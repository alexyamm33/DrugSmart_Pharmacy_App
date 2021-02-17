//
//  PatientViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-05-28.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase

class PatientViewController: UIViewController  {

    
    var userInfo = ("","", "", [])
    var storeID : String?
    var pharmacyName = ""
    var pharmacyEmail = ""
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        let docRef = self.db.collection("stores").document(storeID!)
        docRef.getDocument(source: .server) { (document, error) in
            if let document = document {
                self.pharmacyName = document.get("Store Name") as! String
                self.pharmacyEmail = document.get("Email") as! String
            }
        }

        
        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func appointButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueThreeD", sender: self)
    }
    
    @IBAction func medButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueThreeA", sender: self)
    }
    @IBAction func rxButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueThreeC", sender: self)
    }
    @IBAction func refillButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueThreeB", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueThreeC"{ //In the case where there may be multiple segues, if the identifier is eqaul to the one you want
            let destinationVC = segue.destination as! RXViewController
            destinationVC.storeID = storeID
            destinationVC.userInfo = userInfo
            destinationVC.pharmacyEmail = pharmacyEmail
            destinationVC.pharmacyName = pharmacyName

            
        }else if segue.identifier == "segueThreeD" {
            let destinationVC = segue.destination as! AppointmentViewController
            destinationVC.pharmacyEmail = pharmacyEmail
            destinationVC.pharmacyName = pharmacyName
            destinationVC.storeID = storeID!
            destinationVC.userEmail = userInfo.2
            destinationVC.userName = userInfo.1
            
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
