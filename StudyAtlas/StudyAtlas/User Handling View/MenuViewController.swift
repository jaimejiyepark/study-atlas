//
//  InitialViewController.swift
//  StudyAtlas
//
//  Created by Jaime Park on 11/20/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import UIKit
import FirebaseAuth

class MenuViewController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupButton.makeRoundButton()
        loginButton.makeRoundButton()

    }
    
    /**
     Implement autologin
     */
    @IBAction func loginButtonClicked(_ sender: Any) {
        if let _ = Auth.auth().currentUser {
            let mapVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            self.navigationController?.popToViewController(mapVC, animated: true)
        } else {
            let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.popToViewController(loginVC, animated: true)
        }
    }
    
    /**
     Do not remove - needed for logout!!!
     */
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
}
