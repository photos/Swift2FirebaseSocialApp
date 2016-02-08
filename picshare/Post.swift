/*
The MIT License (MIT)

Copyright (c) 2016 Forrest Collins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

//---------------------------------------------------------------------------------
// PURPOSE: Use this class to create a Post object. Image is not required in a post
//---------------------------------------------------------------------------------

import Foundation
import Firebase
// store data in classes rather than dictionaries
// handle this all in the model layer

class Post {
    private var _postDescription: String! // required
    private var _imageUrl: String? // Optional, user doesn't have to post image
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: Firebase!
    
    // public variable
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    // create an initializer
    init(description: String, imageUrl: String?, username: String) {
        self._postDescription = postDescription
        self._imageUrl = imageUrl
        self._username = username
        // when you have a new post it will have zero likes
    }
    
    // convert data downloaded from Firebase into dictionary
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        // grab likes out of dictionary if there are any
        // the names in the dictionary "totalLikes", "imageURL" & "description" are the exact names in Firebase
        if let likes = dictionary["totalLikes"] as? Int {
            self._likes = likes
        } else {
            _likes = 0 // app crashes if no likes
        }
        
        if let imgUrl = dictionary["imageURL"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        // grab ref to specific post
        self._postRef = DataServiceSingleton.ds.REF_POSTS.childByAppendingPath(self._postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike == true {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        // grab current like value and replace with new likes
        _postRef.childByAppendingPath("totalLikes").setValue(_likes)
    }
}