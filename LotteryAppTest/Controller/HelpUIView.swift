//
//  HelpUIView.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 4/11/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

//Self view size set after construction, can't set in here for some reason
//Also can't use NSLayoutConstraint to set self to parent constraints because moving the frame won't work after
class HelpUIView: UIView {
    var viewNumber: Int!
    var parent: UIView!
    var controller: HelpViewController!
    
    var background: UIImageView!
    var pic: UIImageView!
    var swipeForMore: UILabel!
    var heading: UILabel!
    var instructions: UILabel!
    
    let smallUILabelScalingConstant: CGFloat = 0.0163
    let normalUILabelScalingConstant: CGFloat = 0.015
    let boldUILabelScalingConstant: CGFloat = 0.0231
    var smallUILabelFontSize: CGFloat { return controller.view.frame.size.height * smallUILabelScalingConstant }
    var normalUILabelFontSize: CGFloat { return controller.view.frame.size.height * normalUILabelScalingConstant }
    var boldUILabelFontSIze: CGFloat { return controller.view.frame.size.height * boldUILabelScalingConstant }
    
    var smallUILabelFont: UIFont { return UIFont(name: "Poppins-Medium", size: smallUILabelFontSize)! }
    var normalUILabelFont: UIFont { return UIFont(name: "Poppins-Medium", size: normalUILabelFontSize)! }
    var boldUILableFont: UIFont { return UIFont(name: "Poppins-SemiBold", size: boldUILabelFontSIze)! }
    
    required init(viewNumber: Int, parent: UIView, controller: HelpViewController) {
        self.viewNumber = viewNumber
        self.parent = parent
        self.controller = controller
        
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        setViewChildrenContents()
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 0.4
        
        configureConstraints()
        self.updateConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//Public functions
extension HelpUIView {
    public func callInViewDidLayoutSubviews() {
        if parent.frame.size.height * 0.8 * (341.0 / 502.0) > parent.frame.size.width * 0.9 {
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.9, constant: 0).isActive = true
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 502.0 / 341.0, constant: 0).isActive = true
        } else {
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.height, multiplier: 0.8, constant: 0).isActive = true
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.height, multiplier: 341.0 / 502.0, constant: 0).isActive = true
        }
    }
}

//Private functions
extension HelpUIView {
    private func setViewChildrenContents() {
        background = UIImageView(image: #imageLiteral(resourceName: "HelpContainer"))
        swipeForMore = UILabel(frame: .zero)
        swipeForMore.text = "Swipe for more"
        heading = UILabel(frame: .zero)
        instructions = UILabel(frame: .zero)
        
        switch viewNumber{
        case 0:
            pic = UIImageView(image: #imageLiteral(resourceName: "Help1UnpurchasedState"))
            heading.text = "Select Your State"
            instructions.text = "Pick the state you'd like to view scratch ticket data for"
        case 1:
            pic = UIImageView(image: #imageLiteral(resourceName: "HelpPurchasePopup"))
            heading.text = "Purchase or Try"
            instructions.text = "Purchase your state to view all ticket data, or try for free to view some ticket data (doesn't show the best tickets)"
            
            pic.layer.shadowColor = UIColor.black.cgColor
            pic.layer.shadowOffset = CGSize(width: 0, height: 0)
            pic.layer.shadowRadius = 12
            pic.layer.shadowOpacity = 0.4
        case 2:
            pic = UIImageView(image: #imageLiteral(resourceName: "Help1PurchasedState"))
            heading.text = "Your Purchased State"
            instructions.text = "Select your purchased state to view all data"
        case 3:
            pic = UIImageView(image: #imageLiteral(resourceName: "Help1Row"))
            heading.text = "Ticket Information"
            instructions.text = "Tickets are organized by rank, best tickets in their price point have green colored ranks"
        default:
            print("Unrecognized HelpUIView number")
        }
        
        self.addSubview(background)
        self.addSubview(pic)
        self.addSubview(swipeForMore)
        self.addSubview(heading)
        self.addSubview(instructions)
    }
    private func configureConstraints() {
        background.translatesAutoresizingMaskIntoConstraints = false
        pic.translatesAutoresizingMaskIntoConstraints = false
        swipeForMore.translatesAutoresizingMaskIntoConstraints = false
        heading.translatesAutoresizingMaskIntoConstraints = false
        instructions.translatesAutoresizingMaskIntoConstraints = false
        
        swipeForMore.font = smallUILabelFont
        swipeForMore.textAlignment = .center
        swipeForMore.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        heading.font = boldUILableFont
        heading.textAlignment = .center
        heading.textColor = UIColor(red: 251.0 / 255.0, green: 103.0 / 255.0, blue: 83.0 / 255.0, alpha: 1)

        instructions.font = normalUILabelFont
        instructions.textAlignment = .center
        instructions.numberOfLines = 0
        instructions.textColor = UIColor(red: 52.0 / 255.0, green: 52.0 / 255.0, blue: 52.0 / 255.0, alpha: 1)
        
        //Self constraints
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 0.9, constant: 0).isActive = true
        
        //Background image constraints
        NSLayoutConstraint(item: background, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: background, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 0.9, constant: 0).isActive = true
        NSLayoutConstraint(item: background, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: background, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0).isActive = true
        
        //Picture constraints
        NSLayoutConstraint(item: pic, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: pic, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 0.7, constant: 0).isActive = true
        switch viewNumber {
        case 0:
            NSLayoutConstraint(item: pic, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: pic, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: pic, attribute: NSLayoutConstraint.Attribute.width, multiplier: 420.0 / 523.0, constant: 0).isActive = true
        case 1:
            NSLayoutConstraint(item: pic, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.8, constant: 0).isActive = true
            NSLayoutConstraint(item: pic, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: pic, attribute: NSLayoutConstraint.Attribute.width, multiplier: 702.0 / 659.0, constant: 0).isActive = true
        case 2:
            NSLayoutConstraint(item: pic, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: pic, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: pic, attribute: NSLayoutConstraint.Attribute.width, multiplier: 191.0 / 250.0, constant: 0).isActive = true
        case 3:
            NSLayoutConstraint(item: pic, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.9, constant: 0).isActive = true
            NSLayoutConstraint(item: pic, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: pic, attribute: NSLayoutConstraint.Attribute.width, multiplier: 335.0 / 459.0, constant: 0).isActive = true
        default:
            print("Unrecognized HelpUIView number")
        }
        
        //Swipe for more constraints
        NSLayoutConstraint(item: swipeForMore, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: swipeForMore, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.42, constant: 0).isActive = true
        
        //Heading constraints
        NSLayoutConstraint(item: heading, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: heading, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.6, constant: 0).isActive = true
        
        //Instructions constraints
        NSLayoutConstraint(item: instructions, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: instructions, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.8, constant: 0).isActive = true
        NSLayoutConstraint(item: instructions, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.9, constant: 0).isActive = true
        
        self.bringSubviewToFront(background)
        self.bringSubviewToFront(pic)
        self.bringSubviewToFront(swipeForMore)
        self.bringSubviewToFront(heading)
        self.bringSubviewToFront(instructions)
    }
}
