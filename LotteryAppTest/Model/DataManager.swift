//
//  DbManager.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/21/19.
//  Copyright © 2019 Ryan Bilodeau. All rights reserved.
//

import Foundation

class DataManager {
    static func updateDate(completion: @escaping (String?) -> Void) {
        let stringUrl = Strings.Url + "DateToUse.php"
        
        if let link = URL(string: stringUrl) {
            let data = try? Data(contentsOf: link)
            if data == nil {
                completion(nil)
                print("Couldn't data from url: " + stringUrl)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            if json == nil {
                completion(nil)
                print("Couldn't get json from data at url: " + stringUrl)
                return
            }
            
            if let object = json as? [Any] {
                for item in object as! [Dictionary<String, AnyObject>] {
                    completion(item["dateToUse"] as! String)
                    break
                }
            } else {
                completion(nil)
                print("Couldn't create object from json at url: " + stringUrl)
                return
            }
            
        } else {
            print("Couldn't access url")
        }
    }
    
    static func getTicketsFrom(url: String, completion: @escaping ([FormattedTicket]?) -> Void) {
        var tickets = [FormattedTicket]()
        
        if let link = URL(string: url) {
            let data = try? Data(contentsOf: link)
            if data == nil {
                completion(nil)
                print("Couldn't get data from url: " + url)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            if json == nil {
                completion(nil)
                print("Couldn't get json from data at url: " + url)
                return
            }
            
            if let object = json as? [Any] {
                for item in object as! [Dictionary<String, AnyObject>] {
                    let priceString = item["price"] as! String
                    let price: Int = Int(Double(priceString)!)
                    let name: String = item["name"] as! String
                    let odds: Double = Double(item["odds"] as! String)!
                    let oddsRank: Int = Int(item["oddsRank"] as! String)!
                    
                    var number: Int?
                    if (item["number"] as? NSNull) != nil {
                        number = nil
                    } else {
                        number = Int(item["number"] as! String)
                    }
                    
                    var prizesRemaining: Double?
                    if (item["prizesRemaining"] as? NSNull) != nil {
                        prizesRemaining = nil
                    } else if (item["prizesRemaining"] as! String) == " " {
                        prizesRemaining = nil
                    } else if (item["prizesRemaining"] as! String) == "" {
                        prizesRemaining = nil
                    } else {
                        prizesRemaining = Double(item["prizesRemaining"] as! String)! * 100
                    }
                    
                    var averageProfit: Double?
                    if (item["averageProfit"] as? NSNull) != nil {
                        averageProfit = nil
                    } else {
                        averageProfit = Double(item["averageProfit"] as! String)
                    }
                    
                    var statsRank: Int?
                    if (item["statsRank"] as? NSNull) != nil {
                        statsRank = nil
                    } else {
                        statsRank = Int(item["statsRank"] as! String)
                    }
                    
                    let ticket = FormattedTicket(price: price, number: number, name: name, odds: odds, prizesRemaining: prizesRemaining, averageProfit: averageProfit, oddsRank: oddsRank, statsRank: statsRank)
                    tickets.append(ticket)
                }
                completion(tickets)
            } else {
                completion(nil)
                print("Couldn't create object from json at url: " + url)
                return
            }
        } else {
            print("Couldn't access url")
        }
    }
}
