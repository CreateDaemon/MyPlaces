//
//  ModelPlaces.swift
//  MyPlaces
//
//  Created by Дмитрий Межевич on 28.09.21.
//

import RealmSwift

class Places: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData : Data?
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?) {
        
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }
    
}
