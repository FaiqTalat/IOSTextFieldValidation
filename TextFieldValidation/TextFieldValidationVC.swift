//
//  ViewController.swift
//  TextFieldValidation
//
//  Created by Faiq Talat on 24/12/2015.
//  Copyright (c) 2015 Faiq Talat. All rights reserved.
//

import UIKit

class TextFieldValidationVC: UIViewController {
    
    @IBOutlet weak var textField1: ITextField!
    @IBOutlet weak var textField2: ITextField!
    @IBOutlet weak var textField3: ITextField!
    @IBOutlet weak var textField4: ITextField!
    @IBOutlet weak var textField5: ITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textField1.setValidation(3, maxTextLimit: 100, keyboardType: UIKeyboardType.Default, isRequired: true)
        textField2.setValidation(6, maxTextLimit: 100, keyboardType: UIKeyboardType.EmailAddress, isRequired: true)
        textField3.setValidation(11, maxTextLimit: 100, keyboardType: UIKeyboardType.PhonePad)
        textField4.setValidation(3, maxTextLimit: 100, keyboardType: UIKeyboardType.Default)
        textField5.setValidation(3, maxTextLimit: 100, keyboardType: UIKeyboardType.Default)
        
        
        textField1.validateAllTextFields()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func validateAllFields(sender: AnyObject) {
        _validateAllFields()
    }
    
    func _validateAllFields(){
        if textField1.isValid && textField2.isValid && textField3.isValid && textField4.isValid && textField5.isValid {
            print("All Fields Validated.\n")
        }
    }

}

