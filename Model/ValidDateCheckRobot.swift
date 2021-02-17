//
//  ValidDateCheckRobot.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-07-04.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import Foundation

struct ValidDateCheckRobot {
    var pendingDate : Date?
    let dateFormatter = DateFormatter()
    let today = Date()
    func checkDate() -> (Bool, String, String) {
        var filterDateSubject = ""
        dateFormatter.dateFormat = "ccc"
        filterDateSubject = dateFormatter.string(from: pendingDate!)
        if filterDateSubject == "Sat" || filterDateSubject == "Sun"{
            return(false, "Error", "This store is closed on weekends")
        }
        if today >= pendingDate! {
            return(false, "Error", "Date unavailable for booking")
        }
        return(true, "", "")
        
    }
}
