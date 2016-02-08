//
//  FeedVC.swift
//  picshare
//
//  Created by Forrest Collins on 1/18/16.
//  Copyright © 2016 helloTouch. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cameraButton: UIImageView!
    @IBOutlet weak var postTextField: MaterialTextField!

    var imagePicker: UIImagePickerController!
    
    var posts = [Post]()
    static var imageCache = NSCache() // create one instance of the cache
    
    
    // WHAT'S HAPPENING: Clear out posts array whenever it needs to update, then grab all the objects
    // out of the array, iterate through those objects, convert each one to a Dictionary, then save the
    // key of the snapshot, create a new post with the Dictionary passed into the Post object to parse
    // the data, then append. Then reload the table data
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 375
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // instantiate image picker controller
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // PRINT ALL POST DATA INSTANTLY
        // .Value is called whenever data or children is changed
        // you observe an event type on a reference on a path and whenever 
        // anything is changed, this function is called and your UI is updated
        // this is called many times
        DataServiceSingleton.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            // only called when data is changed in the table
            print(snapshot.value)
            
            self.posts = [] // clear this out any time there is an update needed
            
            // parse out data so it's usable
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    // postDict is same format as in Post.swift
                    // We are going through each of the snapshots in [FDSnapshot] children objects
                    // and convert it to a dictionary. It's AnyObject b/c it could be a String or Int
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }   
            }
            
            // whenever new data comes in, reload the tableview
            self.tableView.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            // cancel requests when you create a new cell
            cell.request?.cancel()
            
            var img: UIImage? // make an empty image
            
            // set the image to the one you grab from the cache if it exists
            // if this doesn't work, an empty image will be passed in
            if let url = post.imageUrl {
                // go to the image cache and grab the url as the key b/c it's unique
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        // if no image, shrink the row
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    // This one is deprecated, but it's fine in this case
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        cameraButton.image = image
    }
    
    // MARK: 
    @IBAction func cameraButtonTapped(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(sender: AnyObject) {
        
        if let txt = postTextField.text where txt != "" {
            if let img = cameraButton.image where img != UIImage(named: "add_camera") {
                
                let urlString = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlString)!
                
                // convert image and string to jpg data
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "ZMYN81PJ739b0c9d57f56e627c61dd70d1c4fc31".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData -> Void in
                    
                    // create a request
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    }) { encodingResult in
                        
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { response in
                                // grab link out of JSON and convert to dictionary
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        if let imgLink = links["image_link"] as? String {
                                            // Success, this is the url we save to Firebase
                                            print("LINK: \(imgLink)")
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            })
                        case .Failure(let error):
                            print(error)
                        }
                }
            
            } else { // no image, just post text description
                self.postToFirebase(nil)
            }
        }
    }
    
    // an image is not required
    // Unlike REST, Firebase won't reject the data that you don't want.
    // With Angular, you have to make sure that a web based app and iphone app have the
    // exact same data structure on their client.
    func postToFirebase(imgUrl: String?) {
        var post: Dictionary<String, AnyObject> = [
        "description": postTextField.text!,
        "totalLikes": 0
        ]
        
        if imgUrl != nil {
            post["imageURL"] = imgUrl
        }
        
        // generate a new post (new child location using a unique key)
        let firebasePost = DataServiceSingleton.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        // set back to defaults
        self.postTextField.text = ""
        self.cameraButton.image = UIImage(named: "add_camera")
        
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        postTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Settings Button Tapped
    @IBAction func settingsButtonTapped(sender: AnyObject) {
        DataServiceSingleton.ds.REF_BASE.unauth()
        storyboard?.instantiateViewControllerWithIdentifier("loginSignup")
    }
}
