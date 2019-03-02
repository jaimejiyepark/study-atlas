//
//  LoginViewController.swift
//  StudyAtlas
//
//  Created by Jaime Park on 11/12/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate{

    @IBAction func backbutton(_ sender: Any){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.addTarget(self, action: #selector(handleSignin), for: UIControl.Event.touchUpInside)
        submitButton.makeRoundButton()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
    }

    @objc func handleSignin(){
        guard let email = emailTextfield.text else { return }
        guard let password = passwordTextfield.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password){ user, error in
            if error == nil && user != nil{
                self.navigateToMap()
                print("youre logged in!")
            } else { //an error alert will be presented if there is an error with the login
                let errorAlert = UIAlertController.init(title: "Login Error",
                    message: "There was an error with the login. Please try again.",
                    preferredStyle: .alert)
                
                errorAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                    style: .default,
                    handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }
                  )
                )
                self.present(errorAlert, animated: true, completion: nil)
                print("uh oh.")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if emailTextfield.isFirstResponder { emailTextfield.resignFirstResponder() }
        if passwordTextfield.isFirstResponder { passwordTextfield.resignFirstResponder() }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextfield:
            emailTextfield.resignFirstResponder()
            passwordTextfield.becomeFirstResponder()
        case passwordTextfield:
            passwordTextfield.resignFirstResponder()
            handleSignin()
        default:
            return true
        }
        return true
    }
    
    func navigateToMap(){
        if let mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController{

            if let navigator = navigationController {
                navigator.pushViewController(mapView, animated: true)
            }
        }
    }

}

