//
//  ModelPlaces.swift
//  MyPlaces
//
//  Created by Дмитрий Межевич on 28.09.21.
//

import Foundation


struct Places {
    
    var name: String
    var location: String
    var type: String
    var image : String
    
    static let entertainmentName = [
        "The Box 99", "Европа", "New Time",
        "Немо", "Семь Пятниц", "Старое Время",
        "Мята", "Этаж", "Фасоль"
    ]
    
    static func getPlaces() -> [Places] {
        
        var places: [Places] = []
        
        for place in entertainmentName {
            places.append(Places(name: place, location: "Гомель", type: "Ресторан", image: place))
        }
        
        return places
    }
}
