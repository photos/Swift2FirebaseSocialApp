/*
The MIT License (MIT)

Copyright (c) 2016 Forrest Collins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//--------------------------------------------------------------------------------------------------
// PURPOSE: Custom Cell to present a Post Object. Uses Alamofire to leverage NSURLSession and the
// Foundation URL Loading System to provide first-class networking capabilities. Alamofire is also
// used for in-app image caching.
//--------------------------------------------------------------------------------------------------

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImage: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var likeRef: Firebase!
    
    // store an Alamozfire request so we can cancel it
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // add tap gesture to lieks image
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
    }
    
    // corner radius happens after a profile image has a frame and size
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        showcaseImage.clipsToBounds = true
    }

    func configureCell(post: Post, img: UIImage?) {
        
        self.post = post
        
        likeRef = DataServiceSingleton.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        self.descriptionText.text = post.postDescription
        self.likesLabel.text = "\(post.likes)"
        
        // check if there is an imageUrl, because a user does not have to submit an image
        if post.imageUrl != nil {
            // if there is an imageUrl, we probably have an image
            print("image url found")
            if img != nil {
                self.showcaseImage.image = img // use cached image
            } else {
                
                // no cached image, get image from internet
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["application/json"]).response(completionHandler: { request, response, data, err in
                    
                    if err != nil { // do an if let on this in the future
                        print("no error with image")
                        
                        if let img = UIImage(data: data!) {
                            
                            self.showcaseImage.image = img // put image inside our showcase image
                            
                            FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                            
                        } else {
                            
                            print("invalid image url")
                            //self.showcaseImage.image = nil
                        }
                        
                    } else {
                        print("error with image")
                    }
                })
            }
            
        } else { // no imageUrl, hide the image
            // problem is when the view "sees" that there isn't an image, it will hide the first index image
            // self.showcaseImage.hidden = true
            
            print("no image")
        }
        
        // likeRef grabs the current user's likes and the postKey of the current post
        // check if post exists, observeSingleEventOfType is only called once
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            // In Firebase, if you get data that does not exist, you will get a NSNull
            if let _ = snapshot.value as? NSNull {
                
                // this means we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-empty")
                
            } else {
                // we have liked the image, show full heart
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        // likeRef grabs the current user's likes and the postKey of the current post
        // check if post exists, observeSingleEventOfType is only called once
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            // In Firebase, if you get data that does not exist, you will get a NSNull
            if let _ = snapshot.value as? NSNull {
                // this means we have not liked this specific post, then like it
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true) // add a like
                self.likeRef.setValue(true) // set that we have liked the post in Firebase
            } else {
                // we have liked the image, and like again, show empty
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false) // remove a like
                self.likeRef.removeValue() // delete key if we have not liked the post in Firebase
            }
        })
    }
}
