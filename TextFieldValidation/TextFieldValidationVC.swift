//
//  ViewController.swift
//  TextFieldValidation
//
//  Created by Faiq Talat on 24/12/2015.
//  Copyright (c) 2015 Faiq Talat. All rights reserved.
//

import UIKit

class TextFieldValidationVC: UIViewController {
    
    // All Text Fields
    @IBOutlet weak var firstNameTF: ITextField!
    @IBOutlet weak var lastNameTF: ITextField!
    @IBOutlet weak var ageTF: ITextField!
    @IBOutlet weak var languageTF: ITextField!
    @IBOutlet weak var addressTF: ITextField!
    @IBOutlet weak var emailAddressTF: ITextField!
    @IBOutlet weak var cityTF: ITextField!
    @IBOutlet weak var countryTF: ITextField!
    @IBOutlet weak var websiteTF: ITextField!
    @IBOutlet weak var contactNumberTF: ITextField!
    @IBOutlet weak var professionalTF: ITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Required TextFields
        firstNameTF.setValidation(3, maxTextLimit: 100, keyboardType: .Alphabet, isRequired: true)
        lastNameTF.setValidation(3, maxTextLimit: 100, keyboardType: .Alphabet, isRequired: true)
        ageTF.setValidation(2, maxTextLimit: 100, keyboardType: UIKeyboardType.NumberPad, isRequired: true)
        languageTF.setValidation(3, maxTextLimit: 100, keyboardType: .Alphabet, isRequired: true)
        addressTF.setValidation(2, maxTextLimit: 200, keyboardType: .Alphabet, isRequired: true)
        cityTF.setValidation(3, maxTextLimit: 100, keyboardType: UIKeyboardType.Default, isRequired: true)
        countryTF.setValidation(3, maxTextLimit: 100, keyboardType: UIKeyboardType.Default, isRequired: true)
        
        // Optional TextFields
        websiteTF.setValidation(3, maxTextLimit: 100, keyboardType: UIKeyboardType.URL)
        contactNumberTF.setValidation(1, maxTextLimit: 100, keyboardType: UIKeyboardType.PhonePad)
        professionalTF.setValidation(1, maxTextLimit: 100, keyboardType: UIKeyboardType.Default)
        emailAddressTF.setValidation(6, maxTextLimit: 100, keyboardType: UIKeyboardType.EmailAddress)
 
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func validateAllFields(sender: AnyObject) {
        
        // validate all textfields
        let isAllTextFieldsValidated = self.view.validateAllTextFields()
        
        print("\(self.dynamicType), \(__FUNCTION__), isAllTextFieldsValidated: \(isAllTextFieldsValidated)")
        
        // get all newly entered OR Text changed with new text Fields
        let allTextFieldsWithChangedText = self.view.getTextFieldsWithChangedText()
        
        for _textfield in allTextFieldsWithChangedText {
            
            // do anything you want with newly entered OR Text changed with new text Fields
            print("\(self.dynamicType), \(__FUNCTION__), changedTextField: \(_textfield.placeholder!) with new text: \(_textfield.text!) \n\n")
            
        }
        
    }
    
    
}

