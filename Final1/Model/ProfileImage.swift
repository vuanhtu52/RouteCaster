//
//  ProfileImage.swift
//  Final1
//
//  Created by Misaa Pandaaa on 4/23/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ProfileImage {
    var image: UIImage
    var downloadURL: URL?
    var downloadURLString: String!
    var ref: StorageReference!
    
    init(image: UIImage) {
        self.image = image
    }
    
    
}
extension UIImage {
    func resize() -> UIImage {
        let height: CGFloat = 1000.0
        let ratio = self.size.width / self.size.height
        let width = height * ratio
        
        let newSize = CGSize(width: width, height: height)
        let newRectangle = CGRect(x: 0, y: 0, width: width, height: height)
        
        // context - canvas
        UIGraphicsBeginImageContext(newSize)
        
        // draw the newly sized image on the canvas
        self.draw(in: newRectangle)
        
        // get the new size image into a new variable
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // close the canvas
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
}
