//
//  OwnerViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-06-09.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase

class OwnerViewController: UIViewController {

    let db = Firestore.firestore()
    
    var userInfo = ("","", "", [])
    var storeID : String?
    @IBOutlet weak var storeNumLabel: UILabel!



    override func viewDidLoad() {
        super.viewDidLoad()
        storeNumLabel.text = "Store ID: \(storeID!)"

        // Do any additional setup after loading the view.
    }
    

    

    


    @IBAction func manageBookingsPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToBookings", sender: self)
    }
    
    @IBAction func setSchedulePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToManage", sender: self)
    }
    @IBAction func bookedAppointmentsPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToAppointments", sender: self)
    }
    @IBAction func manageItemsPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBookings"{
            let destinationVC = segue.destination as! ManageBookingsViewController
            destinationVC.storeID = storeID!
        } else if segue.identifier == "goToManage"{
            let destinationVC = segue.destination as! SetScheduleViewController
            destinationVC.storeID = storeID!
        } else if segue.identifier == "goToAppointments"{
            let destinationVC = segue.destination as! BookedAppointmentsViewController
            destinationVC.storeID = storeID!
        } else if segue.identifier == "goToItems"{
            let destinationVC = segue.destination as! ManageItemsViewController
            destinationVC.storeID = storeID!
            
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
