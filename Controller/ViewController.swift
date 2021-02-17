//
//  ViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-05-25.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UIViewController, UITextFieldDelegate {
    

    let db = Firestore.firestore()
    var userInfo = ("","", "", [])
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tap)
        usernameTextField.delegate = self
    }
    @IBAction func signUpPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToSignIn", sender: self)
    }
    @IBAction func goButtonPressed(_ sender: Any) {
        if let email = usernameTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
                if let e = error {
                    let alertRobot = AlertRobot(title:"Error", message: e.localizedDescription, button: "Retry")
                    self.present(alertRobot.creatAlert(), animated: true, completion: nil)
                } else{
                    let docRef = self.db.collection("accounts").document(email)
                    docRef.getDocument(source: .server) { (document, error) in
                        if let document = document {
                            self.userInfo = (document.get("Access Lv") as! String, document.get("Name") as! String,document.get("Email") as! String,document.get("Stores") as! Array)
                            self.performSegue(withIdentifier: "goToSelect", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSelect"{ //In the case where there may be multiple segues, if the identifier is eqaul to the one you want
            let destinationVC = segue.destination as! StoreNumberViewController
            destinationVC.userInfo = userInfo
        }
    }
}

