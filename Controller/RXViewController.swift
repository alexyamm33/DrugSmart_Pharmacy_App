//
//  RXViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-05-28.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase
class RXViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    let db = Firestore.firestore()
    var userInfo = ("","", "", [])
    var storeID: String?
    var pharmacyName: String?
    var pharmacyEmail: String?
    var emailBody: String?
    var emailHeader: String?
    var userNotes = ""
    
    @IBOutlet weak var patientNotesTextField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var selectImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }
    

    @IBAction func albumButtonPressed(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        selectImage.image = image
    }

    @IBAction func sendButtonPressed(_ sender: Any) {
        if patientNotesTextField.text != nil{
            userNotes = patientNotesTextField.text!
        }
        emailBody = "<p>" + userInfo.1 + " sends a new RX</p>" + "<p>Notes: " + userNotes + "</p>" + "If there's any problem, Email them at " + userInfo.2 + "."
        emailHeader = userInfo.1 + " new RX"
        let email = EmailRobot(receiverName:pharmacyName!, receiverEmail:pharmacyEmail!, robotName: "Appointment Robot", robotEmail: "ayeh0330@gmail.com", robotPassword: "Mcibehs2021gm", header: emailHeader!, body: emailBody!)
        if let rxImage = selectImage.image{
            email.attachImage(image: rxImage)
            email.sendEmail()
            //Add alert to let user know rx is sent. 
        }else{
            let alertRobot = AlertRobot(title:"Error", message: "Please Attach an Image", button: "Ok")
            self.present(alertRobot.creatAlert(), animated: true, completion: nil)
        }
        
        




    }
}
