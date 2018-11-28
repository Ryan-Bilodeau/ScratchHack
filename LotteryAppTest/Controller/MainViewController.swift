//
//  MainViewController.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 2/22/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var downArrowImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var IDUIImage: UIImageView!
    @IBOutlet weak var nameUIImage: UIImageView!
    
    @IBOutlet weak var sortViewContainer: UIView!
    @IBOutlet weak var sortViewButton: UIButton!
    @IBOutlet weak var sortViewBackground: UIImageView!
    @IBOutlet weak var sortXButton: UIButton!
    
    @IBOutlet var sortOrderButtons: [CustomButton]!
    @IBOutlet var sortFieldButtons: [CustomButton]!
    
    var formattedTickets = [FormattedTicket]()
    var purchased: Bool!
    
    //Not used by this controller, used to save data between views
    var unownedStates: [USAState]!
    var ownedStates: [USAState]!
    
    var cellLabelFontSize: CGFloat {
        return self.view.frame.size.width * cellLabelScalingConstant
    }
    let cellLabelScalingConstant: CGFloat = 0.03
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        goBackToStateView()
    }
    @IBAction func backButtonPressed() {
        goBackToStateView()
    }
    @IBAction func sortByButtonPressed() {
        sortViewButton.isHidden = false
        UIView.animate(withDuration: 0.35) {
            self.sortViewButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        }
        
        sortViewContainer.isHidden = false
        sortViewContainer.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
        UIView.animate(withDuration: 0.35) {
            self.sortViewContainer.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    @IBAction func sortByButtonActionCollection(_ sender: CustomButton) {
        updateSortByButtonImages(sender)
        updateTable()
    }
    @IBAction func xButtonPressed() {
        UIView.animate(withDuration: 0.35, animations: {
            self.sortViewButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        }) { (true) in
            self.sortViewButton.isHidden = true
        }

        UIView.animate(withDuration: 0.35, animations: {
            self.sortViewContainer.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
        }) { (true) in
            self.sortViewContainer.isHidden = true
        }
    }
}

//Overriden functions/protocols
extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callOnViewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.rowHeight = tableView.frame.height / 8
        //Removes last line separator in table
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "goBackToStateView" else { return }
            if let stateView = segue.destination as? StateViewController {
                stateView.ownedStates = ownedStates
                stateView.unownedStates = unownedStates
        }
    }
    //Number of cells
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if purchased {
            return formattedTickets.count
        } else {
            return 10
        }
    }
    //Called for each cell when the cell is displayed
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Hide down arrow image if last cell is showing
        if indexPath.row == formattedTickets.count - 1 {
            self.downArrowImage.stopAnimating()
            UIView.animate(withDuration: 0.25, animations: {
                self.downArrowImage.alpha = 0
            })
        }
        
        return formatCell(tableView, cellForRowAt: indexPath)
    }
    //Called when a cell stops displaying (is dequeued)
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Show down arrow image if last cell isn't showing
        if indexPath.row == formattedTickets.count - 1 {
            self.downArrowImage.stopAnimating()
            UIView.animate(withDuration: 0.25, animations: {
                self.downArrowImage.alpha = 1
            })
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

//Private functions
extension MainViewController {
    private func goBackToStateView() {
        performSegue(withIdentifier: "goBackToStateView", sender: nil)
    }
    //Turns off other buttons
    private func updateSortByButtonImages(_ button: CustomButton) {
        if button.tag < 2 {
            for btn in sortOrderButtons {
                if button.tag != btn.tag {
                    btn.on = false
                } else {
                    btn.on = true
                }
            }
        } else {
            for btn in sortFieldButtons {
                if button.tag != btn.tag {
                    btn.on = false
                } else {
                    btn.on = true
                }
            }
        }
        
        sortOrderButtons[0].setImage(sortOrderButtons[0].image, for: .normal)
        sortOrderButtons[1].setImage(sortOrderButtons[1].image, for: .normal)
        sortFieldButtons[0].setImage(sortFieldButtons[0].image, for: .normal)
        sortFieldButtons[1].setImage(sortFieldButtons[1].image, for: .normal)
        sortFieldButtons[2].setImage(sortFieldButtons[2].image, for: .normal)
        sortFieldButtons[3].setImage(sortFieldButtons[3].image, for: .normal)
        sortFieldButtons[4].setImage(sortFieldButtons[4].image, for: .normal)
    }
    //Sorts table
    private func updateTable() {
        if sortOrderButtons[1].on {
            switch true {
            case sortFieldButtons[0].on:
                formattedTickets.sort { return $0.price > $1.price }
            case sortFieldButtons[1].on:
                formattedTickets.sort { return $0.number > $1.number }
            case sortFieldButtons[2].on:
                formattedTickets.sort { return $0.name > $1.name }
            case sortFieldButtons[3].on:
                formattedTickets.sort { return $0.topPrizesRemaining > $1.topPrizesRemaining }
            case sortFieldButtons[4].on:
                formattedTickets.sort { return $0.rank > $1.rank }
            default:
                print("Error in first switch statment in updateTable()")
            }
        } else {
            switch true {
            case sortFieldButtons[0].on:
                formattedTickets.sort { return $0.price < $1.price }
            case sortFieldButtons[1].on:
                formattedTickets.sort { return $0.number < $1.number }
            case sortFieldButtons[2].on:
                formattedTickets.sort { return $0.name < $1.name }
            case sortFieldButtons[3].on:
                formattedTickets.sort { return $0.topPrizesRemaining < $1.topPrizesRemaining }
            case sortFieldButtons[4].on:
                formattedTickets.sort { return $0.rank < $1.rank }
            default:
                print("Error in second switch statment in updateTable()")
            }
        }
        
        tableView.reloadData()
    }
    //Call in viewDidLoad
    private func callOnViewDidLoad() {
        //Sort by rank on load
        formattedTickets.sort { $0.rank < $1.rank }
        
        //Set which tickets are best in price range
        var temp = [Int]()
        for i in 0...formattedTickets.count - 1 {
            if temp.contains(formattedTickets[i].price) {
                formattedTickets[i].bestInPriceRange = false
            } else {
                formattedTickets[i].bestInPriceRange = true
            }
            temp.append(formattedTickets[i].price)
        }
        
        //Trim formatted tickets to last 10 items if not purchased
        if !purchased {
            var temp = [FormattedTicket]()
            for i in formattedTickets.count - 10...formattedTickets.count - 1 {
                temp.append(formattedTickets[i])
            }
            formattedTickets = temp
        }
        
        //Turn on correct buttons
        for btn in sortOrderButtons {
            if btn.tag == 0 {
                btn.on = true
            } else {
                btn.on = false
            }
        }
        for btn in sortFieldButtons {
            if btn.tag == 6 {
                btn.on = true
            } else {
                btn.on = false
            }
        }
        
        //Make sure sort buttons are sorted correctly
        sortOrderButtons.sort { return $0.tag < $1.tag }
        sortFieldButtons.sort { return $0.tag < $1.tag }
        
        //Create sort view container shadow
        sortViewContainer.layer.shadowColor = UIColor.black.cgColor
        sortViewContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        sortViewContainer.layer.shadowRadius = 12
        sortViewContainer.layer.shadowOpacity = 0.4
        
        //Set to see-through for animating
        sortViewButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        sortViewContainer.isHidden = true
        sortViewButton.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() //Dont show extra cells
        tableView.allowsSelection = false
    }
    //Formats each cell in the table
    private func formatCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TicketTableViewCell
        
        let index = indexPath.row
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        
        cell.priceLabel.text = "$" + String(formattedTickets[indexPath.row].price)
        cell.priceLabel.font = UIFont(name: cell.priceLabel.font.fontName, size: cellLabelFontSize + 3)
        
        //If game numbers exist, else
        if formattedTickets[index].useGameNumbers {
            cell.IDLabel.text = String(formattedTickets[index].number)
            cell.IDLabel.font = UIFont(name: cell.IDLabel.font.fontName, size: cellLabelFontSize)
        } else {    //Change constraints
            cell.IDLabel.isHidden = true
            IDUIImage.isHidden = true
            
            for constraint in nameUIImage.superview!.constraints {
                if constraint.identifier == "nameImgLeadingConstraint" {
                    constraint.isActive = false
                    let newConstraint = NSLayoutConstraint(item: nameUIImage, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nameUIImage.superview!, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 0.38, constant: 0)
                    newConstraint.isActive = true
                }
            }
            for constraint in cell.nameLabel.superview!.constraints {
                if constraint.identifier == "idLabelTrailingConstraint" {
                    constraint.isActive = false
                }
            }
            for constraint in cell.constraints {
                if constraint.identifier == "nameLblLeadingConstraint" {
                    constraint.isActive = false
                    let newConstraint = NSLayoutConstraint(item: cell.nameLabel, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 0.38, constant: 0)
                    newConstraint.isActive = true
                }
            }
        }
        
        cell.nameLabel.font = UIFont(name: cell.nameLabel.font.fontName, size: cellLabelFontSize)
        cell.topPrizesRemainingLabel.font = UIFont(name: cell.topPrizesRemainingLabel.font.fontName, size: cellLabelFontSize)
        cell.rankLabel.font = UIFont(name: cell.rankLabel.font.fontName, size: cellLabelFontSize)
        
        cell.nameLabel.text = formattedTickets[index].name
        cell.topPrizesRemainingLabel.text = formatter.string(from: NSNumber(value: formattedTickets[index].topPrizesRemaining))
        cell.rankLabel.text = String(formattedTickets[index].rank)
        
        if formattedTickets[index].bestInPriceRange {
            cell.rankLabel.textColor = UIColor(red: 0, green: 144 / 255, blue: 81 / 255, alpha: 1)
        } else {
            cell.rankLabel.textColor = UIColor.darkGray
        }
        
        return cell
    }
}
