//
//  UITextfieldExtentions.swift
//  StudyAtlas
//
//  Created by Jaime Park on 11/19/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import UIKit
import Foundation

extension UIButton {
    /**
     Makes UIButtons round and optional with a colored border
     */
    func makeRoundButton(){
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    
    func makeRoundButton(_ borderColor: CGColor?){
        let color = borderColor ?? UIColor.white.cgColor
        self.layer.borderColor = color
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
}
