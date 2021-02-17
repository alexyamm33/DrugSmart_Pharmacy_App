//
//  AppointmentViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-06-04.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase
class AppointmentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alertRobot = AlertRobot(title: "Request Status", message: "Your Request is " + statusConverter.outputArray[indexPath.row].3, button: "Ok")
        self.present(alertRobot.creatAlert(), animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row]
        return cell
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        slotTextField.text = pickerData[row]
        slotTextField.resignFirstResponder()
    }
    
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var slotTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var requestsTableView: UITableView!
    
    
    

    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let db = Firestore.firestore()
    let dispatchGroup = DispatchGroup()
    
    var pickerView = UIPickerView()
    var pickerData = [String]()
    var tableData = [String]()
    var userName: String?
    var userEmail: String?
    var pharmacyName: String?
    var pharmacyEmail: String?
    
    var storeID = String()
    var dateString = ""
    var dateCheckerRobot = ValidDateCheckRobot(pendingDate: nil)
    var alertRobot = AlertRobot(title:"", message: "", button: "")
    var firestoreRobot = FirestoreRobot(collection: "bookings", document: "", field: "")
    var requestRobot = FirestoreRobot(collection: "stores", document: "", field: "Requests")
    var patientRobot = FirestoreRobot(collection: "accounts", document: "", field: "Requests")
    var statusConverter = StatusConverter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        loadAllRequests()
    }
    func createDatePicker(){
        dateTextField.textAlignment = .center
        slotTextField.textAlignment = .center
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneBtn = UIBarButtonItem(barButtonSystemItem:  .search, target: nil, action: #selector(dateSelected))
        toolbar.setItems([doneBtn], animated: true)
        dateTextField.inputAccessoryView = toolbar

        dateTextField.inputView = datePicker

        datePicker.datePickerMode = .date
    }
    @objc func dateSelected() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        dateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)

        dateString = dateTextField.text!
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let date = dateFormatter.date(from: dateString)
        dateCheckerRobot = ValidDateCheckRobot(pendingDate: date)
        let dateValidInfo = dateCheckerRobot.checkDate()
        if dateValidInfo.0 == false{
            alertRobot = AlertRobot(title:dateValidInfo.1, message: dateValidInfo.2, button: "Retry")
            self.present(alertRobot.creatAlert(), animated: true, completion: nil)
        }else{
            firestoreRobot.document = storeID
            firestoreRobot.field = dateString
          //type 0 refers to getting booking template
            dispatchGroup.enter()
            firestoreRobot.retrieveDataFromSource(type: 1, dispatchGroup:dispatchGroup)
            dispatchGroup.notify(queue: .main) {
                for slotString in self.firestoreRobot.sourceSlotsGivenDate {
                        var slotArray = slotString.components(separatedBy: ",")
                        if slotArray[1] == "true"{
                            self.pickerData.append(slotArray[0])
                    }
                }
                self.pickerView.delegate = self
                self.pickerView.dataSource = self
                self.slotTextField.inputView = self.pickerView
                self.slotTextField.text = ""
                self.slotTextField.insertText(self.pickerData[0])
            }


            
        }
    }
    
    func loadAllRequests() {
        dispatchGroup.enter()
        patientRobot.document = userEmail!
        patientRobot.retrieveDataFromSource(type: 3, dispatchGroup:dispatchGroup)
        dispatchGroup.notify(queue: .main) {
            self.statusConverter.requestArray = self.patientRobot.sourceRequestsGivenPatient
            self.statusConverter.arrayStrToArrayTuple()
            self.displayAllRequests()
        }
    }
    
    func displayAllRequests() {
        for tuple in statusConverter.outputArray{
            tableData.append([tuple.1,tuple.2].joined(separator: "-> "))
        }
        requestsTableView.delegate = self
        requestsTableView.dataSource = self
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {
        for i in 0..<(firestoreRobot.sourceSlotsGivenDate.count) {
            var slotArray = firestoreRobot.sourceSlotsGivenDate[i].components(separatedBy: ",")
            if slotArray[0] == slotTextField.text!{
                slotArray[1] = "pending"
                slotArray.append(pharmacyName!)
                slotArray.append(userName!)
                slotArray.append(userEmail!)
                
                firestoreRobot.sourceSlotsGivenDate[i] = slotArray.joined(separator: ",")
                slotArray.insert(dateTextField.text!, at: 0)
                requestRobot.document = storeID
                dispatchGroup.enter()
                requestRobot.retrieveDataFromSource(type: 2, dispatchGroup: dispatchGroup)
                dispatchGroup.notify(queue: .main) {
                    self.requestRobot.sourceRequestsGivenStoreID.append(slotArray.joined(separator: ","))
                    self.patientRobot.sourceRequestsGivenPatient.append(slotArray.joined(separator: ","))
                    self.firestoreRobot.updateSlotArrayGivenDate(newSlot: self.firestoreRobot.sourceSlotsGivenDate, dateString: self.dateTextField.text!)
                    self.requestRobot.updatePendingRequests(newRequests: self.requestRobot.sourceRequestsGivenStoreID)
                    self.patientRobot.updatePatientRequests(newRequests: self.patientRobot.sourceRequestsGivenPatient)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}



