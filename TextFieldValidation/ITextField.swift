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
    var isRequired = false
    var isValid: Bool {
        if isRequired { // when required so first validate then return its validated or not
            validate()
            if !isValidated {
                self.becomeFirstResponder()
            }
            return isValidated
        }else{
            if isValidated == false{
                return isValidated
            }
        }
        return true // optional
    }
    let className = "ITextField"
    var isHeightInitialized = false
    let placeholderColor = UIColor(red: 199.0/255, green: 199.0/255, blue: 205.0/255, alpha: 1.0)
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 3, right: 10);
    
    // validation settings
    var watchValidation = false
    var isValidated = true
    var minTextLimit: Int?
    var minTextLimitValidated = false
    
    var maxTextLimit: Int?
    var maxTextLimitValidated = false
    
    var emailAddressValidated = false
    
    var inValidMsg: String?
    var showInvalidMsgAfterFocusOut = false // by default (show msg on text change)
    
    // private properties
    let isAnimateValidationMsg = false
    
    var _title: UILabel!
    let _titleColor = UIColor(red: 101.0/255.0, green: 178.0/255.0, blue: 137.0/255.0, alpha: 1.0)
    var _isTitleVisible = false
    
    var _validationView: UIView!
    var _validationViewHeight: CGFloat = 30.0 // by default
    var _validationLabel: UILabel!
    var _validationLabelFontSize: CGFloat = 10.0
    
    
    // MARK: TextField Lines Properties
    var lineColor = UIColor(red: 174.0/255, green: 174.0/255, blue: 175.0/255, alpha: 1.0)
    let validLineColor = UIColor(red: 174.0/255, green: 174.0/255, blue: 175.0/255, alpha: 1.0)
    let inValidLineColor = UIColor.redColor()
    let leftLineWidth: CGFloat = 0.5
    let leftLineHeight: CGFloat = 5.0
    var leftLineColor = UIColor.lightGrayColor()
    let leftLinePadding: CGFloat = 0.5
    
    let bottomLineHeight: CGFloat = 0.5
    var bottomLineColor = UIColor.lightGrayColor()
    let bottomLinePadding: CGFloat = 0.5
    
    let rightLineWidth: CGFloat = 0.5
    let rightLineHeight: CGFloat = 5.0
    var rightLineColor = UIColor.lightGrayColor()
    let rightLinePadding: CGFloat = 0.5
    
    let bottomLine = CALayer()
    let leftLine = CALayer()
    let rightLine = CALayer()
    
    
    // initialize
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        iLog("\(className), \(__FUNCTION__)")
        self.delegate = self
        self.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        // editing pointer color
        self.tintColor = self._titleColor
        
        
        //self.backgroundColor = UIColor.lightGrayColor()
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupLines()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateLines()
        
        updateTitleFrame()
        
        updateValidationViewFrame()
        
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return newBounds(bounds)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return newBounds(bounds)
    }
    
    // MARK: TextField Lines func's
    func setupLines(){
        //   lines color
        leftLineColor = lineColor
        bottomLineColor = lineColor
        rightLineColor = lineColor
        
        // remove border
        self.borderStyle = UITextBorderStyle.None
        
        changeLinesColor(lineColor)
        
        // make lines
        self.updateLines()
        
        // add lines to view
        self.superview!.layer.addSublayer(bottomLine)
        self.superview!.layer.addSublayer(leftLine)
        self.superview!.layer.addSublayer(rightLine)
    }
    
    func updateLines(){
        
        let bottomLineY = self.frame.maxY
        
        bottomLine.frame = CGRectMake(self.frame.origin.x, bottomLineY, self.frame.width, bottomLineHeight)
        
        leftLine.frame = CGRectMake(bottomLine.frame.origin.x, bottomLine.frame.origin.y-(leftLineHeight), leftLineWidth, leftLineHeight)
        
        rightLine.frame = CGRectMake(bottomLine.frame.maxX-(rightLineWidth), bottomLine.frame.origin.y-(rightLineHeight), rightLineWidth, rightLineHeight)
 
    }
    
    
    // got focus
    func textFieldDidBeginEditing(textField: UITextField) {
        iLog("\(className), \(__FUNCTION__)")
        
        validate()
        
    }
    
    func validate(){
        
        dispatch_async(dispatch_get_main_queue(),{
            if self._validationView == nil { // if already not added
                self.addValidationView()
            }
            
            self.validateEmailIfNeeded()
            self._checkMinTextLimit()
            self._checkMaxTextLimit()
            self.manageTitle()
        })
        
    }
    
    func validateEmailIfNeeded(){
        
        if self.keyboardType == .EmailAddress {
            if text!.isEmail == false {
                
                _showValidationMsg("Invalid Email Address")
                changeLinesColor(inValidLineColor)
                self.emailAddressValidated = false
                self.isValidated = false
                
            }else{
                
                iLog("\(className), \(__FUNCTION__), Email Address Validated.")
                changeLinesColor(validLineColor)
                _hideValidationMsg()
                self.emailAddressValidated = true
                self.isValidated = true
                
            }
        }
        
    }
    
    func manageTitle(){
        
        if text?.characters.count > 0{
            dispatch_async(dispatch_get_main_queue(),{
                self.addTitleLabel()
            })
        }else if text?.characters.count < 1{
            dispatch_async(dispatch_get_main_queue(),{
                self.removeTitleLabelIfNeeded()
            })
        }
        
    }
    
    // text did change
    func textFieldDidChange(textField: UITextField){
        iLog("\(className), \(__FUNCTION__), newText: \(textField.text)")
        
        validate()

        manageTitle()

    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    func _checkMinTextLimit(){
        iLog("\(className), \(__FUNCTION__)")
        if self.keyboardType == .EmailAddress && !emailAddressValidated {return}
        if let minLimit = self.minTextLimit { // min limit set
            
            //iLog("textLength: \(self.text.textLength())")
            
            if self.text!.textLength() < minLimit{ // text length is less
                _showValidationMsg("Min \(minLimit) Characters")
                changeLinesColor(inValidLineColor)
                self.isValidated = false
            }else{ // text length is correct according to user limit
                iLog("\(className), \(__FUNCTION__), Validated.")
                changeLinesColor(validLineColor)
                self.isValidated = true
            }
            
            
            
        }
    }
    
    func _checkMaxTextLimit(){
        iLog("\(className), \(__FUNCTION__)")
        if self.keyboardType == .EmailAddress && !emailAddressValidated {return}
        if let maxLimit = self.maxTextLimit { // max limit set
            if !self.text!.isEmpty { // textfield not empty
                if self.isValidated == true { // min text limit is validated so check maxlimit
                    
                    //iLog("textLength: \(self.text.textLength())")
                    
                    if self.text!.textLength() > maxLimit{ // text length is less
                        _showValidationMsg("Max \(maxLimit) Characters")
                        changeLinesColor(inValidLineColor)
                        self.isValidated = false
                    }else{ // text length is correct according to user limit
                        iLog("\(className), \(__FUNCTION__), Validated.")
                        changeLinesColor(validLineColor)
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
        
        validateEmailIfNeeded()
        
        validate()
        
        self.resignFirstResponder()
        
        removeTitleLabelIfNeeded()
        
        removeValidationViewIfNeeded()
        
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
    func setValidation(minTextLimit: Int, maxTextLimit: Int, keyboardType: UIKeyboardType, isRequired: Bool){
        iLog("\(className), \(__FUNCTION__), minLimit: \(minTextLimit), maxLimit: \(maxTextLimit), keyboardType.hashValue: \(keyboardType.hashValue)")
        
        watchValidation = true
        self.minTextLimit = minTextLimit
        self.maxTextLimit = maxTextLimit
        self.keyboardType = keyboardType
        self.isRequired = isRequired
    }
    
    func removeValidation(){
        iLog("\(className), \(__FUNCTION__)")
        
        watchValidation = false
        self.minTextLimit = nil
        self.maxTextLimit = nil
    }
    
    
    
    
    
    // helper func's
    
    func addTitleLabel(){
        iLog("\(className), \(__FUNCTION__)")
        
        if _isTitleVisible == false{
            _isTitleVisible = true
            self._title = UILabel(frame: self.frame)
            self._title.textColor = self.placeholderColor
            //self._title.backgroundColor = UIColor.grayColor()
            self._title.font = self.font
            self._title.adjustsFontSizeToFitWidth = true
            self._title.minimumScaleFactor = 0.50
            self._title.textAlignment = NSTextAlignment.Left
            
            if self.placeholder != nil{
                self._title.text = self.placeholder!
            }
            
            self.superview?.addSubview(self._title)
            
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self._title.frame.origin.y -= self.frame.size.height
                self._title.frame.size.width -= self.frame.size.width/2
                self._title.textColor = self._titleColor
                
                self._title.font = UIFont(name: self.font!.fontName, size: self.font!.pointSize - (self.font!.pointSize/3) )
                
            }
            
        }
        
        
    }
    
    func updateTitleFrame(){
        if self._isTitleVisible {
            self._title.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y - (self.frame.size.height), width: self.frame.size.width/2, height: self.frame.size.height)
        }
    }
    
    func removeTitleLabelIfNeeded(){
        iLog("\(className), \(__FUNCTION__)")
        
        if _isTitleVisible == true && self.text?.textLength() < 1{
            
            self._title.removeFromSuperview()
            self._title = nil
            self._isTitleVisible = false
            
        }
        
    }
    
    
    
    
    func addValidationView(){
        iLog("\(className), \(__FUNCTION__)")
        
        if _validationView == nil {
            dispatch_async(dispatch_get_main_queue(),{
                
                self._validationView = UIView(frame: CGRect(x: self.frame.origin.x + (self.frame.width/2), y: self.frame.origin.y-( self.frame.size.height-(self.frame.size.height/3) ), width: self.frame.width/2, height: self.frame.size.height-(self.frame.size.height/3) ))
                self._validationView.frame.origin.y = self.frame.origin.y-(self._validationView.frame.height)
                //self._validationView.backgroundColor = UIColor.brownColor()
                self.superview?.addSubview(self._validationView)
                
                self._validationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self._validationView.frame.width, height: self._validationView.frame.height))
                self._validationLabel.textColor = UIColor.orangeColor()
                self._validationLabel.font = UIFont(name: self._validationLabel.font.fontName, size: self.font!.pointSize-(self.font!.pointSize/4))
                self._validationLabel.adjustsFontSizeToFitWidth = true
                self._validationLabel.minimumScaleFactor = 0.50
                self._validationLabel.textAlignment = NSTextAlignment.Right
                self._validationView.addSubview(self._validationLabel)
                
            })
        }
        
    }
    
    func updateValidationViewFrame(){
        if self._validationView != nil {
            self._validationView.frame = CGRect(x: self.frame.origin.x + (self.frame.width/2), y: self.frame.origin.y-( self.frame.size.height-(self.frame.size.height/3) ), width: self.frame.width/2, height: self.frame.size.height-(self.frame.size.height/3) )
            self._validationLabel.frame = CGRect(x: 0, y: 0, width: self._validationView.frame.width, height: self._validationView.frame.height)
        }
    }
    
    func _showValidationMsg(msg: String){
        iLog("\(className), \(__FUNCTION__), msg: \(msg)")
        dispatch_async(dispatch_get_main_queue(),{
            self.updateValidationViewFrame()
            if self._validationView != nil {
            self._validationLabel.text = msg
            self._validationView.hidden = false
            self.animateText(self._validationLabel)
            }
        })
    }
    
    func animateText(label: UILabel){
        
        if !isAnimateValidationMsg {return}
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            label.alpha = 0.6
            
            self.leftLine.opacity = 0.3
            self.bottomLine.opacity = 0.3
            self.rightLine.opacity = 0.3
            
            }, completion: { (bool) -> Void in
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    
                    label.alpha = 1.0
                    
                    self.leftLine.opacity = 1.0
                    self.bottomLine.opacity = 1.0
                    self.rightLine.opacity = 1.0
                    
                    }, completion: nil)
                
        })
    }
    
    func changeLinesColor(color: UIColor){
        leftLine.backgroundColor = color.CGColor
        bottomLine.backgroundColor = color.CGColor
        rightLine.backgroundColor = color.CGColor
    }
    
    func _hideValidationMsg(){
        iLog("\(className), \(__FUNCTION__)")
        dispatch_async(dispatch_get_main_queue(),{
            if self._validationView != nil {
            self._validationLabel.text = ""
            self._validationView.hidden = true
            }
        })
    }
    
    func removeValidationViewIfNeeded(){
        iLog("\(className), \(__FUNCTION__)")
        
        if isValidated {
            _validationLabel.removeFromSuperview()
            _validationView.removeFromSuperview()
            
            _validationView = nil
            _validationLabel = nil
        }
        
    }
    
    private func newBounds(bounds: CGRect) -> CGRect {
        //iLog("\(className), \(__FUNCTION__)")
        var newBounds = bounds
        newBounds.origin.x += padding.left
        newBounds.origin.y += padding.top
        newBounds.size.height -= padding.top + padding.bottom
        newBounds.size.width -= padding.left + padding.right
        return newBounds
    }
    
    func iLog(data: AnyObject?){
        if isLog && data != nil{
            dispatch_async(dispatch_get_main_queue(),{
                
                // For Swift 1.2
                print("\(data!)")
                print("") // for new line after each log
                
                /*
                // For Swift 2.1 or later
                print("\(data!)")
                print("") // for new line after each log
                */
                
            })
        }
    }
    
    
}


extension String{
    
    func textLength()->Int{
        let textLength = self.characters.count
        return textLength
    }
    
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(self)
        return result
    }
    
}

