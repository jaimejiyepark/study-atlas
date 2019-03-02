//
//  UserUpdateFormViewController.swift
//  StudyAtlas
//
//  Created by Jaime Park on 11/18/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import UIKit
import Foundation

class UserUpdateFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var busySlider: UISlider!
    @IBOutlet weak var sitePicker: UIPickerView!
    @IBOutlet weak var floorTextfield: UITextField!
    @IBOutlet weak var roomTextfield: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var sitePickerData : [String] = []
    var selectedSite : String?
    
    @IBAction func submitUpdate(_ sender: Any) {
        //no site name input
        selectedSite = sitePickerData[self.sitePicker.selectedRow(inComponent: 0)]
        if let siteName = selectedSite {
            let update = UserUpdateForm(site: siteName, floor: Int(floorTextfield.text ?? "1"), room: roomTextfield.text, busyness: Int(ceil(busySlider.value)))
            update.parseToJson()
            print("submitted the update data")
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
            return
        }

        let alert = UIAlertController(title: "Alert", message: "Please input a site name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.makeRoundButton()
        sitePicker.delegate = self
        sitePicker.dataSource = self
        self.submitButton.layer.borderColor = UIColor.white.cgColor
        self.submitButton.layer.borderWidth = 2.0
        self.submitButton.layer.cornerRadius = 9.0
        self.submitButton.layer.masksToBounds = true
        Api.getCollection("places") {(sites, error) in
            guard let sites = sites else {
                print("network error")
                return
            }
            dump(sites)
            for dict in sites {
                self.sitePickerData.append(dict["name"] as! String)
            }
            
            self.sitePicker.reloadAllComponents()
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sitePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSite = sitePickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sitePickerData[row]
    }
    
    
}
