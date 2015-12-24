//
//  ITextField.swift
//  TextFieldValidation
//
//  Created by Faiq Talat on 24/12/2015.
//  Copyright (c) 2015 Faiq Talat. All rights reserved.
//

import UIKit

class ITextField: UITextField, UITextFieldDelegate {

    let isLog = true
    let className = "ITextField"
    var isHeightInitialized = false
    
    // validation settings
    var watchValidation = false
    var isValidated = false
    var textType: ITextFieldTextTypes?
    var minTextLimit: Int?
    var minTextLimitValidated = false
    
    var maxTextLimit: Int?
    var maxTextLimitValidated = false
    
    var inValidMsg: String?
    var showInvalidMsgAfterFocusOut = false // by default (show msg on text change)

    // private properties
    var _validationView: UIView!
    var _validationViewHeight: CGFloat = 10.0 // by default
    var _validationLabel: UILabel!
    
    
    
    // initialize
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        iLog("\(className), \(__FUNCTION__)")
        self.delegate = self
        self.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)

        let
        _validationViewHeight = (self.frame.height / 100) * 10
        
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        if !isHeightInitialized {
//            isHeightInitialized = true
//        self.frame.size.height += 10
//        }
    }
    // got focus
    func textFieldDidBeginEditing(textField: UITextField) {
        iLog("\(className), \(__FUNCTION__)")
        
        if _validationView == nil { // if already not added
        addValidationView()
        }
        
    }
    
    // text did change
    func textFieldDidChange(textField: UITextField){
        iLog("\(className), \(__FUNCTION__), newText: \(textField.text)")
        
        _checkMinTextLimit()
        
    }
    
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    func _checkMinTextLimit(){
        iLog("\(className), \(__FUNCTION__)")
        if let minLimit = self.minTextLimit { // min limit set
                
                //iLog("textLength: \(self.text.textLength())")
            
                if self.text.textLength() < minLimit{ // text length is less
                    _showValidationMsg("Minimum \(minLimit) Characters Required.")
                    self.isValidated = false
                }else{ // text length is correct according to user limit
                    iLog("\(className), \(__FUNCTION__), Validated.")
                    self.isValidated = true
                    _checkMaxTextLimit()
                }
                
                
            
        }
    }
    
    func _checkMaxTextLimit(){
        iLog("\(className), \(__FUNCTION__)")
        if let maxLimit = self.maxTextLimit { // max limit set
            if !self.text.isEmpty { // textfield not empty
                if self.isValidated == true { // min text limit is validated so check maxlimit
                    
                    //iLog("textLength: \(self.text.textLength())")
                    
                    if self.text.textLength() > maxLimit{ // text length is less
                        _showValidationMsg("Maximum \(maxLimit) Characters Required.")
                        self.isValidated = false
                    }else{ // text length is correct according to user limit
                        iLog("\(className), \(__FUNCTION__), Validated.")
                        _hideValidationMsg()
                        self.isValidated = true
                    }
                    
                    
                }
            }
        }
    }
    
    
    // release focus
    func textFieldDidEndEditing(textField: UITextField) {
        iLog("\(className), \(__FUNCTION__)")

        removeValidationView()
    }
    
    
    // MARK: Validation Methods
    
    func setValidation(minTextLimit: Int, maxTextLimit: Int){
        iLog("\(className), \(__FUNCTION__), minLimit: \(minTextLimit), maxLimit: \(maxTextLimit)")
        
        watchValidation = true
        self.minTextLimit = minTextLimit
        self.maxTextLimit = maxTextLimit
        
    }
    func setValidation(minTextLimit: Int, maxTextLimit: Int, keyboardType: UIKeyboardType){
        iLog("\(className), \(__FUNCTION__), minLimit: \(minTextLimit), maxLimit: \(maxTextLimit), keyboardType.hashValue: \(keyboardType.hashValue)")
        
        watchValidation = true
        self.minTextLimit = minTextLimit
        self.maxTextLimit = maxTextLimit
        self.keyboardType = keyboardType
        
    }
    
    func removeValidation(){
        iLog("\(className), \(__FUNCTION__)")
        
        watchValidation = false
        self.minTextLimit = nil
        self.maxTextLimit = nil
        self.textType = nil
    }
    
    
    
    
    
    // helper func's
    
    func addValidationView(){
        iLog("\(className), \(__FUNCTION__)")
        
        if _validationView == nil {
            dispatch_async(dispatch_get_main_queue(),{
                
            self._validationView = UIView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y-self._validationViewHeight+5, width: self.frame.width, height: self._validationViewHeight))
            self.superview?.addSubview(self._validationView)
            
            self._validationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self._validationView.frame.width, height: self._validationView.frame.height))
            self._validationLabel.textColor = UIColor.orangeColor()
            self._validationLabel.font = UIFont(name: self._validationLabel.font.fontName, size: 6)
            self._validationLabel.textAlignment = NSTextAlignment.Right
            self._validationView.addSubview(self._validationLabel)
            
            self._checkMinTextLimit()
                
            })
        }
        
    }
    
    func _showValidationMsg(msg: String){
        iLog("\(className), \(__FUNCTION__), msg: \(msg)")
        dispatch_async(dispatch_get_main_queue(),{
            self._validationLabel.text = msg
            self._validationView.hidden = false
            self.animateText(self._validationLabel)
        })
    }
    
    func animateText(label: UILabel){
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            label.alpha = 0.6
            
            }, completion: { (bool) -> Void in
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    
                    label.alpha = 1.0
                    
                    }, completion: nil)
                
        })
    }

    func _hideValidationMsg(){
        iLog("\(className), \(__FUNCTION__)")
        dispatch_async(dispatch_get_main_queue(),{
            self._validationLabel.text = ""
            self._validationView.hidden = true
            
        })
    }
    
    func removeValidationView(){
        iLog("\(className), \(__FUNCTION__)")
        
        if isValidated {
            _validationLabel.removeFromSuperview()
            _validationView.removeFromSuperview()
            
            _validationView = nil
            _validationLabel = nil
        }
        
    }
    
    func iLog(data: AnyObject?){
        if isLog && data != nil{
            dispatch_async(dispatch_get_main_queue(),{
                
                // For Swift 1.2
                println("\(data!)")
                println("") // for new line after each log
                
                /*
                // For Swift 2.1 or later
                print("\(data!)")
                print("") // for new line after each log
                */
                
            })
        }
    }
    

}

// text types
enum ITextFieldTextTypes {
    case All
    case Numeric
    case Alphabets
    case Alphanumeric
}

extension String{
    func textLength()->Int{
        let textLength = countElements(self)
        return textLength
    }
}

