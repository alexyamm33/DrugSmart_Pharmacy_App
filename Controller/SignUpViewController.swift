//
//  SignUpViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-06-04.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase
class SignUpViewController: UIViewController {

    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    @IBAction func joinButtonPressed(_ sender: UIButton) {
        
        if fullNameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != ""{
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
                if let e = error{
                    let alertRobot = AlertRobot(title:"Error", message: e.localizedDescription, button: "Retry")
                    self.present(alertRobot.creatAlert(), animated: true, completion: nil)
                } else{
                    let alertRobot = AlertRobot(title:"Success", message: "Account Created", button: "Ok")
                    self.present(alertRobot.creatAlert(), animated: true, completion: nil)
                    self.db.collection("accounts").document(self.emailTextField.text!).setData( [
                        "Access Lv": "000",
                        "Email": self.emailTextField.text!,
                        "Name" : self.fullNameTextField.text!,
                        "Stores": []
                    ])
                }
            }
        }else {
            let alertRobot = AlertRobot(title:"Error", message: "Please fill in all information!", button: "Retry")
            self.present(alertRobot.creatAlert(), animated: true, completion: nil)
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
