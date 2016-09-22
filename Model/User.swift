//
//  User.swift
//  ChatDemo
//
//  Created by Khuong Luu on 9/20/16.
//  Copyright © 2016 Khuong Luu. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}