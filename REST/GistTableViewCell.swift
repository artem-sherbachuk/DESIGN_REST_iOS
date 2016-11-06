//
//  GistTableViewCell.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 11/2/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import UIKit
import PINRemoteImage

@IBDesignable
final class GistTableViewCell: UITableViewCell {
    
    override func prepareForInterfaceBuilder() {
        addDesign()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addDesign()
    }
    
    private func addDesign() {
        let separatorLayer = CALayer()
        separatorLayer.backgroundColor = UIColor.darkGray.cgColor
        separatorLayer.frame = CGRect(x: 0, y: self.bounds.height-3, width: UIScreen.main.bounds.width, height: 3)
        self.layer.addSublayer(separatorLayer)
        
        let verticalLeftLineLayer = CALayer()
        verticalLeftLineLayer.backgroundColor = UIColor.blue.withAlphaComponent(0.3).cgColor
        verticalLeftLineLayer.frame = CGRect(x: 0, y: 0, width: 8, height: self.bounds.height)
        self.layer.addSublayer(verticalLeftLineLayer)
    }
    
    var gist: Gist! {
        didSet {
            self.textLabel?.text = gist.description
            self.detailTextLabel?.text = gist.ownerLogin
            
            let placeholderImg = UIImage(named: "placeholder")
            if let avatar = gist.ownerAvatar {
                let imgURL = URL(string: avatar)
                self.imageView?.pin_setImage(from: imgURL, placeholderImage: placeholderImg)
            } else {
                self.imageView?.image = placeholderImg
            }
        }
    }
}
