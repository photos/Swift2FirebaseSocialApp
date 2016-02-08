/*
The MIT License (MIT)

Copyright (c) 2016 Forrest Collins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

//------------------------------------------------------------------------------------------------------------
// PURPOSE: Material TextField is a custom class to create a Google Material Design style look for a textField
//------------------------------------------------------------------------------------------------------------

import UIKit

class MaterialTextField: UITextField {
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).CGColor
        layer.borderWidth = 1.0
        
    }
    
    // For Placeholder, the rectangle you want the text in
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        let leftValue: CGFloat = 10
        return CGRectInset(bounds, leftValue, 0)
    }
    
    // For editable text, the rectangle you want the text in
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        let leftValue: CGFloat = 10
        return CGRectInset(bounds, leftValue, 0)
    }
}
