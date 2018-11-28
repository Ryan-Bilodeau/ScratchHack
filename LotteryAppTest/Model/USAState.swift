//
//  State.swift
//  LotteryAppTest
//
//  Created by Ryan  Bilodeau on 3/24/18.
//  Copyright © 2018 Ryan Bilodeau. All rights reserved.
//

import Foundation

struct USAState {
    let ID: String
    let purchased: Bool
    let state: StateE
    let name: String
    let abbreviation: String
    let url: String
    var expirationDate: Date?
    
    init?(ID: String, purchased: Bool, expirationDate: Date?) {
        switch ID {
        case "com.RyanBilodeau.ScratchHack.CaliforniaSubscription":
            self.state = StateE.california
            self.name = "California"
            self.abbreviation = "CA"
            self.url = "http://18.217.49.62/California/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.TexasSubscription":
            self.state = StateE.texas
            self.name = "Texas"
            self.abbreviation = "TX"
            self.url = "http://18.217.49.62/Texas/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.MaineSubscription":
            self.state = StateE.maine
            self.name = "Maine"
            self.abbreviation = "ME"
            self.url = "http://18.217.49.62/Maine/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.OhioSubscription":
            self.state = StateE.ohio
            self.name = "Ohio"
            self.abbreviation = "OH"
            self.url = "http://18.217.49.62/Ohio/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.NorthCarolinaSubscription":
            self.state = StateE.northCarolina
            self.name = "N. Carolina"
            self.abbreviation = "NC"
            self.url = "http://18.217.49.62/North_Carolina/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.NewJerseySubscription":
            self.state = StateE.newJersey
            self.name = "N. Jersey"
            self.abbreviation = "NJ"
            self.url = "http://18.217.49.62/New_Jersey/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.TennesseeSubscription":
            self.state = StateE.tennessee
            self.name = "Tennessee"
            self.abbreviation = "TN"
            self.url = "http://18.217.49.62/Tennessee/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.MissouriSubscription":
            self.state = StateE.missouri
            self.name = "Missouri"
            self.abbreviation = "MO"
            self.url = "http://18.217.49.62/Missouri/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.WisconsinSubscription":
            self.state = StateE.wisconsin
            self.name = "Wisconsin"
            self.abbreviation = "WI"
            self.url = "http://18.217.49.62/Wisconsin/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.ColoradoSubscription":
            self.state = StateE.colorado
            self.name = "Colorado"
            self.abbreviation = "CO"
            self.url = "http://18.217.49.62/Colorado/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.SouthCarolinaSubscription":
            self.state = StateE.southCarolina
            self.name = "S. Carolina"
            self.abbreviation = "SC"
            self.url = "http://18.217.49.62/South_Carolina/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.LouisianaSubscription":
            self.state = StateE.louisiana
            self.name = "Louisiana"
            self.abbreviation = "LA"
            self.url = "http://18.217.49.62/Louisiana/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.OregonSubscription":
            self.state = StateE.oregon
            self.name = "Oregon"
            self.abbreviation = "OR"
            self.url = "http://18.217.49.62/Oregon/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.OklahomaSubscription":
            self.state = StateE.oklahoma
            self.name = "Oklahoma"
            self.abbreviation = "OK"
            self.url = "http://18.217.49.62/Oklahoma/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.NewMexicoSubscription":
            self.state = StateE.newMexico
            self.name = "N. Mexico"
            self.abbreviation = "NM"
            self.url = "http://18.217.49.62/New_Mexico/getTickets.php"
        case "om.RyanBilodeau.ScratchHack.NebraskaSubscription":
            self.state = StateE.nebraska
            self.name = "Nebraska"
            self.abbreviation = "NE"
            self.url = "http://18.217.49.62/Nebraska/getTickets.php"
        case "com.RyanBilodeau.ScratchHack.IdahoSubscription":
            self.state = StateE.idaho
            self.name = "Idaho"
            self.abbreviation = "ID"
            self.url = "http://18.217.49.62/Idaho/getTickets.php"
        default:
            print("No matching state")
            return nil
        }
        self.ID = ID
        self.purchased = purchased
        self.expirationDate = expirationDate
    }
    
    static func getTestUnpurchasedStates() -> [USAState] {
        var tempStates = [USAState]()
        for id in IAPProduct.productIDs {
            tempStates.append(USAState(ID: id, purchased: false, expirationDate: nil)!)
        }
        return tempStates
    }
    
    static func getTestPurchasedStates() -> [USAState] {
        var tempStates = [USAState]()
        tempStates.append(USAState(ID: IAPProduct.productIDs[0], purchased: true, expirationDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()))!)
        tempStates.append(USAState(ID: IAPProduct.productIDs[1], purchased: true, expirationDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()))!)
        tempStates.append(USAState(ID: IAPProduct.productIDs[2], purchased: true, expirationDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()))!)
        tempStates.append(USAState(ID: IAPProduct.productIDs[3], purchased: true, expirationDate: Calendar.current.date(byAdding: .day, value: 44, to: Date()))!)
        tempStates.append(USAState(ID: IAPProduct.productIDs[4], purchased: true, expirationDate: Date())!)
        return tempStates
    }
    
    enum StateE {
        case california
        case texas
        case ohio
        case northCarolina
        case newJersey
        case tennessee
        case missouri
        case wisconsin
        case colorado
        case southCarolina
        case louisiana
        case oregon
        case oklahoma
        case newMexico
        case nebraska
        case idaho
        case maine
    }
}
