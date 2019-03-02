//
//  SideMenuViewController.swift
//  StudyAtlas
//
//  Created by Jaime Park on 12/3/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import UIKit
import SideMenu
import FirebaseAuth

class SideMenuViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        logoutButton.makeRoundButton(UIColor(red:0.60, green:0.60, blue:0.60, alpha:1.0).cgColor)
    }
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func logoutButtonClicked(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "unwindToMenu", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func menuButton(_ sender: Any) {
        let mapVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func allSiteViewButton(_ sender: Any) {
        let allSiteViewVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "allSitesViewController") as! AllSitesViewController
        self.navigationController?.pushViewController(allSiteViewVC, animated: true)
    }
    
    @IBAction func updateButton(_ sender: Any) {
        let updateVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserUpdateFormViewController") as! UserUpdateFormViewController
        self.navigationController?.pushViewController(updateVC, animated: true)
    }

}
