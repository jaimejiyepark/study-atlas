//
//  SignupViewController.swift
//  StudyAtlas
//
//  Created by Jaime Park on 11/20/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//
import Foundation
import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.addTarget(self, action: #selector(handleSignup), for: UIControl.Event.touchUpInside)
        submitButton.makeRoundButton()
        addTextFieldDelegates()
    }
    
    func addTextFieldDelegates()
    {
        usernameTextfield.delegate = self
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleSignup(){
        guard let email = emailTextfield.text else { return }
        guard let password = passwordTextfield.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password){ user, error in
            if error == nil && user != nil{
                print("hooray! user created!")
                self.navigateToMap()
            } else {
                let errorAlert = UIAlertController.init(title: "Signup Error",
                                                        message: "There was an error with the login. Please try again.",
                                                        preferredStyle: .alert)
                
                errorAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                                                   style: .default,
                                                   handler: { _ in
                                                    NSLog("The \"OK\" alert occured.") }))
                self.present(errorAlert, animated: true, completion: nil)
                print("uh oh.")
            }
        }
        
    }

    func navigateToMap(){
        if let mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController{
            
            if let navigator = navigationController {
                navigator.pushViewController(mapView, animated: true)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if usernameTextfield.isFirstResponder { usernameTextfield.resignFirstResponder() }
        if emailTextfield.isFirstResponder { emailTextfield.resignFirstResponder() }
        if passwordTextfield.isFirstResponder { passwordTextfield.resignFirstResponder() }
    }
}

extension SignupViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextfield:
            usernameTextfield.resignFirstResponder()
            emailTextfield.becomeFirstResponder()
        case emailTextfield:
            emailTextfield.resignFirstResponder()
            passwordTextfield.becomeFirstResponder()
        case passwordTextfield:
            passwordTextfield.resignFirstResponder()
            handleSignup()
        default:
            return true
        }
        return true
    }
}
