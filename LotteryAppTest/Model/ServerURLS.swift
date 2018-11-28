
//
//  ServerURLS.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/1/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import UIKit
import Foundation

class ServerURLS {
    static let ticketsNormal = URL(string: "http://18.217.49.62/Maine/getTickets.php")
    static let ticketsMinusTP = URL(string: "http://18.217.49.62/Maine/getTicketsMinusTP.php")
    static let ticketInfo = URL(string: "http://18.217.49.62/Maine/getTicketInfo.php")
    
    static func getFormattedTickets(completion: @escaping ([FormattedTicket]?) -> Void) {
        var jsonTickets = [JSONTicket]()
        var jsonTicketInfo = [JSONTicketInfo]()
        var formattedTickets = [FormattedTicket]()
        var formattedTicketInfo = [FormattedTicketInfo]()
        
        let task = URLSession.shared.dataTask(with: ticketsNormal!) { (data, response, error) in
            do {
                jsonTickets = try JSONDecoder().decode([JSONTicket].self, from: data!)
                for ticket in jsonTickets {
                    formattedTickets.insert(FormattedTicket(jsonTicket: ticket), at: formattedTickets.count)
                }
                URLSession.shared.dataTask(with: ticketInfo!, completionHandler: { (dat, resp, err) in
                    do {
                        jsonTicketInfo = try JSONDecoder().decode([JSONTicketInfo].self, from: dat!)
                        for ticket in jsonTicketInfo {
                            formattedTicketInfo.insert(FormattedTicketInfo(jsonTicketInfo: ticket), at: formattedTicketInfo.count)
                        }
                        
                        var i = 0
                        var j = 0
                        var done = false
                        while i < formattedTickets.count {
                            while !done {
                                if formattedTickets[i].price == formattedTicketInfo[j].price {
                                    formattedTickets[i].ticketInfo = formattedTicketInfo[j]
                                    done = true
                                }
                                j += 1
                            }
                            i += 1
                            j = 0
                            done = false
                        }
                        completion(formattedTickets)
                    } catch {
                        print("Error in second call")
                        completion(nil)
                    }
                }).resume()
            } catch {
                print("Error in first call")
                completion(nil)
            }
        }
        
        task.resume()
    }
}
