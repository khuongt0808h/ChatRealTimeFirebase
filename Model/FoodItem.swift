//
//  FoodItem.swift
//  ChatDemo
//
//  Created by Khuong Luu on 9/20/16.
//  Copyright © 2016 Khuong Luu. All rights reserved.
//

import Foundation

struct FoodItem {
    
    let key: String
    let name: String
    let addedByUser: String
    let ref: FIRDatabaseReference?
    var completed: Bool
    
    init(name: String, addedByUser: String, completed: Bool, key: String = "")
    {
                self.key = key
                self.name = name
                self.addedByUser = addedByUser
                self.completed = completed
                self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        name = snapshot.value!["name"] as! String
        addedByUser = snapshot.value!["addedByUser"] as! String
        completed = snapshot.value!["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
            "addedByUser": addedByUser,
            "completed": completed
        ]
    }
}