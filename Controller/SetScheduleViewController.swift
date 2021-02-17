//
//  SetScheduleViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-07-14.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase

class SetScheduleViewController: UIViewController {

    
    
    @IBOutlet weak var starTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    var firestoreRobot = FirestoreRobot(collection: "bookings", document: "", field: "Booking Template")
    var alerRobot = AlertRobot(title: "", message: "", button: "")
    
    var storeID = String()
    
    
    var startTime = Date()
    var endTime = Date()
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let dispatchGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        dateFormatter.dateFormat = "HH:mm"
        
//        firestoreRobot.document = storeID
//        dispatchGroup.enter()
//        firestoreRobot.retrieveDataFromSource(type: 0, dispatchGroup: dispatchGroup)
//        dispatchGroup.notify(queue: .main) {
//            var startTime = ""
//            var endTime = ""
//            startTime = self.firestoreRobot.sourceBookingTemplate[0]
//            endTime = self.firestoreRobot.sourceBookingTemplate[self.firestoreRobot.sourceBookingTemplate.count-1]
//            self.starTimeTextField.text = startTime.components(separatedBy: ",")[0]
//            self.endTimeTextField.text = endTime.components(separatedBy: ",")[0]
//        }

        // Do any additional setup after loading the view.
    }
    
    
    func createDatePicker(){
        starTimeTextField.textAlignment = .center
        endTimeTextField.textAlignment = .center
        
        starTimeTextField.inputView = datePicker
        endTimeTextField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem:  .search, target: nil, action: #selector(dateSelected))
        toolbar.setItems([doneBtn], animated: true)
        starTimeTextField.inputAccessoryView = toolbar
        endTimeTextField.inputAccessoryView = toolbar
        
        datePicker.datePickerMode = .time

    }
    @objc func dateSelected() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        if starTimeTextField.isFirstResponder{
            starTimeTextField.text = dateFormatter.string(from: datePicker.date)
            startTime = datePicker.date
        } else if endTimeTextField.isFirstResponder{
            endTimeTextField.text = dateFormatter.string(from: datePicker.date)
            endTime = datePicker.date
        }
        self.view.endEditing(true)
//
//        dateFormatter.timeZone = NSTimeZone() as TimeZone
//        dateFormatter.dateFormat = "MMM dd, yyyy"
//        let date = textField.date(from: dateString)
//        dateCheckerRobot = ValidDateCheckRobot(pendingDate: date)
//        let dateValidInfo = dateCheckerRobot.checkDate()
//        if dateValidInfo.0 == false{
//            alertRobot = AlertRobot(title:dateValidInfo.1, message: dateValidInfo.2, button: "Retry")
//            self.present(alertRobot.creatAlert(), animated: true, completion: nil)
//        }else{
//            getSlots()
//        }
        
    }
    
    @IBAction func setBtnPressed(_ sender: Any) {
        firestoreRobot.updateBookingTemplate(startTime: startTime, endTime: endTime)
        alerRobot = AlertRobot(title: "Warning", message: "Resetting appointment schedule will erase all previous appointments", button: "Ok")
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
