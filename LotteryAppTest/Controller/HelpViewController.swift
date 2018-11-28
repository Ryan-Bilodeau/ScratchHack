//
//  HelpViewController.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 4/10/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    @IBOutlet weak var mainUIView: UIView!
    @IBOutlet weak var helpGestureUIView: UIView!
    @IBOutlet weak var topBlankUIView: UIView!
    
    var helpUIViews = [HelpUIView]()
    var firstHelpView = 0
    var helpViewWidth: CGFloat = 0
    var helpViewHeight: CGFloat = 0
    
    //Only used to store data from the state view controller
    var unownedStates: [USAState]!
    var ownedStates: [USAState]!
    
    @IBAction func backButtonClicked() {
        goBack()
    }
    @IBAction func swipeRight(_ sender: Any) {
        goBack()
    }
    @IBAction func helpRightSwipe(_ sender: UISwipeGestureRecognizer) {
        swipeRight()
    }
    @IBAction func helpLeftSwipe(_ sender: UISwipeGestureRecognizer) {
        swipeLeft()
    }
}

//Overridden stuff
extension HelpViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainUIView.translatesAutoresizingMaskIntoConstraints = false
        
        helpUIViews.append(HelpUIView(viewNumber: 0, parent: mainUIView, controller: self))
        helpUIViews.append(HelpUIView(viewNumber: 1, parent: mainUIView, controller: self))
        helpUIViews.append(HelpUIView(viewNumber: 2, parent: mainUIView, controller: self))
        helpUIViews.append(HelpUIView(viewNumber: 3, parent: mainUIView, controller: self))

        helpUIViews.sort { return $0.viewNumber < $1.viewNumber }

        mainUIView.bringSubviewToFront(helpUIViews[3])
        mainUIView.bringSubviewToFront(helpUIViews[2])
        mainUIView.bringSubviewToFront(helpUIViews[1])
        mainUIView.bringSubviewToFront(helpUIViews[0])

        helpUIViews[1].alpha = 0.5
        helpUIViews[2].alpha = 0.5
        helpUIViews[3].alpha = 0

        topBlankUIView.isHidden = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in helpUIViews {
            view.callInViewDidLayoutSubviews()
        }
        
        helpUIViews[1].transform = CGAffineTransform(translationX: 0, y: mainUIView.frame.size.height * 0.07).scaledBy(x: 0.9, y: 0.9)
        helpUIViews[2].transform = CGAffineTransform(translationX: 0, y: mainUIView.frame.size.height * 0.14).scaledBy(x: 0.8, y: 0.8)
        helpUIViews[3].transform = CGAffineTransform(translationX: 0, y: mainUIView.frame.size.height * 0.14).scaledBy(x: 0.8, y: 0.8)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        helpGestureUIView.frame = helpUIViews[0].frame
        helpGestureUIView.center = mainUIView.center
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "goBackToStatesView" else { return }
        if let statesView = segue.destination as? StateViewController {
            statesView.ownedStates = ownedStates
            statesView.unownedStates = unownedStates
        }
    }
}

//Private functions
extension HelpViewController {
    private func goBack() {
        performSegue(withIdentifier: "goBackToStatesView", sender: nil)
    }
    //Backward
    private func swipeLeft() {
        topBlankUIView.isHidden = false
        
        let arraySize = helpUIViews.count
        var secondHelpView = 0
        var thirdHelpView = 0
        var fourthHelpView = 0

        if firstHelpView + 1 < arraySize {
            secondHelpView = firstHelpView + 1
        } else {
            secondHelpView = 0
        }
        if secondHelpView + 1 < arraySize {
            thirdHelpView = secondHelpView + 1
        } else {
            thirdHelpView = 0
        }
        if thirdHelpView + 1 < arraySize {
            fourthHelpView = thirdHelpView + 1
        } else {
            fourthHelpView = 0
        }
        
        self.mainUIView.bringSubviewToFront(self.helpUIViews[fourthHelpView])
        self.helpUIViews[fourthHelpView].transform = CGAffineTransform(translationX: mainUIView.frame.size.width, y: 0).scaledBy(x: 0.8, y: 0.8)

        //Top view animations
        UIView.animate(withDuration: 0.35) {
            self.helpUIViews[self.firstHelpView].transform = CGAffineTransform(translationX: 0, y: self.mainUIView.frame.size.height * 0.07).scaledBy(x: 0.9, y: 0.9)
            
            self.helpUIViews[self.firstHelpView].alpha = 0.5
        }
        //Middle view animations
        UIView.animate(withDuration: 0.35) {
            self.helpUIViews[secondHelpView].transform = CGAffineTransform(translationX: 0, y: self.mainUIView.frame.size.height * 0.14).scaledBy(x: 0.8, y: 0.8)
        }
        //Bottom view animations
        UIView.animate(withDuration: 0.35) {
            self.helpUIViews[thirdHelpView].alpha = 0
        }
        //Last view animations
        UIView.animate(withDuration: 0.35, animations: {
            self.helpUIViews[fourthHelpView].transform = CGAffineTransform.identity
            self.helpUIViews[fourthHelpView].alpha = 1
        }) { (true) in
            self.firstHelpView = fourthHelpView
            self.topBlankUIView.isHidden = true
        }
    }
    //Forward
    private func swipeRight() {
        topBlankUIView.isHidden = false

        let arraySize = helpUIViews.count
        var secondHelpView = 0
        var thirdHelpView = 0
        var fourthHelpView = 0

        if firstHelpView + 1 < arraySize {
            secondHelpView = firstHelpView + 1
        } else {
            secondHelpView = 0
        }
        if secondHelpView + 1 < arraySize {
            thirdHelpView = secondHelpView + 1
        } else {
            thirdHelpView = 0
        }
        if thirdHelpView + 1 < arraySize {
            fourthHelpView = thirdHelpView + 1
        } else {
            fourthHelpView = 0
        }

//        Top view animations
        UIView.animate(withDuration: 0.35, animations: {
            self.helpUIViews[self.firstHelpView].transform = CGAffineTransform(translationX: self.mainUIView.frame.size.width, y: 0).scaledBy(x: 0.8, y: 0.8)
            self.helpUIViews[self.firstHelpView].alpha = 0
        }) { (true) in
            self.helpUIViews[self.firstHelpView].transform = CGAffineTransform(translationX: -(self.mainUIView.frame.size.width / 2), y: 0)
            self.helpUIViews[self.firstHelpView].transform = CGAffineTransform(translationX: 0, y: self.mainUIView.frame.size.height * 0.14).scaledBy(x: 0.8, y: 0.8)

            self.mainUIView.sendSubviewToBack(self.helpUIViews[self.firstHelpView])
            self.firstHelpView = secondHelpView
            self.topBlankUIView.isHidden = true
        }
        //Middle view animations
        UIView.animate(withDuration: 0.35) {
            self.helpUIViews[secondHelpView].transform = CGAffineTransform.identity
            self.helpUIViews[secondHelpView].alpha = 1
        }
        //Bottom view animations
        UIView.animate(withDuration: 0.35) {
            self.helpUIViews[thirdHelpView].transform = CGAffineTransform(translationX: 0, y: self.mainUIView.frame.size.height * 0.07).scaledBy(x: 0.9, y: 0.9)
        }
        //Last view animations
        UIView.animate(withDuration: 0.35) {
            self.helpUIViews[fourthHelpView].alpha = 0.5
        }
    }
}




