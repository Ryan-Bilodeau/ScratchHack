//
//  FirstViewController.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/16/19.
//  Copyright © 2019 Ryan Bilodeau. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds
import paper_onboarding

class FirstViewController: UIViewController {
    private let displayAd = true
    
    private var animator: UIViewPropertyAnimator!
    private var inCenter = true
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var interstitial: GADInterstitial!
    private var tickets: [FormattedTicket]!
    private var didSegueFromSecondView: Bool = false
    
    private var xTranslationAmount: CGFloat {
        return self.mainUIView.frame.width * 0.666
    }
    private var canAnimate: Bool {
        guard let animator = animator else { return true }
        
        if animator.fractionComplete == 0 || animator.fractionComplete == 100 {
            return true
        } else {
            return false
        }
    }
    private var buttonDown: Bool = false
    private var selectedState: String!
    
    @IBOutlet weak var sideMenuUIView: UIView!
    @IBOutlet weak var shadowUIView: UIView!
    @IBOutlet weak var mainUIView: UIView!
    @IBOutlet weak var collectionUIView: UICollectionView!
    @IBOutlet weak var downArrowUIImage: UIImageView!
    @IBOutlet weak var topUIView: UIView!
    @IBOutlet weak var onboardingUIView: OnboardingView!
    @IBOutlet weak var dismissUIButton: UIButton!
    
