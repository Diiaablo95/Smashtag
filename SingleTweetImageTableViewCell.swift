//
//  SingleTweetTableViewCell.swift
//  Smashtag
//
//  Created by Diablo on 15/12/15.
//  Copyright © 2015 Diablo. All rights reserved.
//

import UIKit

class SingleTweetImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var image_view: UIImageView!
    
    var elementToDisplay: (image: UIImage?, ratio: Double?)? {
        didSet {
            if image_view != nil && elementToDisplay != nil {
                if elementToDisplay?.image != nil {
                    image_view.image = elementToDisplay!.image
                    if let ratio = elementToDisplay!.ratio {
                        let ratioAnchor = image_view.widthAnchor.constraintEqualToAnchor(image_view.heightAnchor, multiplier: CGFloat(ratio), constant: 0)
                        NSLayoutConstraint.activateConstraints([ratioAnchor])
                    }
                }
            }
        }
    }
}