//
//  TicketsViewController.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/19/19.
//  Copyright © 2019 Ryan Bilodeau. All rights reserved.
//

import UIKit

class TicketsViewController: UIViewController {
    public var stateName: String!
    public var firstViewTickets: [FormattedTicket]!
    public var secondViewTickets: [FormattedTicket]!
    
    private var animator: UIViewPropertyAnimator!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var showingLeftView = true {
        didSet {
            if showingLeftView {
                pageControl.currentPage = 0
                fieldUIButtonCollection[3].setTitle("Odds", for: .normal)
                resetView(left: false)
            } else {
                pageControl.currentPage = 1
                resetView(left: true)
                
                if stateName != "Maine" {
                    secondTitleColumn4UILabel.text = "Prizes Remaining"
                    fieldUIButtonCollection[3].setTitle("Prizes", for: .normal)
                } else {
                    secondTitleColumn4UILabel.text = "Average Profit"
                    fieldUIButtonCollection[3].setTitle("Profit", for: .normal)
                }
            }
        }
    }
    
    private var xTranslationAmount: CGFloat {
        return gestureUIView.frame.width + 48
    }
    private var canAnimate: Bool {
        guard let animator = animator else { return true }
        
        if animator.fractionComplete == 0 || animator.fractionComplete == 100 {
            return true
        } else {
            return false
        }
    }
    
    private lazy var sortByUIViewTransform: CGAffineTransform = sortByUIView.transform.translatedBy(x: 0, y: (-mainUIView.frame.height / 2) - sortByUIView.frame.height - 24)
    
    @IBOutlet weak var shadowUIView: UIView!
    @IBOutlet weak var mainUIView: UIView!
    @IBOutlet weak var stateNameUILabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var gestureUIView: UIView!
    
    @IBOutlet weak var firstUIView: UIView!
    @IBOutlet weak var firstTitleUIView: UIView!
    @IBOutlet weak var firstUITableView: UITableView!
    @IBOutlet weak var firstDownArrowUIImage: UIImageView!
    
    @IBOutlet weak var secondUIView: UIView!
    @IBOutlet weak var secondTitleUIView: UIView!
    @IBOutlet weak var secondTitleColumn4UILabel: UILabel!
    @IBOutlet weak var secondUITableView: UITableView!
    @IBOutlet weak var secondDownArrowUIImage: UIImageView!
    @IBOutlet weak var noStatsRankUILabel: UILabel!
    
    @IBOutlet weak var topUIButton: UIButton!
    @IBOutlet weak var sortByUIView: UIView!
    @IBOutlet weak var sortByUIButton: UIButton!
    @IBOutlet var sortUIButtonCollection: [SortUIButton]!
    @IBOutlet var fieldUIButtonCollection: [SortUIButton]!
    
    @IBAction func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func sortButtonClicked(_ sender: Any) {
        showSortView()
    }
    @IBAction func topUIButtonClicked(_ sender: Any) {
        dismissSortByView()
    }
    @IBAction func sortyByXButtonClicked(_ sender: Any) {
        dismissSortByView()
    }
    @IBAction func sortButtonsActionCollection(_ sender: SortUIButton) {
        sortButtonsPressed(sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstTitleUIView.layer.cornerRadius = firstTitleUIView.frame.height / 4
        secondTitleUIView.layer.cornerRadius = secondTitleUIView.frame.height / 4
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        panGestureRecognizer.cancelsTouchesInView = false
        gestureUIView.addGestureRecognizer(panGestureRecognizer)
        
        firstUITableView.dataSource = self
        firstUITableView.delegate = self
        firstUITableView.tableFooterView = UIView(frame: .zero)
        firstUITableView.allowsSelection = false
        firstUITableView.rowHeight = 75
        
        secondUITableView.dataSource = self
        secondUITableView.delegate = self
        secondUITableView.tableFooterView = UIView(frame: .zero)
        secondUITableView.allowsSelection = false
        secondUITableView.rowHeight = 75
        
        if self.view.frame.width > 600 {
            mainUIView.layer.cornerRadius = 16
            shadowUIView.layer.cornerRadius = 16
        }
        
        shadowUIView.layer.shadowOpacity = 0.5
        shadowUIView.layer.shadowColor = UIColor.black.cgColor
        shadowUIView.layer.shadowRadius = 8
        shadowUIView.layer.shadowOffset = CGSize.zero
        shadowUIView.layer.masksToBounds = false
        
        sortByUIView.layer.cornerRadius = 4
        sortByUIView.layer.shadowOpacity = 0.5
        sortByUIView.layer.shadowColor = UIColor.black.cgColor
        sortByUIView.layer.shadowRadius = 8
        sortByUIView.layer.shadowOffset = CGSize.zero
        sortByUIView.layer.masksToBounds = false
        
        for button in fieldUIButtonCollection {
            if button.tag == 5 {
                button.layer.cornerRadius = 6
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stateNameUILabel.text = stateName
        
        firstViewTickets.sort{ return $0.oddsRank < $1.oddsRank }
        
        if secondViewTickets == nil {
            noStatsRankUILabel.isHidden = false
            noStatsRankUILabel.text = "We do not have enough data describing games from " + stateName + " to accurately rank tickets, try ranking by starting odds instead."
            
            secondTitleUIView.isHidden = true
            secondUITableView.isHidden = true
            secondDownArrowUIImage.isHidden = true
        } else {
            secondViewTickets.sort { return $0.statsRank! < $1.statsRank! }
            noStatsRankUILabel.isHidden = true
            secondTitleUIView.isHidden = false
            secondUITableView.isHidden = false
            secondDownArrowUIImage.isHidden = false
            showingLeftView = false
        }
        
        topUIButton.isHidden = true
        sortByUIView.isHidden = true
        
        sortByUIView.transform = sortByUIViewTransform
        
        resetSortButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if secondViewTickets != nil {
            panGestureRecognizer.isEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                self.firstUIView.transform = CGAffineTransform.init(translationX: -self.xTranslationAmount, y: 0)
                self.secondUIView.transform = CGAffineTransform.init(translationX: -self.xTranslationAmount, y: 0)
            }) { (true) in
                self.panGestureRecognizer.isEnabled = true
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Removes the last line separator in table view
        firstUITableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: firstUITableView.frame.size.width, height: 1))
        secondUITableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: firstUITableView.frame.size.width, height: 1))
    }
}

