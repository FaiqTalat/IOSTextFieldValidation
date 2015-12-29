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
        iLog("\(className), \(__FUNCTION__)")
        
        self.forceToResign = false
        self.forceToEdit = false
        
        if isRequired { // when required so first validate then return validated or not
            iLog("\(className), \(__FUNCTION__), isRequired")
            return validate()
        }
        
        if !isRequired && text!.textLength() > 0 { // if typed something in optional field then validate it also.
            return validate()
        }
        
        if !isRequired && text!.textLength() < 1 { // optional field and nothing is written in text so valid it without validate.
            isValidated = true
            removeValidationViewIfNeeded()
            removeTitleLabelIfNeeded()
            changeLinesColor(lineColor)
            iLog("\(className), \(__FUNCTION__), Optional Field isValidated: \(isValidated).")
            
            if !forceToEdit {
                iLog("\(className), \(__FUNCTION__), isValidated: \(isValidated), forceToEdit: \(forceToEdit)")
                self.resignFirstResponder() // if validated so resign it
            }
            
            return isValidated
        }
        
        return false // other cases
    }
    var className = "ITextField"
    var isHeightInitialized = false
    let placeholderColor = UIColor(red: 199.0/255, green: 199.0/255, blue: 205.0/255, alpha: 1.0)
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 3, right: 10);
    
    // validation settings
    var watchValidation = false
    var isValidated = false
    var lastValidationCheckedStatus = false
    var forceToResign = false
    var forceToEdit = false
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
    
    var _isValidationViewAdded = false
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
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.className = "\(self.className), \(self.placeholder)"
        iLog("\(className), \(__FUNCTION__)")
        self.delegate = self
        self.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        // editing pointer color
        self.tintColor = self._titleColor
        
        self.returnKeyType = .Done
        
        //self.backgroundColor = UIColor.lightGrayColor()
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupLines()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //iLog("\(className), \(__FUNCTION__), \(self.placeholder)")
        
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
        
        // add done button on numeric keyboard
        if keyboardType == .NumberPad || keyboardType == .PhonePad {
            addDoneButtonOnKeyboard()
        }
        
        if !isRequired && text!.textLength() < 1 { // optional field and nothing is written in text
            showOptionalMsg()
            return
        }
        
        if isRequired && text!.textLength() < 1 { // required field and nothing is written in text
            showRequiredMsg()
            return
        }
        
        forceToEdit = true
        
        validate()
        
        if isRequired { // auto show done button when typed something in text just for required fields
            self.enablesReturnKeyAutomatically = true
        }
        
    }
    
    func validate()->Bool{
        
        
        self.validateEmailIfNeeded()
        self._checkMinTextLimit()
        self._checkMaxTextLimit()
        self.manageTitle()
        
        if isValidated {
            changeLinesColor(lineColor)
            removeValidationViewIfNeeded()
            removeTitleLabelIfNeeded()
        }
        
        iLog("\(className), \(__FUNCTION__), isValidated: \(isValidated)")
        return isValidated
        
    }
    
    func validateEmailIfNeeded()->Bool{
        if isValidated {return isValidated} // already validated
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
                
                return true
                
            }
        }
        return false
    }
    
    func manageTitle(){
        
        if text?.textLength() > 0{
            dispatch_async(dispatch_get_main_queue(),{
                self.addTitleLabel()
            })
        }else if text?.textLength() < 1{
            dispatch_async(dispatch_get_main_queue(),{
                self.removeTitleLabelIfNeeded()
            })
        }
        
    }
    
    // text did change
    func textFieldDidChange(textField: UITextField){
        iLog("\(className), \(__FUNCTION__), newText: \(textField.text)")
        manageTitle()
        
        if !isRequired && text!.textLength() < 1 { // optional field and nothing is written in text
            
            isValidated = true
            changeLinesColor(lineColor)
            iLog("\(className), \(__FUNCTION__), Optional Field isValidated: \(isValidated).")
            
            showOptionalMsg()
            
            return
        }
        
        if isRequired && text!.textLength() < 1 { // required field and nothing is written in text
            showRequiredMsg()
            return
        }
        
        isValidated = false
        lastValidationCheckedStatus = false
        
        if keyboardType == .EmailAddress { // when user is typing email! dont show invalid email msg when user done then check and show invalid msg
            hideOptionalORRequiredMsg()
            return
        }
        
        
        validate()
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.superview?.validateAllTextFields()
        return true
    }
    
    func _checkMinTextLimit(){
        
        if self.keyboardType == .EmailAddress && !emailAddressValidated {return} // if keyboard type email so first validate email
        if isValidated {return} // already validated
        iLog("\(className), \(__FUNCTION__)")
        if let minLimit = self.minTextLimit { // min limit set
            
            //iLog("textLength: \(self.text.textLength())")
            
            if self.text!.textLength() < minLimit{ // text length is less
                _showValidationMsg("Min \(minLimit) Characters")
                changeLinesColor(inValidLineColor)
                self.isValidated = false
            }else{ // text length is correct according to user limit
                iLog("\(className), \(__FUNCTION__), Validated.")
                _hideValidationMsg()
                changeLinesColor(validLineColor)
                self.isValidated = true
            }
            
            
            
        }
    }
    
    func _checkMaxTextLimit(){
        
        if self.keyboardType == .EmailAddress && !emailAddressValidated {return} // if keyboard type email so first validate email
        if isValidated {return} // already validated
        iLog("\(className), \(__FUNCTION__)")
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
                        _hideValidationMsg()
                        changeLinesColor(validLineColor)
                        self.isValidated = true
                    }
                    
                    
                }
            }
        }
    }
    
    // release focus
    func textFieldDidEndEditing(textField: UITextField) {
        iLog("\(className), \(__FUNCTION__)")
        
        self.forceToResign = true
        
        if !isRequired && text!.textLength() < 1 { // optional field and nothing is written in text
            hideOptionalORRequiredMsg()
            return
        }
        
        if isRequired && text!.textLength() < 1 { // required field and nothing is written in text
            hideOptionalORRequiredMsg()
            return
        }
        
        validate()
        
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
    
    func showRequiredMsg(){
        _showValidationMsg("Required")
    }
    func showOptionalMsg(){
        _showValidationMsg("Optional")
    }
    func hideOptionalORRequiredMsg(){
        _hideValidationMsg()
        removeValidationViewIfNeeded()
    }
    
    func addTitleLabel(){
        
        if _isTitleVisible == false{
            iLog("\(className), \(__FUNCTION__)")
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
        
        if _isTitleVisible == true && self.text?.textLength() < 1{
            iLog("\(className), \(__FUNCTION__)")
            self._title.removeFromSuperview()
            self._title = nil
            self._isTitleVisible = false
            
        }
        
    }
    
    func addValidationViewIfNeeded(){
        
        if !_isValidationViewAdded {
            iLog("\(className), \(__FUNCTION__)")
            _isValidationViewAdded = true
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
        
        self.addValidationViewIfNeeded()
        
        dispatch_async(dispatch_get_main_queue(),{
            self.updateValidationViewFrame()
            if self._validationView != nil {
                self.iLog("\(self.className), \(__FUNCTION__), msg: \(msg)")
                self._validationLabel.text = msg
                self._validationView.hidden = false
                self.animateText(self._validationLabel)
                self.lastValidationCheckedStatus = true
                
                if !self.forceToResign { // when user force to resign set focus out or in another textfield
                    self.becomeFirstResponder()
                }
                
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
        dispatch_async(dispatch_get_main_queue(),{
            if self._validationView != nil && !self._validationView.hidden {
                self.iLog("\(self.className), \(__FUNCTION__)")
                self._validationLabel.text = ""
                self._validationView.hidden = true
            }
        })
    }
    
    func removeValidationViewIfNeeded(){
        iLog("\(className), \(__FUNCTION__)")
        
        if _isValidationViewAdded && isValidated {
            _validationLabel.removeFromSuperview()
            _validationView.removeFromSuperview()
            
            _validationView = nil
            _validationLabel = nil
            _isValidationViewAdded = false
        }
        
    }
    
    func addDoneButtonOnKeyboard(){
        
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        doneToolbar.items = [flexSpace, done]
        
        self.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction(){
        self.resignFirstResponder()
        self.superview?.validateAllTextFields()
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
                print("\n") // for new line after each log
                
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

extension UIScrollView {
    // hide keyboard when tap on outside the textfield
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.endEditing(true)
    }
}

extension UIView {
    
    // validation method for all textfield with first in first out priority in view
    func validateAllTextFields()->Bool{
        
        // get all tf in view with first in first out priority
        func _getTextFieldsWithPriorityAndCheckIsValid(textfields: [ITextField])->Bool{
            
            var _allTFWithXY = [CGFloat: ITextField]()
            
            // ascending all tf with respect to Y
            for _iTextField in textfields{
                //iLog("\(self.dynamicType), \(__FUNCTION__), (for _iTextField in textfields) \(_iTextField.placeholder)")
                let _iTextField_XY = _iTextField.frame.origin.x * _iTextField.frame.origin.y
                _allTFWithXY[_iTextField_XY] = _iTextField
            }
            
            let allTFSortedByY = Array(_allTFWithXY.keys).sort()
            //iLog("\(self.dynamicType), \(__FUNCTION__), allTFSortedByY \(allTFSortedByY)")
            
            for _iTextFieldY in allTFSortedByY{
                if let _iTextField = _allTFWithXY[_iTextFieldY]{
                    if !_iTextField.isValid { // is one TF is invalid so no try another tf
                        return false
                    }
                }
            }
            
            return true
        }
        
        // get all tf in view
        var allITextfields = [ITextField]()
        
        // check if scroll view or not
        
        for _subview in self.subviews {
            
            iLog("\(self.dynamicType), \(__FUNCTION__), _subview.dynamicType \(_subview.dynamicType)")
            
            // if scroll view then find in scroll subviews
            if "\(_subview.dynamicType)" == "UIScrollView" {
                
                for __subview in _subview.subviews {
                    
                    if let _iTextField = __subview as? ITextField {
                        allITextfields.append(_iTextField)
                    }
                    
                }
                
            }else{ // all textfields direct in uiview
                
                if let _iTextField = _subview as? ITextField {
                    allITextfields.append(_iTextField)
                }
                
            }
        }
        
        return _getTextFieldsWithPriorityAndCheckIsValid(allITextfields)
        
    }
    
    // hide keyboard when tap on outside the textfield
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.endEditing(true)
    }
    
    func getFirstResponder()->ITextField?{
        
        for _subview in self.subviews {
            
            // if scroll view then find in scroll subviews
            if "\(_subview.dynamicType)" == "UIScrollView" {
                
                for __subview in _subview.subviews {
                    
                    if __subview.isFirstResponder() {
                        if let _iTextField = __subview as? ITextField {
                            return _iTextField
                        }
                    }
                    
                }
                
            }else{ // all textfields direct in uiview
                
                if _subview.isFirstResponder() {
                    if let _iTextField = _subview as? ITextField {
                        return _iTextField
                    }
                }
                
            }
        }
        
        return nil
    }
    
    func getScrollViewIfAny()->UIScrollView?{
        
        for _subview in self.subviews {
            // if scroll view then find in scroll subviews
            if let scrollView = _subview as? UIScrollView {
                //iLog("scrollView: \(scrollView)")
                return scrollView
            }
        }
        
        return nil
    }
    
}

// extend all uiviewcontroller classes from LoginUserDelegate add self in delegates
extension UIViewController {
    
    public override static func initialize() {
        
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        // make sure this isn't a subclass
        if self !== UIViewController.self {
            return
        }
        
        dispatch_once(&Static.token) {
            
            let originalSelectorVDL = Selector("viewDidLoad")
            let swizzledSelectorVDL = Selector("_viewDidLoad")
            
            let originalMethod = class_getInstanceMethod(self, originalSelectorVDL)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelectorVDL)
            
            let didAddMethod = class_addMethod(self, originalSelectorVDL, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelectorVDL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
            
        }
        
    }
    
    // MARK: - Method Swizzling
    
    func _viewDidLoad() {
        
        // custom did load functions
        
        //print("\(__FUNCTION__): \(self.dynamicType)")
        
        listenerOnKeyboardAppearORDisappear()
        
    }
    
    // helper methods
    func listenerOnKeyboardAppearORDisappear(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"moveViewAccordingToActiveTextfield:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"moveViewAccordingToActiveTextfield:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func moveViewAccordingToActiveTextfield(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardSizeNSValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
            if keyboardSizeNSValue == nil {return}
            let keyboardSize = keyboardSizeNSValue!.CGRectValue()
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double
            if duration == nil {return}
            let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt
            if curve == nil {return}
            let options = UIViewAnimationOptions(rawValue: curve!)
            
            UIView.animateWithDuration(duration!, delay: 0.0, options: options, animations: { () -> Void in
                
                if notification.name == UIKeyboardWillShowNotification { // keyboard will up
                    
                    if let activeTextField = self.view.getFirstResponder() {// one field is active
                        let someExtraDistance: CGFloat = 10.0 // some distance from textfield for better user experience.
                        var distanceFromTFToKeyboard = (self.view.frame.height - activeTextField.frame.maxY) - keyboardSize.height
                        
                        print("distanceFromTFToKeyboard: \(distanceFromTFToKeyboard)")
                        if distanceFromTFToKeyboard == -19.0 { // when suggestion view open
                            self.moveViewWithIncreaseORDecreaseY(19.0 + someExtraDistance, _duration: duration!, _options: options)
                        }else if distanceFromTFToKeyboard < 0 {
                            distanceFromTFToKeyboard -= someExtraDistance
                            self.moveViewAtY(distanceFromTFToKeyboard, _duration: duration!, _options: options)
                        }
                        
                    }
                    
                }else if notification.name == UIKeyboardWillHideNotification { // keyboard will down
                    self.moveViewAtY(0.0, _duration: duration!, _options: options)
                }
                
                }, completion: nil)
            
        }
        
    }
    
    // helper func to move the view with all components
    func moveViewAtY(_yAxis: CGFloat, _duration: Double, _options: UIViewAnimationOptions){
        //iLog("\(self.dynamicType), \(__FUNCTION__), _yAxis: \(_yAxis), _duration: \(_duration), _options: \(_options)")
        
        
        // 1. when scrollview exist so work as scrollview nature.
        if let scrollView = self.view.getScrollViewIfAny() {
            scrollView.contentInset.top = _yAxis
            self.view.layoutIfNeeded() // update frames for view
            _updateLayoutSubviews() // update frames for all sub views
            return
        }
        
        // 2. when direct view in viewcontroller
        for cons in self.view.constraints {
            
            //print("cons.dynamicType: \(cons.dynamicType)| cons.firstItem.dynamicType: \(cons.firstItem.dynamicType)| cons.secondItem.dynamicType: \(cons.secondItem.dynamicType)| \n")
            
            if "\(cons.dynamicType)" == "_UILayoutSupportConstraint" {
                //iLog("\(self.dynamicType), \(__FUNCTION__), cons.dynamicType: \(cons.dynamicType)")
                if let _ = cons.secondItem as? UIView {
                    //iLog("\(self.dynamicType), \(__FUNCTION__), desc: \(cons.firstItem)| \(cons.secondItem)")
                    
                    cons.constant = _yAxis
                    self.view.layoutIfNeeded() // update frames for view
                    _updateLayoutSubviews() // update frames for all sub views
                    
                    
                }
            }
            
        }
        
        
    }
    
    func moveViewWithIncreaseORDecreaseY(_yAxis: CGFloat, _duration: Double, _options: UIViewAnimationOptions){
        iLog("\(self.dynamicType), \(__FUNCTION__)")
        
        
        // 1. when scrollview exist so work as scrollview nature.
        if let scrollView = self.view.getScrollViewIfAny() {
            scrollView.contentInset.top -= _yAxis
            self.view.layoutIfNeeded() // update frames for view
            _updateLayoutSubviews() // update frames for all sub views
            return
        }
        
        // 2. when direct view in viewcontroller
        for cons in self.view.constraints {
            
            //print("cons.dynamicType: \(cons.dynamicType)| cons.firstItem.dynamicType: \(cons.firstItem.dynamicType)| cons.secondItem.dynamicType: \(cons.secondItem.dynamicType)| \n")
            
            if "\(cons.dynamicType)" == "_UILayoutSupportConstraint" {
                
                if let _ = cons.secondItem as? UIView {
                    //print("desc: \(cons.firstItem)| \(cons.secondItem) \n\n")
                    
                    cons.constant -= _yAxis
                    self.view.layoutIfNeeded() // update frames for view
                    _updateLayoutSubviews() // update frames for all sub views
                    
                    
                }
                
            }
            
        }
        
        
    }
    
    
    func _updateLayoutSubviews(){
        
        for _subview in self.view.subviews {
            
            // if scroll view then find in scroll subviews
            if "\(_subview.dynamicType)" == "UIScrollView" {
                _subview.layoutIfNeeded()
                _subview.layoutSubviews()
                for __subview in _subview.subviews {
                    __subview.layoutSubviews()
                }
                
            }else{ // all textfields direct in uiview
                _subview.layoutSubviews()
            }
        }
        
    }
    
    
    
    
    
    
}







let isLog = true

func iLog(data: AnyObject?){
    if isLog && data != nil{
        dispatch_async(dispatch_get_main_queue(),{
            
            // For Swift 1.2
            print("\(data!)")
            print("\n") // for new line after each log
            
        })
    }
}








