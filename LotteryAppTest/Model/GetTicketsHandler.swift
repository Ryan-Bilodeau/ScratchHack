//
//  GetTicketsHandler.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/27/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import Foundation

class GetTicketsHandler {
    let url: String
    
    init(url: String) {
        self.url = url
    }
    
    func getFormattedTickets(completion: @escaping ([FormattedTicket]?) -> Void) {
        let ticketURL: URL = URL(string: url)!
        var jsonTickets = [JSONTicket]()
        var formattedTickets = [FormattedTicket]()
        
        let task = URLSession.shared.dataTask(with: ticketURL) { (data, response, error) in
            do {
                guard let data = data  else { return }
                
                jsonTickets = try JSONDecoder().decode([JSONTicket].self, from: data)
                print(jsonTickets)
                for ticket in jsonTickets {
                    formattedTickets.insert(FormattedTicket(jsonTicket: ticket), at: formattedTickets.count)
                }
                completion(formattedTickets)
            } catch {
                print("Error in first call")
                completion(nil)
            }
        }
        
        task.resume()
    }
}