// Selectors and private functions to handle interactive animations
extension TicketsViewController {
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: gestureUIView)
        
        switch recognizer.state {
        case .began:
            startPanning()
        case .changed:
            scrub(translation: translation)
        case .ended:
            let velocity = recognizer.velocity(in: gestureUIView)
            endAnimation(translation: translation, velocity: velocity)
        default:
            print("pan default")
        }
    }
    
    func startPanning() {
        var firstTransform: CGAffineTransform!
        var secondTransfrom: CGAffineTransform!
        
        if showingLeftView {
            firstTransform = CGAffineTransform.init(translationX: -xTranslationAmount, y: 0)
            secondTransfrom = CGAffineTransform.init(translationX: -xTranslationAmount, y: 0)
        } else {
            firstTransform = CGAffineTransform.identity
            secondTransfrom = CGAffineTransform.identity
        }
        
        animator = UIViewPropertyAnimator(duration: 1, dampingRatio: 0.8, animations: {
            self.firstUIView.transform = firstTransform
            self.secondUIView.transform = secondTransfrom
        })
    }
    
    func scrub (translation:CGPoint) {
        if let animator = self.animator {
            var progress:CGFloat = 0
            
            if showingLeftView {
                progress = (-translation.x) / (xTranslationAmount)
            } else {
                progress = translation.x / (xTranslationAmount)
            }
            
            progress = max(0.001, min(0.999, progress))
            
            animator.fractionComplete = progress
        }
    }
    
    func endAnimation (translation:CGPoint, velocity:CGPoint) {
        if let animator = self.animator {
            panGestureRecognizer.isEnabled = false
            
            if showingLeftView {
                if velocity.x <= 0 {
                    animator.isReversed = false
                    animator.addCompletion { (position:UIViewAnimatingPosition) in
                        self.showingLeftView = false
                        self.panGestureRecognizer.isEnabled = true
                    }
                } else {
                    animator.isReversed = true
                    animator.addCompletion { (position:UIViewAnimatingPosition) in
                        self.showingLeftView = true
                        self.panGestureRecognizer.isEnabled = true
                    }
                }
            } else {
                if velocity.x >= 0 {
                    animator.isReversed = false
                    animator.addCompletion { (position:UIViewAnimatingPosition) in
                        self.showingLeftView = true
                        self.panGestureRecognizer.isEnabled = true
                    }
                } else {
                    animator.isReversed = true
                    animator.addCompletion { (position:UIViewAnimatingPosition) in
                        self.showingLeftView = false
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

// Overridden functions and private functions dealing with sorting and displaying of tables
extension TicketsViewController: UITableViewDataSource, UITableViewDelegate {
    //Number of cells
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return firstViewTickets.count
    }
    //Called for each cell when the cell is displayed
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let animationDuration: CGFloat  = 0.25
        
        if tableView == firstUITableView {
            if indexPath.row == firstViewTickets.count - 1 {
                firstDownArrowUIImage.stopAnimating()
                UIView.animate(withDuration: TimeInterval(firstDownArrowUIImage.alpha * animationDuration)) {
                    self.firstDownArrowUIImage.alpha = 0
                }
            }
        } else if tableView == secondUITableView && secondViewTickets != nil {
            if indexPath.row == secondViewTickets.count - 1 {
                secondDownArrowUIImage.stopAnimating()
                UIView.animate(withDuration: TimeInterval(secondDownArrowUIImage.alpha * animationDuration)) {
                    self.secondDownArrowUIImage.alpha = 0
                }
            }
        }
        
        return formatCell(tableView: tableView, cellForRowAt: indexPath)
    }
    //Called when a cell stops displaying (is dequeued)
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let animationDuration: CGFloat  = 0.25
        
        if tableView == firstUITableView {
            if indexPath.row == firstViewTickets.count - 1 {
                firstDownArrowUIImage.stopAnimating()
                UIView.animate(withDuration: TimeInterval(firstDownArrowUIImage.alpha * animationDuration)) {
                    self.firstDownArrowUIImage.alpha = 1
                }
            }
        } else if tableView == secondUITableView && secondViewTickets != nil {
            if indexPath.row == secondViewTickets.count - 1 {
                secondDownArrowUIImage.stopAnimating()
                UIView.animate(withDuration: TimeInterval(secondDownArrowUIImage.alpha * animationDuration)) {
                    self.secondDownArrowUIImage.alpha = 1
                }
            }
        }
    }
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    private func formatCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var firstTableViewCell: FirstTableViewCell!
        var secondTableViewCell: SecondTableViewCell!
        
        if tableView == firstUITableView {
            firstTableViewCell = tableView.dequeueReusableCell(withIdentifier: "firstTableViewCell") as? FirstTableViewCell
            
            firstTableViewCell.priceUILabel.text = "$" + String(firstViewTickets[indexPath.row].price)
            
            if firstViewTickets[indexPath.row].number == nil {
                firstTableViewCell.idUILabel.text = "-"
            } else {
                firstTableViewCell.idUILabel.text = String(firstViewTickets[indexPath.row].number!)
            }
            
            firstTableViewCell.nameUILabel.text = firstViewTickets[indexPath.row].name
            firstTableViewCell.oddsUILabel.text = String(firstViewTickets[indexPath.row].odds)
            firstTableViewCell.oddsRankUILabel.text = String(firstViewTickets[indexPath.row].oddsRank)
        } else if tableView == secondUITableView && secondViewTickets != nil {
            secondTableViewCell = tableView.dequeueReusableCell(withIdentifier: "secondTableViewCell") as? SecondTableViewCell
            
            secondTableViewCell.priceUILabel.text = "$" + String(secondViewTickets[indexPath.row].price)
            
            if secondViewTickets[indexPath.row].number == nil {
                secondTableViewCell.idUILabel.text = "-"
            } else {
                secondTableViewCell.idUILabel.text = String(secondViewTickets[indexPath.row].number!)
            }
            
            secondTableViewCell.nameUILabel.text = secondViewTickets[indexPath.row].name
            
            if stateName != "Maine" {
                secondTableViewCell.prizesRemainingUILabel.text = String(format: "%.1f", secondViewTickets[indexPath.row].prizesRemaining!) + "%"
            } else {
                secondTableViewCell.prizesRemainingUILabel.text = "$" + String(format: "%.2f", abs(secondViewTickets[indexPath.row].averageProfit!))
                
                if secondViewTickets[indexPath.row].averageProfit! > 0 {
                    secondTableViewCell.prizesRemainingUILabel.textColor = UIColor(red: 1 / 255, green: 174 / 255, blue: 4 / 255, alpha: 1)
                } else {
                    secondTableViewCell.prizesRemainingUILabel.textColor = .red
                }
            }
            
            secondTableViewCell.rankUILabel.text = String(secondViewTickets[indexPath.row].statsRank!)
        }
        
        if tableView == firstUITableView {
            return firstTableViewCell
        } else if tableView == secondUITableView && secondViewTickets != nil {
            return secondTableViewCell
        } else {
            return UITableViewCell()
        }
    }
}

// Private functions to manage the sort functionality
extension TicketsViewController {
    private func resetSortButtons() {
        sortUIButtonCollection.sort { return $0.tag < $1.tag }
        fieldUIButtonCollection.sort { return $0.tag < $1.tag }
        
        sortUIButtonCollection[0].on = true
        sortUIButtonCollection[1].on = false
        
        fieldUIButtonCollection[0].on = false
        fieldUIButtonCollection[1].on = false
        fieldUIButtonCollection[2].on = false
        fieldUIButtonCollection[3].on = false
        fieldUIButtonCollection[4].on = true
    }
    private func resetView(left: Bool) {
        sortUIButtonCollection[0].on = true
        sortUIButtonCollection[1].on = false
        
        fieldUIButtonCollection[0].on = false
        fieldUIButtonCollection[1].on = false
        fieldUIButtonCollection[2].on = false
        fieldUIButtonCollection[3].on = false
        fieldUIButtonCollection[4].on = true
        
        if left {
            firstViewTickets.sort { return $0.oddsRank < $1.oddsRank }
            firstUITableView.reloadData()
        } else {
            if secondViewTickets != nil {
                secondViewTickets.sort { return $0.statsRank! < $1.statsRank! }
                secondUITableView.reloadData()
            }
        }
    }
    private func sortButtonsPressed(sender: SortUIButton) {
        if sender.tag < 2 {
            for button in sortUIButtonCollection {
                if button.tag == sender.tag {
                    button.on = true
                } else {
                    button.on = false
                }
            }
        } else {
            for button in fieldUIButtonCollection {
                if button.tag == sender.tag {
                    button.on = true
                } else {
                    button.on = false
                }
            }
        }
        
        var tickets: [FormattedTicket] = showingLeftView ? firstViewTickets : secondViewTickets
        if sortUIButtonCollection[0].on {
            switch true {
            case fieldUIButtonCollection[0].on:
                tickets.sort { return $0.price < $1.price }
            case fieldUIButtonCollection[1].on:
                if tickets[0].number != nil {
                    tickets.sort { return $0.number! < $1.number! }
                }
            case fieldUIButtonCollection[2].on:
                tickets.sort { return $0.name < $1.name }
            case fieldUIButtonCollection[3].on:
                if showingLeftView {
                    tickets.sort { return $0.odds < $1.odds }
                } else {
                    if stateName != "Maine" {
                        tickets.sort { return $0.prizesRemaining! < $1.prizesRemaining! }
                    } else {
                        tickets.sort { return $0.averageProfit! < $1.averageProfit! }
                    }
                }
            case fieldUIButtonCollection[4].on:
                if showingLeftView {
                    tickets.sort { return $0.oddsRank < $1.oddsRank }
                } else {
                    tickets.sort { return $0.statsRank! < $1.statsRank! }
                }
            default:
                print("First switch statement in TicketsViewController exhausted")
            }
        } else if sortUIButtonCollection[1].on {
            switch true {
            case fieldUIButtonCollection[0].on:
                tickets.sort { return $0.price > $1.price }
            case fieldUIButtonCollection[1].on:
                if tickets[0].number != nil {
                    tickets.sort { return $0.number! > $1.number! }
                }
            case fieldUIButtonCollection[2].on:
                tickets.sort { return $0.name > $1.name }
            case fieldUIButtonCollection[3].on:
                if showingLeftView {
                    tickets.sort { return $0.odds > $1.odds }
                } else {
                    if stateName != "Maine" {
                        tickets.sort { return $0.prizesRemaining! > $1.prizesRemaining! }
                    } else {
                        tickets.sort { return $0.averageProfit! > $1.averageProfit! }
                    }
                }
            case fieldUIButtonCollection[4].on:
                if showingLeftView {
                    tickets.sort { return $0.oddsRank > $1.oddsRank }
                } else {
                    tickets.sort { return $0.statsRank! > $1.statsRank! }
                }
            default:
                print("Second switch statement in TicketsViewController exhausted")
            }
        }
        
        if showingLeftView {
            firstViewTickets = tickets
            firstUITableView.reloadData()
        } else {
            secondViewTickets = tickets
            secondUITableView.reloadData()
        }
    }
    private func showSortView() {
        if !showingLeftView && secondViewTickets == nil { return }
        
        if panGestureRecognizer.isEnabled {
            panGestureRecognizer.isEnabled = false
            topUIButton.isHidden = false
            sortByUIView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.topUIButton.alpha = 0.05
                self.sortByUIView.transform = CGAffineTransform.identity
            }
        }
    }
    private func dismissSortByView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.topUIButton.alpha = 0
            self.sortByUIView.transform = self.sortByUIViewTransform
        }) { (true) in
            self.topUIButton.isHidden = true
            self.sortByUIView.isHidden = true
            self.panGestureRecognizer.isEnabled = true
        }
    }
}
