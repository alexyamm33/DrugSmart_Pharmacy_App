//
//  BookedAppointmentsViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-08-17.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase

class BookedAppointmentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alertRobot = AlertRobot(title: "Appointment With", message: tableData[indexPath.row][1], button: "Ok")
        self.present(alertRobot.creatAlert(), animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row][0]
        return cell
    }

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var bookedAppointmentsTableView: UITableView!
    
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let db = Firestore.firestore()
    let dispatchGroup = DispatchGroup()
    
    
    var storeID: String?
    var dateString = ""
    var tableData = [[String]]()
    
    
    var firestoreRobot = FirestoreRobot(collection: "bookings", document: "", field: "")
    var alertRobot = AlertRobot(title: "", message: "", button: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        

        // Do any additional setup after loading the view.
    }
    func createDatePicker(){
        dateTextField.textAlignment = .center
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
        firestoreRobot.document = storeID!
        firestoreRobot.field = dateString
        dispatchGroup.enter()
        firestoreRobot.retrieveDataFromSource(type: 1, dispatchGroup: dispatchGroup)
        dispatchGroup.notify(queue: .main){
            for string in self.firestoreRobot.sourceSlotsGivenDate{
                let status = String(string.split(separator: ",")[1])
                if status == "booked"{
                    let time = String(string.split(separator: ",")[0])
                    let patient = String(string.split(separator: ",")[3])
                    let slot = [self.dateString,time].joined(separator: "->")
                    self.tableData.append([slot,patient])
                }
            }
            if self.tableData.count == 0{
                self.alertRobot = AlertRobot(title: "No Appointments", message: "There are no appointments on this date", button: "Ok")
                self.present(self.alertRobot.creatAlert(), animated: true, completion: nil)
            } else {
                self.bookedAppointmentsTableView.delegate = self
                self.bookedAppointmentsTableView.dataSource = self
            }
        }
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
