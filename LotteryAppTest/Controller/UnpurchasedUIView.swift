//
//  UnpurchasedUIView.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/25/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

class UnpurchasedUIView: UIView {
    var parent: UIView!
    var state: USAState!
    var button: UnpurchasedUIButton!
    var controller: StateViewController!
    var unpurchasedViews: [UnpurchasedUIView]!
    
    var abbreviationLabel: UILabel!
    var nameLabel: UILabel!
    
    var abbreviationFontSize: CGFloat {
        return controller.view.frame.size.height * abbreviationScalingConstant
    }
    var nameFontSize: CGFloat {
        return controller.view.frame.size.height * nameScalingConstant
    }
    let abbreviationScalingConstant: CGFloat = 0.0245
    let nameScalingConstant: CGFloat = 0.021
    
    let labelFont: UIFont = UIFont(name: "Poppins-Medium", size: 20)!
    
    required init(state: USAState, parent: UIView, controller: StateViewController, unpurchasedViews: [UnpurchasedUIView]) {
        self.parent = parent
        self.state = state
        self.controller = controller
        self.unpurchasedViews = unpurchasedViews
        
        super.init(frame: .zero)
        self.button = UnpurchasedUIButton(parent: self)
        self.abbreviationLabel = UILabel(frame: .zero)
        self.abbreviationLabel.font = labelFont
        self.nameLabel = UILabel(frame: .zero)
        self.nameLabel.font = labelFont
        
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        
        self.addSubview(button)
        self.addSubview(abbreviationLabel)
        self.addSubview(nameLabel)
        setAllViews(parent: parent, unpurchasedViews: unpurchasedViews)
        self.updateConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//Public functions
extension UnpurchasedUIView {
    public func callInViewWillLayoutSubviews() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = controller.view.frame.size.width * 0.9 * 0.03220611916
        self.layer.shadowOpacity = 0.4
    }
}

//Private functions
extension UnpurchasedUIView {
    private func setAllViews(parent: UIView, unpurchasedViews: [UnpurchasedUIView]) {
        setLabels(parent: self)
        arrangeView(parent: parent, unpurchasedViews: unpurchasedViews)
    }
    private func arrangeView(parent: UIView, unpurchasedViews: [UnpurchasedUIView]) {
        var position: CellPosition!
        
        if unpurchasedViews.count % 3 == 0 {
            position = CellPosition.left
        } else if (unpurchasedViews.count + 2) % 3 == 0 {
            position = CellPosition.middle
        } else {
            position = CellPosition.right
        }
        let useTopConstraint = unpurchasedViews.count > 2 ? false : true
        let relativeWidth = controller.view.frame.size.width * 0.9
        
        if useTopConstraint {
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: controller.view.frame.size.width * 0.9 * 0.05367686527).isActive = true
        } else {
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: unpurchasedViews[unpurchasedViews.count - 3], attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: relativeWidth * 0.07).isActive = true
        }
        
        switch position! {
        case .left:
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: controller.unpurchasedStatesUIButton, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0).isActive = true
        case .middle:
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        case .right:
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: controller.purchasedStatesUIButton, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        }
        
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.31 * 0.9, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 75.0 / 106.0, constant: 0).isActive = true
    }
    private func setLabels(parent: UnpurchasedUIView) {
        abbreviationLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let abbreviationFont = UIFont(name: abbreviationLabel.font.fontName, size: abbreviationFontSize)
        let nameFont = UIFont(name: nameLabel.font.fontName, size: nameFontSize)
        
        abbreviationLabel.font = abbreviationFont
        abbreviationLabel.text = state.abbreviation
        abbreviationLabel.textAlignment = .center
        abbreviationLabel.textColor = UIColor(red: 255.0 / 255.0, green: 251.0 / 255.0, blue: 234.0 / 255.0, alpha: 1)
        nameLabel.font = nameFont
        nameLabel.text = state.name
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor(red: 253.0 / 255.0, green: 213.0 / 255.0, blue: 90.0 / 255.0, alpha: 1)
        
        NSLayoutConstraint(item: abbreviationLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 0.68, constant: 0).isActive = true
        NSLayoutConstraint(item: abbreviationLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: nameLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.65, constant: 0).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        
        parent.bringSubviewToFront(abbreviationLabel)
        parent.bringSubviewToFront(nameLabel)
    }
    
    enum CellPosition {
        case left
        case middle
        case right
    }
}







