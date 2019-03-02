//
//  UserUpdateForm.swift
//  StudyAtlas
//
//  Created by Jaime Park on 11/18/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import Foundation

class UserUpdateForm {
    var site : String
    var floor : Int?
    var room : String?
    var busyness : Int
    
    init(){
        site = ""
        floor = -1
        room = ""
        busyness = 5
    }
    
    init(site: String, floor: Int?, room: String?, busyness : Int){
        self.site = site
        self.floor = floor
        self.room = room
        self.busyness = busyness
    }
    
    func parseToJson(){
        var data : [String : Any] = [:]
        
        data["site"] = site
        data["floor"] = floor ?? 1
        data["room"] = room ?? ""
        data["busyness"] = busyness
        //creates a timestamp that will be stored as int
        //use to sort updates
        
        Api.userPost(data)
    }
}