    @IBAction func menuButtonClicked(_ sender: Any) {
        handleMenuButtonClick()
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
        if let url = URL(string: "https://twitter.com/RyanBilodeauME") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func dismissButtonClicked() {
        UIView.animate(withDuration: 0.5, animations: {
            self.onboardingUIView.transform = CGAffineTransform(translationX: 0, y: -self.mainUIView.frame.height)
        }) { (true) in
            self.onboardingUIView.isHidden = true
            self.panGestureRecognizer.isEnabled = true
            self.onboardingUIView.currentIndex(0, animated: false)
            self.dismissUIButton.alpha = 0
        }
    }
    
    @IBAction func helpButtonClicked() {
        self.onboardingUIView.isHidden = false
        self.panGestureRecognizer.isEnabled = false
        
        UIView.animate(withDuration: 0.5) {
            self.onboardingUIView.transform = CGAffineTransform.identity
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionUIView.delegate = self
        collectionUIView.dataSource = self
        collectionUIView.register(StateCollectionViewCell.self, forCellWithReuseIdentifier: "stateCell")
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        panGestureRecognizer.cancelsTouchesInView = false
        mainUIView.addGestureRecognizer(panGestureRecognizer)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.delaysTouchesBegan = false
        navigationController?.interactivePopGestureRecognizer?.delaysTouchesEnded = false
        
        interstitial = createAndLoadInterstitial()
        
        if self.view.frame.width > 600 {
            shadowUIView.layer.cornerRadius = 16
            mainUIView.layer.cornerRadius = 16
        }
        
        shadowUIView.layer.shadowOpacity = 0.5
        shadowUIView.layer.shadowColor = UIColor.black.cgColor
        shadowUIView.layer.shadowRadius = 8
        shadowUIView.layer.shadowOffset = CGSize.zero
        shadowUIView.layer.masksToBounds = false
        
        topUIView.alpha = 0.5
        topUIView.isHidden = true
        
        onboardingUIView.dataSource = self
        onboardingUIView.delegate = self
        
        let defaults = UserDefaults.standard
        if defaults.integer(forKey: "Runtimes") == 0 {
            onboardingUIView.isHidden = false
            dismissUIButton.alpha = 0
            panGestureRecognizer.isEnabled = false
        } else {
            onboardingUIView.isHidden = true
            onboardingUIView.transform = CGAffineTransform(translationX: 0, y: -mainUIView.frame.height)
        }
        
        if defaults.integer(forKey: "Runtimes") == 1 || defaults.integer(forKey: "Runtimes") == 5 {
            if #available( iOS 10.3,*){
                SKStoreReviewController.requestReview()
            }
        }
        
        defaults.set(defaults.integer(forKey: "Runtimes") + 1, forKey: "Runtimes")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if didSegueFromSecondView {
            didSegueFromSecondView = false
            topUIView.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TicketsViewController, let stateName = sender as? String {
            destination.stateName = stateName
            destination.firstViewTickets = tickets
            
            if tickets[0].statsRank != nil {
                destination.secondViewTickets = tickets
            }
            
            self.topUIView.isHidden = true
            self.didSegueFromSecondView = true
        }
    }
    
    private func loadTicketsAndSegue() {
        DispatchQueue.main.async {
            DataManager.getTicketsFrom(url: Strings.Url  + self.selectedState.replacingOccurrences(of: " ", with: "") + ".php") { (data) in
                
                if let data = data {
                    self.tickets = data
                    self.performSegue(withIdentifier: "goToTicketsView", sender: self.selectedState)
                } else {
                    let alert = UIAlertController(title: "Error", message: "There was an error getting ticket data for " + self.selectedState + ", please check your internet connection or try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.topUIView.isHidden = true
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let ad = GADInterstitial(adUnitID: Strings.AdMobInterstitialID)
        ad.delegate = self
        ad.load(GADRequest())
        return ad
    }
}

// Functions to handle Paper Onboarding
extension FirstViewController: PaperOnboardingDataSource, PaperOnboardingDelegate {
    func onboardingItemsCount() -> Int {
        return 4
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        let bg1 = UIColor(red: 255 / 255, green: 223 / 255, blue: 217 / 255, alpha: 1)
        let bg2 = UIColor(red: 255 / 255, green: 217 / 255, blue: 213 / 255, alpha: 1)
        let bg3 = UIColor(red: 255 / 255, green: 211 / 255, blue: 209 / 255, alpha: 1)
        let bg4 = UIColor(red: 255 / 255, green: 205 / 255, blue: 205 / 255, alpha: 1)
 
        let titleFont = UIFont(name: "Poppins", size: 30)!
        let titleColor = UIColor(red: 251 / 255, green: 103 / 255, blue: 83 / 255, alpha: 1)
        let descriptionFont = UIFont(name: "Poppins", size: 20)!
        let descriptionColor = UIColor.darkGray
        
        let screen1 = OnboardingItemInfo(informationImage: UIImage(named: "Icon")!, title: "Welcome", description: "Thank you for downloading Scratch Hack", pageIcon: UIImage(named: "Icon")!, color: bg1, titleColor: titleColor, descriptionColor: descriptionColor, titleFont: titleFont, descriptionFont: descriptionFont)
        let screen2 = OnboardingItemInfo(informationImage: UIImage(named: "State Select")!, title: "Select", description: "Pick your state or browse other states", pageIcon: UIImage(named: "State Select")!, color: bg2, titleColor: titleColor, descriptionColor: descriptionColor, titleFont: titleFont, descriptionFont: descriptionFont)
        let screen3 = OnboardingItemInfo(informationImage: UIImage(named: "Rank by Odds")!, title: "Rank by Odds", description: "Games are ranked either by starting odds", pageIcon: UIImage(named: "Rank by Odds")!, color: bg3, titleColor: titleColor, descriptionColor: descriptionColor, titleFont: titleFont, descriptionFont: descriptionFont)
        let screen4 = OnboardingItemInfo(informationImage: UIImage(named: "Rank Image")!, title: "Rank by Statistics", description: "Or, games are ranked using information we gather daily. Not available for every state.", pageIcon: UIImage(named: "Rank Image")!, color: bg4, titleColor: titleColor, descriptionColor: descriptionColor, titleFont: titleFont, descriptionFont: descriptionFont)
        
        return [screen1, screen2, screen3, screen4][index]
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index != 3 && dismissUIButton.alpha > 0 {
            UIView.animate(withDuration: 0.4) {
                self.dismissUIButton.alpha = 0
            }
        }
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 3 {
            onboardingUIView.bringSubviewToFront(dismissUIButton)
            UIView.animate(withDuration: 0.4) {
                self.dismissUIButton.alpha = 1
            }
        }
    }
}

// Private functions and selectors to handle interactive animations
extension FirstViewController {
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: mainUIView)
        
        switch recognizer.state {
        case .began:
            startPanning()
        case .changed:
            scrub(translation: translation)
        case .ended:
            let velocity = recognizer.velocity(in: mainUIView)
            endAnimation(translation: translation, velocity: velocity)
        default:
            print("pan default")
        }
    }
    
    private func handleMenuButtonClick() {
        if panGestureRecognizer.isEnabled {
            panGestureRecognizer.isEnabled = false
            
            var mainUIViewTansform: CGAffineTransform!
            var shadowUIViewTransform: CGAffineTransform!
            
            if inCenter {
                mainUIViewTansform = CGAffineTransform.init(translationX: xTranslationAmount, y: 0)
                shadowUIViewTransform = CGAffineTransform.init(translationX: xTranslationAmount, y: 0)
            } else {
                mainUIViewTansform = CGAffineTransform.identity
                shadowUIViewTransform = CGAffineTransform.identity
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.mainUIView.transform = mainUIViewTansform
                self.shadowUIView.transform = shadowUIViewTransform
            }) { (true) in
                self.inCenter = !self.inCenter
                self.panGestureRecognizer.isEnabled = true
            }
        }
    }
    
    private func startPanning() {
        var mainUIViewTansform: CGAffineTransform!
        var backgoundUIViewTransform: CGAffineTransform!
        
        if inCenter {
            mainUIViewTansform = CGAffineTransform.init(translationX: xTranslationAmount, y: 0)
            backgoundUIViewTransform = CGAffineTransform.init(translationX: xTranslationAmount, y: 0)
        } else {
            mainUIViewTansform = CGAffineTransform.identity
            backgoundUIViewTransform = CGAffineTransform.identity
        }
        
        animator = UIViewPropertyAnimator(duration: 1, dampingRatio: 0.8, animations: {
            self.mainUIView.transform = mainUIViewTansform
            self.shadowUIView.transform = backgoundUIViewTransform
        })
    }
    
    private func scrub (translation:CGPoint) {
        if let animator = self.animator {
            var progress:CGFloat = 0
            
            if inCenter {
                progress = translation.x / (xTranslationAmount)
            } else {
                progress = (-translation.x) / (xTranslationAmount)
            }
            
            progress = max(0.001, min(0.999, progress))
            
            animator.fractionComplete = progress
        }
    }
    
    private func endAnimation (translation:CGPoint, velocity:CGPoint) {
        if let animator = self.animator {
            panGestureRecognizer.isEnabled = false
            
            if inCenter {
                if velocity.x >= -1 {
                    animator.isReversed = false
                    animator.addCompletion { (position:UIViewAnimatingPosition) in
                        self.inCenter = false
                        self.panGestureRecognizer.isEnabled = true
                    }
                } else {
                    animator.isReversed = true
                    animator.addCompletion { (position:UIViewAnimatingPosition) in
                        self.inCenter = true
                        self.panGestureRecognizer.isEnabled = true
                    }
                }
            } else {
                if velocity.x <= 1 {
                    animator.isReversed = false
                    animator.addCompletion { (position:UIViewAnimatingPosition) in
                        self.inCenter = true
                        self.panGestureRecognizer.isEnabled = true
                    }
                } else {
                    animator.isReversed = true
                    animator.addCompletion { (position:UIViewAnimatingPosition) in
                        self.inCenter = false
                        self.panGestureRecognizer.isEnabled = true
                    }
                }
            }
            
            if animator.fractionComplete > 0 && animator.fractionComplete < 100 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            } else {
                panGestureRecognizer.isEnabled = true
            }
        }
    }
}

// Delegate to allow recieving interactions from the pan gesture recognizer
extension FirstViewController: UIGestureRecognizerDelegate { }

extension FirstViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return States.stateNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stateCell", for: indexPath) as! StateCollectionViewCell
        if cell.stateUIButton == nil {
            cell.setStateUIButton(stateName: States.stateNames[indexPath.row], abbreviation: States.stateAbbreviations[indexPath.row], delegate: self)
        } else {
            cell.stateUIButton.setButtonForState(name: States.stateNames[indexPath.row], abbreviation: States.stateAbbreviations[indexPath.row])
        }
        return cell
    }
}

