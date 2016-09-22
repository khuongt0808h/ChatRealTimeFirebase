//
//  ViewController.swift
//  ChatDemo
//
//  Created by Khuong Luu on 9/20/16.
//  Copyright © 2016 Khuong Luu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK
    // Login action
    @IBAction func actionLogin(sender: AnyObject) {
        
        FIRAuth.auth()?.signInWithEmail(txfEmail.text!, password: txfPass.text!, completion: nil)
        
        let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ListFoodIdentity") as! ListFood
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @IBAction func actionSignUp(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default) { action in
                                        
                                        let emailField = alert.textFields![0]
                                        let passwordField = alert.textFields![1]
                                        
                                        FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!, completion:{ (user, error) in
                                            
                                            if error == nil {
                                                FIRAuth.auth()?.signInWithEmail(emailField.text!, password: emailField.text!, completion: nil)
                                                
                                                let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ListFoodIdentity") as! ListFood
                                                self.navigationController?.pushViewController(secondViewController, animated: true)
                                            }
                                            
                                            }
                                        )
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addTextFieldWithConfigurationHandler { (textEmail) in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextFieldWithConfigurationHandler { (textPassword) in
            textPassword.secureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txfEmail {
            txfPass.becomeFirstResponder()
        }
        if textField == txfPass {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
