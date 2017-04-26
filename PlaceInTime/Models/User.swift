//
//  User.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import Foundation
import Firebase

// FIRUser
struct User {
    var id: String
    var email: String
    var password: String?

    init(authData: FIRUser) {
        id = authData.uid
        email = authData.email!
    }

    init(uid: String, email: String) {
        self.id = uid
        self.email = email
    }
}

// additional info not included in FIRUser
struct UserInfo {
    var authUser: User
    var key: String?
    var username: String?
    var name: String?
    var ref: FIRDatabaseReference?

    init(snapshot: FIRDataSnapshot, user: User) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as? String
        username = snapshotValue["username"] as? String
        ref = snapshot.ref
        authUser = user
    }

    init(authUser: User, name: String, username: String) {
        self.authUser = authUser
        self.name = name
        self.username = username
    }
}

extension UserInfo: FirebaseModel {

    func toAnyObject() -> Any {
        return [
            "username": username ?? "",
            "name": name ?? "",
            "email": authUser.email
        ]
    }
}
