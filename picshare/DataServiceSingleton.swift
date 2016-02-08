/*
The MIT License (MIT)

Copyright (c) 2016 Forrest Collins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//-----------------------------------------
// PURPOSE: Singleton to reference Firebase
//-----------------------------------------

// Create a Singleton, which is a single instance of a class, which you have global access to
import Foundation
import Firebase

let URL_BASE = "https://picshare.firebaseIO.com"

class DataServiceSingleton {
    // create a static variable with only one instance in memory and it's globally accessible
    static let ds = DataServiceSingleton()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/Posts")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/Users")
    
    // For good code practice, create public variables to return private variables
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        // OR: let user = Firebase(url: "\(URL_BASE)/Users")
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("Users").childByAppendingPath(uid)
        return user!
    }
    
    // Dictionary for the signup/login provider (ex: provider : facebook)
    // grab a reference to a path and if it does note exist, it will when we save it
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
}

