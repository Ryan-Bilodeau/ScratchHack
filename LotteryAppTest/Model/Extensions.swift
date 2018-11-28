//
//  Extensions.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/31/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    // This function was taken from GitHub here:
    // https://gist.github.com/leilee/a3c157b125916e0205405a0b543f090a
    static func changeMultiplier(_ constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: constraint.firstItem!,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: constraint.secondItem!,
            attribute: constraint.secondAttribute,
            multiplier: multiplier,
            constant: constraint.constant)
        
        newConstraint.priority = constraint.priority
        
        NSLayoutConstraint.deactivate([constraint])
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
}

extension UIButton {
    // This function was taken from Stack Overflow here:
    // https://stackoverflow.com/questions/16801948/fade-between-two-uibutton-images/39966233
    func changeImageAnimated(image: UIImage?, withDuration: CFTimeInterval) {
        guard let imageView = self.imageView, let currentImage = imageView.image, let newImage = image else {
            return
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.setImage(newImage, for: [])
        }
        let crossFade: CABasicAnimation = CABasicAnimation(keyPath: "contents")
        crossFade.duration = withDuration
        crossFade.fromValue = currentImage.cgImage
        crossFade.toValue = newImage.cgImage
        crossFade.isRemovedOnCompletion = false
        crossFade.fillMode = CAMediaTimingFillMode.forwards
        imageView.layer.add(crossFade, forKey: "animateContents")
        CATransaction.commit()
    }
}
