//
//  PatientViewRequestsViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-08-05.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit

class PatientViewRequestsViewController: UIViewController {

    var patientRequests: [String]?
    
    @IBOutlet weak var requestsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestsLabel.text = patientRequests![0]
        // Do any additional setup after loading the view.
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