extension FirstViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (collectionView.frame.width > 400) {
            return CGSize(width: (collectionView.bounds.size.width / 3), height: (collectionView.bounds.size.width / 4.5))
        } else {
            return CGSize(width: (collectionView.bounds.size.width / 2), height: (collectionView.bounds.size.width / 3))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == States.stateNames.count - 1 {
            let animationDuration: CGFloat  = 0.25
            let duration = TimeInterval(downArrowUIImage.alpha * animationDuration)
            
            downArrowUIImage.stopAnimating()
            UIView.animate(withDuration: duration) {
                self.downArrowUIImage.alpha = 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == States.stateNames.count - 1  {
            let animationDuration: CGFloat  = 0.25
            let duration = TimeInterval(downArrowUIImage.alpha * animationDuration)
            
            downArrowUIImage.stopAnimating()
            UIView.animate(withDuration: duration) {
                self.downArrowUIImage.alpha = 1
            }
        }
    }
}

extension FirstViewController: MFMailComposeViewControllerDelegate {
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

extension FirstViewController: GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
        
        self.topUIView.isHidden = false
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        
        interstitial = createAndLoadInterstitial()
        self.topUIView.isHidden = false
        loadTicketsAndSegue()
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}

extension FirstViewController: StateUIButtonDelegate {
    func buttonDown(sender: StateUIButton) {
        if canAnimate && abs(panGestureRecognizer.velocity(in: mainUIView).x) < 5 {
            self.panGestureRecognizer.isEnabled = false
            self.buttonDown = true
            sender.topUIView.isHidden = false
            self.selectedState = sender.stateName
            
            UIView.animate(withDuration: 0.05) {
                sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        }
    }
    
    func buttonTouchUpInside(sender: StateUIButton) {
        if buttonDown {
            self.panGestureRecognizer.isEnabled = true
            self.buttonDown = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.animate(withDuration: 0.05, animations: {
                    sender.transform = CGAffineTransform.identity
                }, completion: { (true) in
                    self.topUIView.isHidden = false
                    sender.topUIView.isHidden = true
                    
                    if self.interstitial.isReady && self.displayAd {
                        self.interstitial.present(fromRootViewController: self)
                    } else {
                        print("Ad not ready to display")
                        self.loadTicketsAndSegue()
                    }
                })
            }
        }
    }
    
    func buttonUp(sender: StateUIButton) {
        if canAnimate {
            self.panGestureRecognizer.isEnabled = true
            self.buttonDown = false
            
            UIView.animate(withDuration: 0.05, animations: {
                sender.transform = CGAffineTransform.identity
            }) { (true) in
                sender.topUIView.isHidden = true
            }
        }
    }
}

