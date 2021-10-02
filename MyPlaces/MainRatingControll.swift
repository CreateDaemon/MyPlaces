//
//  mainRatingControll.swift
//  MyPlaces
//
//  Created by Дмитрий Межевич on 2.10.21.
//

import UIKit

@IBDesignable class MainRatingControll: UIStackView {

    private var arrayImage = [UIImageView]()
    
    var rating = 0 {
        didSet {
            setImageForLabel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImages()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setImages()
    }
    
    private func setImages() {
        
        // Create labels for rating
        for _ in 1...5 {

            let ratingImage = UIImageView()
            
            // Set size label
            ratingImage.translatesAutoresizingMaskIntoConstraints = false
            ratingImage.widthAnchor.constraint(equalToConstant: 15).isActive = true
            ratingImage.heightAnchor.constraint(equalToConstant: 15).isActive = true
            
            addArrangedSubview(ratingImage)
            
            arrayImage.append(ratingImage)
        }
    }
    
    private func setImageForLabel() {
        
        for index in 0..<5 {
            if index <= rating - 1 {
                arrayImage[index].image = UIImage(named: "filledStar")
            } else {
                arrayImage[index].image = UIImage(named: "emptyStar")
            }
        }
    }

}
