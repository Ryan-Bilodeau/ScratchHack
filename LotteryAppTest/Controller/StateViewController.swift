//
//  StateViewController.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/9/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit
import MessageUI

class StateViewController: UIViewController {
    @IBOutlet weak var loadingCirclesContainerUIView: UIView!
    @IBOutlet var loadingCirclesUIImage: [UIImageView]!
    @IBOutlet weak var topBlankUIView: UIView!
    @IBOutlet weak var mainUIView: UIView!
    
    @IBOutlet weak var purchasedStatesContainerUIView: UIView!
    @IBOutlet weak var purchaseAStateUILabel: UILabel!
    
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var unpurchasedStateClickedUIView: UIView!
    @IBOutlet weak var unpurchasedStateClickedUILabel: UILabel!
    @IBOutlet weak var unpurchasedStateClickedUILabel1: UILabel!
    @IBOutlet weak var unpurchasedStateClickedUILabel2: UILabel!
    @IBOutlet weak var unpurchasedStateClickedUILabel3: UILabel!
    @IBOutlet weak var unpurchasedStateClickedUILabel4: UILabel!
    
    @IBOutlet weak var disclaimerUIView: UIView!
    @IBOutlet weak var disclaimerUILabel: UILabel!
    @IBOutlet weak var disclaimerSeparatorUILabel: UILabel!
    @IBOutlet weak var privacyPolicyUIButton: UIButton!
    @IBOutlet weak var termsOfUseUIButton: UIButton!
    
    @IBOutlet weak var unpurchasedStatesContainerUIView: UIView!
    @IBOutlet weak var unpurchasedStatesUIScrollView: UIScrollView!
    @IBOutlet weak var stateButtonsUIView: UIView!
    
    @IBOutlet weak var unpurchasedStatesUIButton: UIButton!
    @IBOutlet weak var purchasedStatesUIButton: UIButton!
    
    @IBOutlet weak var moreMenuUIView: UIView!
    @IBOutlet weak var restorePurchasesUILabel: UILabel!
    @IBOutlet weak var contactUsUILabel: UILabel!
    @IBOutlet weak var twitterUILabel: UILabel!
    
    var formattedTickets = [FormattedTicket]()
    
    var currentUnpurchasedState: USAState?
    var unpurchasedStates = [UnpurchasedUIView]()
    var purchasedStates = [PurchasedUIView]()
    var unownedStates: [USAState]!
    var ownedStates: [USAState]!
    var showingUnpurchased = true
    var purchased: Bool!
    var loading: Bool!
    var purchaseSuccessful: Bool!
    var showingMoreMenu = false
    
    var unpurchasedStatesClickedLabelFontSize: CGFloat {
        return unpurchasedStatesClickedLabelScalingConstant * self.view.frame.height
    }
    let unpurchasedStatesClickedLabelScalingConstant: CGFloat = 0.025
    
    var moreMenuLableFontSize: CGFloat {
        return self.view.frame.size.height * moreMenuLabelScalingConstant
    }
    let moreMenuLabelScalingConstant: CGFloat = 0.024
    
