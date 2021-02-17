//
//  StoreNumberViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-06-04.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase
class StoreNumberViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var selectedTextField: UITextField!
    @IBOutlet weak var newStoreIdTextField: UITextField!
    @IBOutlet weak var addStoreBtn: UIButton!
    
   var pickerView = UIPickerView()
    var alertRobot = AlertRobot(title: "", message: "", button: "")
    var pickerData: [String] = [String]()
    var userInfo = ("","", "", [])
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerData = userInfo.3 as! [String]
        selectedTextField.inputView = pickerView
        selectedTextField.textAlignment = .center
        selectedTextField.placeholder = "Select Store"
        selectedTextField.insertText(pickerData[0])
        
        if userInfo.0 == "001"{
            newStoreIdTextField.isHidden = true
            addStoreBtn.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTextField.text = pickerData[row]
        selectedTextField.resignFirstResponder()

    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Signed out")
            self.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    @IBAction func goButtonPressed(_ sender: Any) {
        if userInfo.0 == "001"{
            self.performSegue(withIdentifier: "goToOwner", sender: self)
        }else if userInfo.0 == "000"{
            self.performSegue(withIdentifier: "goToCustomer", sender: self)
        }
    }
    @IBAction func addStoreBtnPressed(_ sender: Any) {
        if newStoreIdTextField.text == ""{
            alertRobot = AlertRobot(title: "Invalid Store", message: "The store doesn't exist", button: "Ok")
            present(self.alertRobot.creatAlert(), animated: true, completion: nil)
        } else {
            let docRef = db.collection("stores").document(newStoreIdTextField.text!)
            docRef.getDocument(source: .server) { (document, error) in
                if let document = document, document.exists {
                    self.userInfo.3.append(self.newStoreIdTextField.text!)
                    self.pickerData = self.userInfo.3 as! [String]
                    self.db.collection("accounts").document(self.userInfo.2).updateData(["Stores" : self.userInfo.3])
                    self.alertRobot = AlertRobot(title: "Store Added", message: "You have successfully added a new store", button: "Ok")
                    self.present(self.alertRobot.creatAlert(), animated: true, completion: nil)
                } else {
                    self.alertRobot = AlertRobot(title: "Invalid Store", message: "The store doesn't exist", button: "Ok")
                    self.present(self.alertRobot.creatAlert(), animated: true, completion: nil)
                }
            
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOwner"{
            let destinationVC = segue.destination as! OwnerViewController
            destinationVC.storeID = selectedTextField.text!
            destinationVC.userInfo = userInfo
        }else if segue.identifier == "goToCustomer"{
            let destinationVC = segue.destination as! PatientViewController
            destinationVC.storeID = selectedTextField.text!
            destinationVC.userInfo = userInfo
        }
    }
}



