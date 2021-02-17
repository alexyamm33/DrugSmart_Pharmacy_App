//
//  FirestoreRobot.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-08-04.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import Foundation
import Firebase

class FirestoreRobot {
    //Initial required attributes
    var collection = ""
    var document = ""
    var field = ""
    //Optional input attributes
    var storeID = ""
    
    
    let db = Firestore.firestore()

    
    var sourceBookingTemplate = [String]()
    var sourceSlotsGivenDate = [String]()
    var sourceRequestsGivenStoreID = [String]()
    var sourceRequestsGivenPatient = [String]()
    
    var listItemsGivenStoreID = [String]()
    var itemInfoGivenItemID = [String]()
    
    var saleHistoryGivenStoreID = [String]() //Item_NameXQuantity, PatientName, Time
    
    init(collection:String, document:String, field:String) {
        self.collection = collection
        self.document = document
        self.field = field 
    }

        func retrieveDataFromSource(type: Int, dispatchGroup: DispatchGroup) {//Since cannot return inside closure, need to call other methods.
        let docRef = db.collection(collection).document(document)

        docRef.getDocument(source: .server) { (docums, error) in
            if let docums = docums{
                if type == 0{//Get Booking Template
                    self.sourceBookingTemplate = docums.get(self.field) as! [String]
                } else if type == 1 {//Get Slots given date
                    if docums.get(self.field) == nil{
                        self.db.collection(self.collection).document(self.document).setData([self.field:docums.get("Booking Template")], merge: true)
                        self.sourceSlotsGivenDate = docums.get("Booking Template") as! [String]
                    } else {
                        self.sourceSlotsGivenDate = docums.get(self.field) as! [String]
                    }
                } else if type == 2 {//Get all booking requests of a store
                    self.sourceRequestsGivenStoreID = docums.get(self.field) as! [String]
                } else if type == 3 {//Get all booking requested from patient
                    self.sourceRequestsGivenPatient = docums.get(self.field) as! [String]
//                    print(self.sourceRequestsGivenPatient)
                } else if type == 4 {//Get full list of items
                    self.listItemsGivenStoreID = docums.get(self.field) as! [String]
                } else if type == 5{
                    self.itemInfoGivenItemID = docums.get(self.field) as! [String]
                } else if type == 6{
                    self.saleHistoryGivenStoreID = docums.get(self.field) as! [String]
                }
                dispatchGroup.leave()
                

            }
        }
        
    }
    func updateBookingTemplate(startTime: Date, endTime: Date) {
        var template = [String]()
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        var slotStartTime = dateFormatter.string(from: startTime)
        var currentTime = startTime
        
        while currentTime < endTime {
            template.append(slotStartTime+",true")
            currentTime = currentTime + 1800
            slotStartTime = dateFormatter.string(from: currentTime)

        }
        
        db.collection(collection).document(document).setData([field:template])
    }
    
    func updateSlotArrayGivenDate(newSlot: [String], dateString: String) {//Change date array in booking
        db.collection(collection).document(document).setData([dateString:newSlot], merge: true)
    }
    
    func updatePendingRequests(newRequests: [String]) {
        db.collection(collection).document(document).setData([field:newRequests], merge: true)
    }
    
    func updatePatientRequests(newRequests: [String]) {
        db.collection(collection).document(document).setData([field:newRequests], merge: true)
    }

    func updateItemInfo() {
        db.collection(collection).document(document).setData([field:itemInfoGivenItemID], merge: true)
    }

    
    func updateStoreItemList() {
        db.collection(collection).document(document).setData([field:listItemsGivenStoreID], merge: true)
    }
    
    func deleteItem(itemName:String) {
        db.collection("items").document(document).updateData([
            itemName: FieldValue.delete(),
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}