    @IBAction func helpButtonClicked() {
        performSegue(withIdentifier: "showHelpView", sender: nil)
    }
    @IBAction func leftSwipe(_ sender: UISwipeGestureRecognizer) {
        if topBlankUIView.isHidden && unpurchasedStateClickedUIView.isHidden {
            switchToPurchasedStates()
        } else if topBlankUIView.isHidden && !unpurchasedStateClickedUIView.isHidden && showingMoreMenu {
            hideMoreMenu()
        }
    }
    @IBAction func unpurchasedRightSwipe(_ sender: UISwipeGestureRecognizer) {
        if topBlankUIView.isHidden && unpurchasedStateClickedUIView.isHidden && !showingMoreMenu {
            showMoreMenu()
        }
    }
    @IBAction func rightSwipe(_ sender: UISwipeGestureRecognizer) {
        if topBlankUIView.isHidden && unpurchasedStateClickedUIView.isHidden {
            switchToUnpurchasedStates()
        }
    }
    @IBAction func popupRightSwipe(_ sender: UISwipeGestureRecognizer) {
        animateViewPosition(view: unpurchasedStateClickedUIView, from: nil, to: CGAffineTransform(translationX: self.view.frame.width, y: 0), animTime: 0.35, fadeIn: false)
        UIView.animate(withDuration: 0.35, animations: {
            self.disclaimerUIView.transform = CGAffineTransform(translationX: 0, y: self.disclaimerUIView.frame.height)
        }) { (true) in
            self.disclaimerUIView.isHidden = true
        }
    }
    @IBAction func unpurchasedStatesButtonClicked(_ sender: UIButton) {
        switchToUnpurchasedStates()
    }
    @IBAction func purchasedStatesButtonClicked(_ sender: Any) {
        switchToPurchasedStates()
    }
    @IBAction func exitFromMenuView(_ sender: UIButton) {
        if showingMoreMenu {
            hideMoreMenu()
        } else {
            animateViewPosition(view: unpurchasedStateClickedUIView, from: nil, to: CGAffineTransform(translationX: self.view.frame.width, y: 0), animTime: 0.35, fadeIn: false)
            UIView.animate(withDuration: 0.35, animations: {
                self.disclaimerUIView.transform = CGAffineTransform(translationX: 0, y: self.disclaimerUIView.frame.height)
            }) { (true) in
                self.disclaimerUIView.isHidden = true
            }
        }
    }
    @IBAction func unpurchasedStateClickedPurchaseClicked() {
        onPurchaseButtonClicked(state: currentUnpurchasedState!)
    }
    @IBAction func unpurchasedStateClickedFreeClicked() {
        onFreeTrialClicked(state: currentUnpurchasedState!)
    }
    @IBAction func moreButtonClicked() {
        showMoreMenu()
    }
    @IBAction func restorePurchasesButtonClicked() {
        topBlankUIView.alpha = 1
        topBlankUIView.isHidden = false
        IAPService.shared.restorePurchases()
    }
    @IBAction func contactUsButtonClicked() {
        if MFMailComposeViewController.canSendMail() {
            let mailView = MFMailComposeViewController()
            mailView.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            mailView.setToRecipients(["scratchhackapp@gmail.com"])
            mailView.setSubject("Contact Us")
            mailView.setMessageBody("What can we help you with?", isHTML: false)
            
            // Present the view controller modally.
            self.present(mailView, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Contact Us", message: "Error opening email app, here's our email instead:\n\n scratchhackapp@gmail.com", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func twitterButtonClicked() {
        if let url = URL(string: "https://twitter.com/Scratch_Hack") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func privacyPolicyClicked() {
        if let url = URL(string: "https://github.com/ScratchHack/Privacy-Policy/blob/master/Privacy%20Policy.pdf") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func termsOfUseClicked() {
        if let url = URL(string: "https://www.websitepolicies.com/policies/view/FfgsmH") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

//Overriden stuff
extension StateViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Change back to load real products
        IAPService.shared.statePurchasedDelegate = self
        IAPService.shared.restorePurchasesDelegate = self
        IAPService.shared.statePurchaseFailedDelegate = self
        
        let labelScaleModifier: CGFloat = 0.65
        unpurchasedStateClickedUILabel.font = UIFont(name: unpurchasedStateClickedUILabel.font.fontName, size: unpurchasedStatesClickedLabelFontSize)
        unpurchasedStateClickedUILabel1.font = UIFont(name: unpurchasedStateClickedUILabel1.font.fontName, size: unpurchasedStatesClickedLabelFontSize * labelScaleModifier)
        unpurchasedStateClickedUILabel2.font = UIFont(name: unpurchasedStateClickedUILabel2.font.fontName, size: unpurchasedStatesClickedLabelFontSize * labelScaleModifier)
        unpurchasedStateClickedUILabel3.font = UIFont(name: unpurchasedStateClickedUILabel3.font.fontName, size: unpurchasedStatesClickedLabelFontSize * labelScaleModifier)
        unpurchasedStateClickedUILabel4.font = UIFont(name: unpurchasedStateClickedUILabel4.font.fontName, size: unpurchasedStatesClickedLabelFontSize * labelScaleModifier)
        
        let disclaimerScaleModifier: CGFloat = 0.55
        let disclaimerButtonsScaleModifier: CGFloat = 0.6
        disclaimerUILabel.font = UIFont(name: disclaimerUILabel.font.fontName, size: unpurchasedStatesClickedLabelFontSize * disclaimerScaleModifier)
        disclaimerSeparatorUILabel.font = UIFont(name: disclaimerSeparatorUILabel.font.fontName, size: unpurchasedStatesClickedLabelFontSize * disclaimerButtonsScaleModifier)
        privacyPolicyUIButton.titleLabel!.font = UIFont(name: privacyPolicyUIButton.titleLabel!.font.fontName, size: unpurchasedStatesClickedLabelFontSize *  disclaimerButtonsScaleModifier)
        termsOfUseUIButton.titleLabel!.font = UIFont(name: termsOfUseUIButton.titleLabel!.font.fontName, size: unpurchasedStatesClickedLabelFontSize * disclaimerButtonsScaleModifier)
        
        purchasedStatesContainerUIView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
        disclaimerUIView.transform = CGAffineTransform(translationX: 0, y: disclaimerUIView.frame.height)
        unpurchasedStateClickedUIView.isHidden = true
        disclaimerUIView.isHidden = true
        backgroundButton.isHidden = true
        topBlankUIView.isHidden = true
        loadingCirclesContainerUIView.isHidden = true
        
        mainUIView.layer.shadowColor = UIColor.black.cgColor
        mainUIView.layer.shadowOffset = CGSize(width: 0, height: 0)
        mainUIView.layer.shadowRadius = 12
        mainUIView.layer.shadowOpacity = 0.4
        
        unpurchasedStateClickedUIView.layer.shadowColor = UIColor.black.cgColor
        unpurchasedStateClickedUIView.layer.shadowOffset = CGSize(width: 0, height: 0)
        unpurchasedStateClickedUIView.layer.shadowRadius = 12
        unpurchasedStateClickedUIView.layer.shadowOpacity = 0.4
        
        setUnpurchasedButtons()
        setPurchasedButtons()
        configureMoreMenu()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for view in unpurchasedStates {
            view.callInViewWillLayoutSubviews()
        }
        for view in purchasedStates {
            view.callInViewWillLayoutSubviews()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showMainView" {
            if let mainView = segue.destination as? MainViewController {
                mainView.formattedTickets = formattedTickets
                mainView.purchased = purchased
                mainView.ownedStates = ownedStates
                mainView.unownedStates = unownedStates
            }
        } else if segue.identifier == "showHelpView" {
            if let helpView = segue.destination as? HelpViewController {
                helpView.ownedStates = ownedStates
                helpView.unownedStates = unownedStates
            }
        }
    }
}

//Private functions
extension StateViewController {
    private func setUnpurchasedButtons() {
        unownedStates.sort() { return $0.name < $1.name }
        
        unpurchasedStates = [UnpurchasedUIView]()
        for state in unownedStates {
            let cell = UnpurchasedUIView(state: state, parent: stateButtonsUIView, controller: self, unpurchasedViews: unpurchasedStates)
            unpurchasedStates.append(cell)
        }

        NSLayoutConstraint(item: stateButtonsUIView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: unpurchasedStates.last!, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 32).isActive = true
    }
    private func setPurchasedButtons() {
        ownedStates.sort() { return $0.name < $1.name }
        
        purchaseAStateUILabel.font = UIFont(name: purchaseAStateUILabel.font.fontName, size: moreMenuLableFontSize)
        purchaseAStateUILabel.isHidden = false
        purchasedStates = [PurchasedUIView]()
        for state in ownedStates {
            let cell = PurchasedUIView(state: state, parent: purchasedStatesContainerUIView, controller: self, purchasedViews: purchasedStates)
            purchasedStates.append(cell)
            purchaseAStateUILabel.isHidden = true
        }
    }
    private func configureMoreMenu() {
        restorePurchasesUILabel.font = UIFont(name: restorePurchasesUILabel.font.fontName, size: moreMenuLableFontSize)
        contactUsUILabel.font = UIFont(name: contactUsUILabel.font.fontName, size: moreMenuLableFontSize)
        twitterUILabel.font = UIFont(name: twitterUILabel.font.fontName, size: moreMenuLableFontSize)
    }
    private func onPurchaseButtonClicked(state: USAState) {
        onAnimateLoading(purchasing: true)
        IAPService.shared.purchaseSubscription(with: state.ID)
    }
    private func onFreeTrialClicked(state: USAState) {
        onAnimateLoading(purchasing: false)
        segueToInformationView(state: state)
    }
    private func segueToInformationView(state: USAState) {
        purchased = state.purchased
        let ticketHandler = GetTicketsHandler(url: state.url)
        ticketHandler.getFormattedTickets { (tickets) in
            if let tickets = tickets {
                self.formattedTickets = tickets
                self.loading = false
            }
        }
    }
    private func onAnimateLoading(purchasing: Bool) {
        topBlankUIView.isHidden = false
        loadingCirclesContainerUIView.isHidden = false
        loading = true
        animateLoadingCircles(purchasing: purchasing)
    }
    private func animateLoadingCircles(purchasing: Bool) {
        let sizeIncrease:CGFloat = 2
        let duration: Double = 0.4
        let delay: Double = 0.15
        let restartDelay: Double = 0.5
        
        for i in 0...loadingCirclesUIImage.count - 1 {
            //If on last circle, animate it then segue or redo animation
            if i == loadingCirclesUIImage.count - 1 {
                UIView.animate(withDuration: duration, delay: delay * Double(i), options: [], animations: {
                    self.loadingCirclesUIImage[i].transform = CGAffineTransform(scaleX: sizeIncrease, y: sizeIncrease)
                }) { (true) in
                    UIView.animate(withDuration: duration, animations: {
                        self.loadingCirclesUIImage[i].transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: { (true) in
                        //If purchase failed
                        if !self.loading {
                            if purchasing && !self.purchaseSuccessful {
                                self.loadingCirclesContainerUIView.isHidden = true
                                let alertController = UIAlertController(title: "Error", message: "Error occured during purchase.", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                                self.present(alertController, animated: true, completion: {
                                    self.topBlankUIView.isHidden = true
                                })
                            } else {
                                self.performSegue(withIdentifier: "showMainView", sender: nil)
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + restartDelay, execute: {
                                self.animateLoadingCircles(purchasing: purchasing)
                            })
                        }
                    })
                }
            } else {
                UIView.animate(withDuration: duration, delay: delay * Double(i), options: [], animations: {
                    self.loadingCirclesUIImage[i].transform = CGAffineTransform(scaleX: sizeIncrease, y: sizeIncrease)
                }) { (true) in
                    UIView.animate(withDuration: duration, animations: {
                        self.loadingCirclesUIImage[i].transform = CGAffineTransform(scaleX: 1, y: 1)
                    })
                }
            }
        }
    }
    private func switchToUnpurchasedStates() {
        if !showingUnpurchased {
            showingUnpurchased = true
            unpurchasedStatesUIButton.changeImageAnimated(image: #imageLiteral(resourceName: "BarLeftOn"), withDuration: 0.35)
            purchasedStatesUIButton.changeImageAnimated(image: #imageLiteral(resourceName: "BarRightOff"), withDuration: 0.35)
            
            topBlankUIView.alpha = 0
            topBlankUIView.isHidden = false
            UIView.animate(withDuration: 0.35, animations: {
                self.unpurchasedStatesContainerUIView.transform = CGAffineTransform.identity
                self.purchasedStatesContainerUIView.transform = CGAffineTransform(translationX: (self.view.frame.width), y: 0)
            }, completion: { (true) in
                self.topBlankUIView.isHidden = true
                self.topBlankUIView.alpha = 1
            })
        }
    }
    private func switchToPurchasedStates() {
        if showingUnpurchased {
            showingUnpurchased = false
            purchasedStatesUIButton.changeImageAnimated(image: #imageLiteral(resourceName: "BarRightOn"), withDuration: 0.35)
            unpurchasedStatesUIButton.changeImageAnimated(image: #imageLiteral(resourceName: "BarLeftOff"), withDuration: 0.35)
            
            topBlankUIView.alpha = 0
            topBlankUIView.isHidden = false
            UIView.animate(withDuration: 0.35, animations: {
                self.unpurchasedStatesContainerUIView.transform = CGAffineTransform(translationX: -(self.view.frame.width), y: 0)
                self.purchasedStatesContainerUIView.transform = CGAffineTransform.identity
            }, completion: { (true) in
                self.topBlankUIView.isHidden = true
                self.topBlankUIView.alpha = 1
            })
        }
    }
    private func animateViewPosition(view: UIView, from: CGAffineTransform?, to: CGAffineTransform, animTime: TimeInterval, fadeIn: Bool) {
        topBlankUIView.alpha = 0
        topBlankUIView.isHidden = false
        if let from = from {
            view.transform = from
        }
        
        if (fadeIn) {
            view.isHidden = false
            backgroundButton.alpha = 0
            backgroundButton.isHidden = false
        }
        
        UIView.animate(withDuration: animTime, animations: {
            view.transform = to
            
            if (fadeIn) {
                self.backgroundButton.alpha = 1
            } else {
                self.backgroundButton.alpha = 0
            }
        }) { (true) in
            if (!fadeIn) {
                self.backgroundButton.isHidden = true
                view.isHidden = true
            }
            
            self.topBlankUIView.isHidden = true
            self.topBlankUIView.alpha = 1
        }
    }
    private func showMoreMenu() {
        showingMoreMenu = true
        
        topBlankUIView.alpha = 0
        topBlankUIView.isHidden = false
        
        backgroundButton.alpha = 1
        backgroundButton.backgroundColor = UIColor.clear    //Can't change alpha for some reason, do this instead
        backgroundButton.isHidden = false
        
        UIView.animate(withDuration: 0.35, animations: {
            self.mainUIView.transform = CGAffineTransform(translationX: self.mainUIView.frame.width * 0.666, y: 0)
        }) { (true) in
            self.topBlankUIView.isHidden = true
        }
    }
    private func hideMoreMenu() {
        showingMoreMenu = false
        topBlankUIView.alpha = 0
        topBlankUIView.isHidden = false
        UIView.animate(withDuration: 0.35, animations: {
            self.mainUIView.transform = CGAffineTransform.identity
        }) { (true) in
            self.backgroundButton.isHidden = true
            self.backgroundButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
            self.topBlankUIView.alpha = 1
            self.topBlankUIView.isHidden = true
        }
    }
}

//On unpurchased state clicked
extension StateViewController: UnpurchasedStateClickedDelegate {
    func unpurchasedStateClicked(state: USAState) {
        self.unpurchasedStateClickedUILabel.text = currentUnpurchasedState!.name
        self.unpurchasedStateClickedUILabel1.text = currentUnpurchasedState!.name + " Subscription"
        
        animateViewPosition(view: unpurchasedStateClickedUIView, from: CGAffineTransform(translationX: self.view.frame.width, y: 0), to: CGAffineTransform.identity, animTime: 0.35, fadeIn: true)
        
        disclaimerUIView.isHidden = false
        disclaimerUIView.transform = CGAffineTransform(translationX: 0, y: disclaimerUIView.frame.height)
        UIView.animate(withDuration: 0.35) {
            self.disclaimerUIView.transform = CGAffineTransform.identity
        }
    }
}

//On purchase state clicked
extension StateViewController: PurchasedStateClickedDelegate {
    func purchasedStateClicked(state: USAState) {
        onAnimateLoading(purchasing: false)
        segueToInformationView(state: state)
    }
}

//When a state is first purchased
extension StateViewController: StatePurchasedDelegate {
    func statePurchased(state: USAState) {
        //Remove the unpurchased state from unpurchased states
        print(unownedStates.count)
        if unownedStates.count > 0 {
            for i in 0...unownedStates.count - 1 {
                print(i)
                if unownedStates[i].state == state.state {
                    unownedStates.remove(at: i)
                    break
                }
            }
        }
        
        ownedStates.append(state)
        
        purchaseSuccessful = true
        segueToInformationView(state: state)
    }
}

//When purchasing a state fails
extension StateViewController: StatePurchaseFailedDelegate {
    func statePurchaseFailed() {
        self.loading = false
        self.purchaseSuccessful = false
    }
}

//On restore purchases finished
extension StateViewController: RestorePurchasesFinishedDelegate {
    func restorePurchasesFinished(succeeded: Bool) {
        topBlankUIView.isHidden = true
        
        if succeeded {
            let alert = UIAlertController(title: "Please Restart", message: "For restored purchases to take effect, please restart the app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Error occured while restoring purchases.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//On email send delegate
extension StateViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .sent:
            print("Email sent")
        case .failed:
            print("Email canceled sending")
        default:
            print("Email result not caught")
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}





