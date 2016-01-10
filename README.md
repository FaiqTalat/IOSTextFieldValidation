# IOSTextFieldValidation
Make your UITextField Validation Free, Easy And Fast. (Stable Version 2.0 Completed)
Note: Varsion 2.0 Highly Recommended with Xcode 7.2 , Swift 2.2 And iOS 9.2 (last updated on January 10, 2016)

Advantage:
1. auto component location adjestment on keyboard appear clear visible when keyboard appear or disappear.
2. set custom space from kayboard to intractable component.
3. Imp can set minimum or maximum range characters of any type string for names , integer for numbers and email for emailaddress.
4. required and optional functionality when required field is empty so show red signal on validation and go optional field as empty
5. Even Textfield in in scroll view so auto adjust positions of keyboard and clicked component.

Features Added: (password, confirmPass, oldPass, newPass and much more)

1. When scroll view exist so validate all fields from up to down
priority and when one top field is validated auto focus on textfield
which is next to it.

2. Proper management when keyboard appear or dissappear so textfield
place auto change to fit in screen because keyboard take some place in
the screen.
3. A type of field that should response from server then show green
validated signal so just do like this,

if error == "user with this email does not exist."{

self.iTextField.showValidationMsg("Incorrect Email.")
                        }else if error == "invalid password."{

self.iTextField.showValidationMsg("Incorrect Password.")
                        }

and as before it is already validated from client side just need when
server say false so show invalid msg by using textfield method
showValidationMsg.

4. when the situation is,
like SignUP Screen we need to show two password textfield that is
password and confirm password for that purpose we use this method in
ViewController’s viewDidLoad() it will maintain everything,

passwordTextField.setValidation(3, maxTextLimit: 100, keyboardType:
UIKeyboardType.Default, isRequired: true, confirmField:
confirmPasswordTextField)

so when user type a password then confirm field type password that is
not match it will show msg password not matched and consider it as
invalid textfield.

some bugs in previous version 1.0 now removed.
