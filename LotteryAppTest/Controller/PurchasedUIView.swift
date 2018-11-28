//
//  PurchasedUIView.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/25/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

class PurchasedUIView: UIView {
    var parent: UIView!
    var state: USAState!
    var button: PurchasedUIButton!
    var controller: StateViewController!
    var purchasedViews: [PurchasedUIView]!
    
    var abbreviationLabel: UILabel!
    var nameLabel: UILabel!
    var timeRemainingLabel: UILabel!
    
    var abbreviationFontSize: CGFloat {
        return controller.view.frame.size.width * abbreviationScalingConstant
    }
    var nameFontSize: CGFloat {
        return controller.view.frame.size.width * nameScalingConstant
    }
    var timeFontSize: CGFloat {
        return controller.view.frame.size.width * timeRemainingConstant
    }
    let abbreviationScalingConstant: CGFloat = 0.039
    let nameScalingConstant: CGFloat = 0.037
    let timeRemainingConstant: CGFloat = 0.035
    
    let labelFont: UIFont = UIFont(name: "Poppins-Medium", size: 20)!
    
    required init(state: USAState, parent: UIView, controller: StateViewController, purchasedViews: [PurchasedUIView]) {
        self.parent = parent
        self.state = state
        self.controller = controller
        self.purchasedViews = purchasedViews
        
        super.init(frame: .zero)
        self.button = PurchasedUIButton(parent: self)
        self.abbreviationLabel = UILabel()
        self.abbreviationLabel.font = labelFont
        self.nameLabel = UILabel()
        self.nameLabel.font = labelFont
        self.timeRemainingLabel = UILabel()
        self.timeRemainingLabel.font = labelFont
        
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 0.4
        
        self.addSubview(button)
        self.addSubview(abbreviationLabel)
        self.addSubview(nameLabel)
        self.addSubview(timeRemainingLabel)
        setAllViews(parent: parent, purchasedViews: purchasedViews)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//Public functions
extension PurchasedUIView {
    public func callInViewWillLayoutSubviews() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = controller.view.frame.size.width * 0.9 * 0.03220611916
        self.layer.shadowOpacity = 0.4
    }
}

//Private functions
extension PurchasedUIView {
    private func setAllViews(parent: UIView, purchasedViews: [PurchasedUIView]) {
        setLabels(parent: self)
        setViewConstraints(parent: parent)
    }
    private func setViewConstraints(parent: UIView) {
        let useTopConstraint = purchasedViews.count > 0 ? false : true
        let relatedTo = purchasedViews.count < 1 ? parent : purchasedViews[purchasedViews.count - 1]
        
        if useTopConstraint {
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: relatedTo, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        } else {
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: relatedTo, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: controller.view.frame.width * 0.9 * 0.05).isActive = true
        }
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.height, multiplier: 679.0 / 93.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 93.0 / 679.0, constant: 0).isActive = true
    }
    private func setLabels(parent: PurchasedUIView) {
        abbreviationLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        timeRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        let abbreviationFont = UIFont(name: abbreviationLabel.font.fontName, size: abbreviationFontSize)
        let nameFont = UIFont(name: nameLabel.font.fontName, size: nameFontSize)
        let timeFont = UIFont(name: timeRemainingLabel.font.fontName, size: timeFontSize)
        
        abbreviationLabel.font = abbreviationFont
        abbreviationLabel.text = state.abbreviation
        abbreviationLabel.textAlignment = .center
        abbreviationLabel.textColor = UIColor(red: 255.0 / 255.0, green: 251.0 / 255.0, blue: 234.0 / 255.0, alpha: 1)
        nameLabel.font = nameFont
        nameLabel.text = state.name
        nameLabel.textAlignment = .left
        nameLabel.textColor = UIColor(red: 253.0 / 255.0, green: 213.0 / 255.0, blue: 90.0 / 255.0, alpha: 1)
        timeRemainingLabel.font = timeFont
        
        if Calendar.current.dateComponents([.day], from: Date(), to: state.expirationDate!).day! < 2 {
            timeRemainingLabel.text = "1 day left"
        } else {
            timeRemainingLabel.text = String(describing: Calendar.current.dateComponents([.day], from: Date(), to: state.expirationDate!).day!) + " days left"
        }
        timeRemainingLabel.textAlignment = .left
        timeRemainingLabel.textColor = UIColor(red: 255.0 / 255.0, green: 251.0 / 255.0, blue: 234.0 / 255.0, alpha: 1)
        
        NSLayoutConstraint(item: abbreviationLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 0.97, constant: 0).isActive = true
        NSLayoutConstraint(item: abbreviationLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 0.17, constant: 0).isActive = true
        
        NSLayoutConstraint(item: nameLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.08, constant: 0).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 0.16, constant: 0).isActive = true
        
        NSLayoutConstraint(item: timeRemainingLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.05, constant: 0).isActive = true
        NSLayoutConstraint(item: timeRemainingLabel, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 0.735, constant: 0).isActive = true
        
        parent.bringSubviewToFront(abbreviationLabel)
        parent.bringSubviewToFront(nameLabel)
        parent.bringSubviewToFront(timeRemainingLabel)
    }
}





