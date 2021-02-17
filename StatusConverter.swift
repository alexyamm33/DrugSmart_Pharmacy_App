//
//  StatusConverter.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-08-06.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import Foundation
import UIKit

class StatusConverter {
    //initial attributes
    var requestArray = [String]()
    
    //output attributes
    var outputArray: [(String,String,String,String)] = []//Name, Pharmacy, Date&Time, Status
    
    
//    init(requestArray: [String]) {
//        self.requestArray = requestArray
//    }
    
    func arrayStrToArrayTuple() {
        var requestTuple = ("","","","")
        var temArray = ["","","","","","",""] //Date, Year, Time, Status, pharmacy, name, email
        for i in 0..<(requestArray.count){
            temArray = requestArray[i].components(separatedBy: ",")
            requestTuple.0 = temArray[5]
            requestTuple.1 = temArray[4]
            requestTuple.2 = [temArray[0],temArray[1],temArray[2]].joined(separator: ",")
            requestTuple.3 = temArray[3]
            outputArray.append(requestTuple)
        }
    }
    
}
