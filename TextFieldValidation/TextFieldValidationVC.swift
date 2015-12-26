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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textField1.setValidation(3, maxTextLimit: 5, keyboardType: UIKeyboardType.EmailAddress)
        textField2.setValidation(5, maxTextLimit: 10, keyboardType: UIKeyboardType.Default)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

