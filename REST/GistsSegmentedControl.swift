//
//  GistsSegmentedControl.swift
//  REST
//
//  Created by Artem Sherbachuk (UKRAINE) on 11/6/16.
//  Copyright © 2016 ArtemSherbachuk. All rights reserved.
//

import UIKit

class GistsSegmentedControl: UISegmentedControl {

    func isPublicGistsSelected() -> Bool {
        return self.selectedSegmentIndex == 0
    }
    func isPrivateGistsSelected() -> Bool {
        return self.selectedSegmentIndex == 1 || self.selectedSegmentIndex == 2
    }

    func animateSegment() {
        if let segments = self.value(forKey: "_segments") as? NSArray,
            let segment = segments.object(at: self.selectedSegmentIndex) as? UIView {
            segment.transform = CGAffineTransform(scaleX: 0.1, y: 1)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.7, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                segment.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
}
