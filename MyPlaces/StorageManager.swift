//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Дмитрий Межевич on 30.09.21.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Places) {
        
        try! realm.write{
            realm.add(place)
        }
    }
}
