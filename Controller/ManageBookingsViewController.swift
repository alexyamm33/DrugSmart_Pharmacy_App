//
//  ManageBookingsViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-07-06.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase

class ManageBookingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRequestNumber = Int(tableData[indexPath.row][1])!
        selectedTableDataNumber = indexPath.row
        nameDateandTimeString = tableData[indexPath.row][0]
        dateString = nameDateandTimeString.split(separator: ",")[1] + "," + nameDateandTimeString.split(separator: ",")[2]
        timeString = String(nameDateandTimeString.split(separator: ",")[3])
        print(dateString, timeString)
        alertRobot = AlertRobot(title: "New Request", message: [statusConverter.outputArray[indexPath.row].0,statusConverter.outputArray[indexPath.row].2].joined(separator: "->"), button: "Confirm")
        alertRobot.buttonTwo = "Back"
        alertRobot.buttonThree = "Decline"
        dispatchGroup.enter()
        self.present(alertRobot.multipleButtons(dispatchGroup:dispatchGroup), animated: true, completion: nil)
        dispatchGroup.notify(queue: .main){
            self.respondToRequest()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row][0]
        return cell
    }
    
    
    let dispatchGroup = DispatchGroup()
    var selectedRequestNumber = 0
    var selectedTableDataNumber = 0
    var nameDateandTimeString = ""
    var dateString = ""
    var timeString = ""
    var oldRequest = ""
    var newRequest = ""
    var storeID: String?
    var updatedRequest = ""
    var tableData = [[String]]()
    
    @IBOutlet weak var requestsTableView: UITableView!
    
    var ownerRobot = FirestoreRobot(collection: "stores", document: "", field: "Requests")
    var patientRobot = FirestoreRobot(collection: "accounts", document: "", field: "Requests")
    var bookingRobot = FirestoreRobot(collection: "bookings", document: "", field: "")
    var alertRobot = AlertRobot(title: "", message: "", button: "")
    var statusConverter = StatusConverter()
    
    
    override func viewDidLoad() {
        loadAllRequests()
    }
    
    
    func loadAllRequests() {
        tableData = []
        statusConverter.outputArray = []
        dispatchGroup.enter()
        ownerRobot.document = storeID!
        ownerRobot.retrieveDataFromSource(type: 2, dispatchGroup:dispatchGroup)
        dispatchGroup.notify(queue: .main) {
            self.statusConverter.requestArray = self.ownerRobot.sourceRequestsGivenStoreID
            self.statusConverter.arrayStrToArrayTuple()
            print(self.statusConverter.outputArray)
            self.displayAllRequests()
        }
    }
    
    func displayAllRequests() {
        for i in 0..<(statusConverter.outputArray.count){
            if statusConverter.outputArray[i].3 == "pending"{
                tableData.append([[statusConverter.outputArray[i].0,statusConverter.outputArray[i].2].joined(separator: ","),String(i)])
            }
        }
        requestsTableView.reloadData()
        requestsTableView.delegate = self
        requestsTableView.dataSource = self
    }
    
    func respondToRequest() {
        if alertRobot.buttonNumberClicked! == 3{
            declineRequest()
        } else if alertRobot.buttonNumberClicked! == 2{
            loadAllRequests()
        } else if alertRobot.buttonNumberClicked! == 1{
            approveRequest()
        }
    }
    
    func approveRequest() {
        //pharmacy
        oldRequest = ownerRobot.sourceRequestsGivenStoreID[selectedRequestNumber]
        newRequest = oldRequest.replacingOccurrences(of: "pending", with: "booked")
        let patientEmail = oldRequest.split(separator: ",")[6]
        ownerRobot.sourceRequestsGivenStoreID[selectedRequestNumber] = newRequest
        
        //patient
        patientRobot.document = String(patientEmail)
        dispatchGroup.enter()
        patientRobot.retrieveDataFromSource(type: 3, dispatchGroup: dispatchGroup)
        dispatchGroup.notify(queue: .main) {
            for i in 0..<(self.patientRobot.sourceRequestsGivenPatient.count){
                if self.patientRobot.sourceRequestsGivenPatient[i] == self.oldRequest{
                    self.patientRobot.sourceRequestsGivenPatient[i] = self.newRequest
                }
            }
            self.patientRobot.updatePatientRequests(newRequests: self.patientRobot.sourceRequestsGivenPatient)
            self.ownerRobot.updatePendingRequests(newRequests: self.ownerRobot.sourceRequestsGivenStoreID)
            self.modifyBookingSlots(status: "booked")
        }
        
    }
    
    func declineRequest(){
        //pharmacy
        oldRequest = ownerRobot.sourceRequestsGivenStoreID[selectedRequestNumber]
        newRequest = oldRequest.replacingOccurrences(of: "pending", with: "declined")
        ownerRobot.sourceRequestsGivenStoreID.remove(at: selectedRequestNumber)
        
        //patient
        let patientEmail = oldRequest.split(separator: ",")[6]
        patientRobot.document = String(patientEmail)
        dispatchGroup.enter()
        patientRobot.retrieveDataFromSource(type: 3, dispatchGroup: dispatchGroup)
        dispatchGroup.notify(queue: .main){
            for i in 0..<(self.patientRobot.sourceRequestsGivenPatient.count){
                if self.patientRobot.sourceRequestsGivenPatient[i] == self.oldRequest{
                    self.patientRobot.sourceRequestsGivenPatient[i] = self.newRequest
                }
            }
            self.patientRobot.updatePatientRequests(newRequests: self.patientRobot.sourceRequestsGivenPatient)
            self.ownerRobot.updatePendingRequests(newRequests: self.ownerRobot.sourceRequestsGivenStoreID)
            self.modifyBookingSlots(status: "declined")
        }
    }
    
    func modifyBookingSlots(status:String) {
        bookingRobot.document = storeID!
        bookingRobot.field = dateString
        dispatchGroup.enter()
        bookingRobot.retrieveDataFromSource(type: 1, dispatchGroup: dispatchGroup)
        dispatchGroup.notify(queue: .main) {
            for i in 0..<(self.bookingRobot.sourceSlotsGivenDate.count){
                var slotsArray = self.bookingRobot.sourceSlotsGivenDate[i].split(separator: ",")
                if slotsArray[0] == self.timeString{
                    if status == "declined"{
                        self.bookingRobot.sourceSlotsGivenDate[i] = self.timeString + ",true"
                    } else if status == "booked"{
                        slotsArray[1] = "booked"
                        self.bookingRobot.sourceSlotsGivenDate[i] = slotsArray.joined(separator: ",")
                    }
                }
            }
            self.bookingRobot.updateSlotArrayGivenDate(newSlot: self.bookingRobot.sourceSlotsGivenDate, dateString: self.dateString)
            self.loadAllRequests()
        }
    }
    
    //1: Approve, 2: Decline, 3:Do Nothing and Go Back
    //Change booking, pending->booked or pending->Tempalte
    //Change account(patient), pending->booked or declined
    //Change store, pending-> booked or erase completely
}
