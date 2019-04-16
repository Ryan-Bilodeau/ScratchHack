//
//  StateUIButton.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/16/19.
//  Copyright © 2019 Ryan Bilodeau. All rights reserved.
//

import UIKit

class StateUIButton: UIButton {
    public var stateName: String
    public var topUIView = UIView(frame: .zero)
    
    private var abbreviation: String
    
    private let parentCell: StateCollectionViewCell
    private let delegate: StateUIButtonDelegate
    private let nameUILabel = UILabel(frame: .zero)
    private let abbreviationUILabel = UILabel(frame: .zero)
    
    init(frame: CGRect, name: String, abbreviation: String, parentCell: StateCollectionViewCell, delegate: StateUIButtonDelegate) {
        self.stateName = name
        self.abbreviation = abbreviation
        self.parentCell = parentCell
        self.delegate = delegate
        super.init(frame: frame)
        
        self.addTarget(self, action: #selector(buttonDown(sender:)), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonUp(sender:)), for: [.touchUpOutside, .touchCancel])
        
        self.setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Public functions
extension StateUIButton {
    public func setButtonForState(name: String, abbreviation: String) {
        self.stateName = name
        self.abbreviation = abbreviation
        nameUILabel.text = name
        abbreviationUILabel.text = abbreviation
    }
}

// Private functions
extension StateUIButton {
    private func setUpLayout() {
        let shadowRadius: CGFloat = 8
        parentCell.addSubview(self)
        backgroundColor = UIColor(red: 251 / 255, green: 103 / 255, blue: 83 / 255, alpha: 1)
        layer.cornerRadius = 6
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = CGSize.zero
        layer.masksToBounds = false
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentCell.topAnchor, constant: 14),
            bottomAnchor.constraint(equalTo: parentCell.bottomAnchor, constant: -14),
            leadingAnchor.constraint(equalTo: parentCell.leadingAnchor, constant: shadowRadius*2),
            trailingAnchor.constraint(equalTo: parentCell.trailingAnchor, constant: -(shadowRadius*2)),
            centerXAnchor.constraint(equalTo: parentCell.centerXAnchor),
            centerYAnchor.constraint(equalTo: parentCell.centerYAnchor)
        ])
        
        let center = UIView(frame: .zero)
        self.addSubview(center)
        center.backgroundColor = .clear
        center.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            center.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            center.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        self.addSubview(nameUILabel)
        nameUILabel.text = stateName
        nameUILabel.numberOfLines = 0
        nameUILabel.textColor = UIColor(red: 253 / 255, green: 213 / 255, blue: 90 / 255, alpha: 1)
        nameUILabel.textAlignment = .center
        nameUILabel.font = UIFont(name: "Poppins-Medium", size: 16)
        
        nameUILabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameUILabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            nameUILabel.topAnchor.constraint(equalTo: center.bottomAnchor, constant: 12)
        ])
        
        let circleUIView = UIView(frame: .zero)
        self.addSubview(circleUIView)
        circleUIView.backgroundColor = UIColor(red: 255 / 255, green: 83 / 255, blue: 24 / 255, alpha: 1)
        circleUIView.layer.cornerRadius = 20
        circleUIView.layer.shadowOpacity = 0.5
        circleUIView.layer.shadowRadius = 3
        circleUIView.layer.shadowOffset = CGSize(width: 0, height: 5)
        circleUIView.layer.masksToBounds = false
        circleUIView.isUserInteractionEnabled = false
        
        circleUIView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            circleUIView.heightAnchor.constraint(equalToConstant: 40),
            circleUIView.widthAnchor.constraint(equalToConstant: 40),
            circleUIView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circleUIView.bottomAnchor.constraint(equalTo: center.topAnchor, constant: 0)
        ])
        
        circleUIView.addSubview(abbreviationUILabel)
        abbreviationUILabel.text = abbreviation
        abbreviationUILabel.numberOfLines = 0
        abbreviationUILabel.textColor = .white
        abbreviationUILabel.textAlignment = .center
        abbreviationUILabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        
        abbreviationUILabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            abbreviationUILabel.centerXAnchor.constraint(equalTo: circleUIView.centerXAnchor),
            abbreviationUILabel.centerYAnchor.constraint(equalTo: circleUIView.centerYAnchor)
        ])
        
        self.addSubview(topUIView)
        topUIView.backgroundColor = .black
        topUIView.alpha = 0.3
        topUIView.layer.cornerRadius = self.layer.cornerRadius
        
        topUIView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topUIView.topAnchor.constraint(equalTo: self.topAnchor),
            topUIView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            topUIView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topUIView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        self.bringSubviewToFront(topUIView)
        topUIView.isHidden = true
    }
}

// Actions
extension StateUIButton {
    @objc func buttonDown(sender: StateUIButton) {
        delegate.buttonDown(sender: sender)
    }
    @objc func buttonTouchUpInside(sender: StateUIButton) {
        delegate.buttonTouchUpInside(sender: sender)
    }
    @objc func buttonUp(sender: StateUIButton) {
        delegate.buttonUp(sender: sender)
    }
}
