//
//  NewItemViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-08-18.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class NewItemViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var storeID: String?
    var itemName: String?
    var imageUrl: String?
    var newItemCheck: Bool?
    var newImageCheck: Bool?
    

    
    @IBOutlet weak var itemImageOne: UIImageView!

    var imageData = Data()

    
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var firestoreRobot = FirestoreRobot(collection: "items", document: "", field: "")
    let dispatchGroup = DispatchGroup()
    let storage = Storage.storage().reference()
    
    
    override func viewDidLoad() {
        if !(newItemCheck!){
            editItem()
            super.viewDidLoad()
        } else {
            super.viewDidLoad()
        }

        // Do any additional setup after loading the view.
    }
    @IBAction func newImageBtnPressed(_ sender: Any) {
        let vc = UIImagePickerController()

        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }

        // print out the image size as a test
        imageData = image.pngData()!
        itemImageOne.image = image
        
    }
    func loadImageFromStorage() {
        let url = URL(string: imageUrl!)
        let task = URLSession.shared.dataTask(with: url!) { (data, _, error) in
            guard let data = data, error == nil else{
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.itemImageOne.image = image
            }
        }
        task.resume()
        
    }
    func uploadToCloud(imageData: Data, fileName: String, dispatchGroup: DispatchGroup) {
        storage.child(storeID!+"/"+fileName).putData(imageData, metadata: nil) { (_, error) in
            guard error == nil else{
                print("Failed")
                return
            }
            self.storage.child(self.storeID!+"/"+fileName).downloadURL { (url, err) in
                self.imageUrl = url?.absoluteString
                print(self.imageUrl)
                dispatchGroup.leave()
            }
        }
    }
    
    func editItem() {
        firestoreRobot.document = storeID!
        firestoreRobot.field = itemName!
        dispatchGroup.enter()
        firestoreRobot.retrieveDataFromSource(type: 5, dispatchGroup: dispatchGroup)
        dispatchGroup.notify(queue: .main){
            self.itemTitleTextField.text = self.firestoreRobot.itemInfoGivenItemID[0]
            self.quantityTextField.text = self.firestoreRobot.itemInfoGivenItemID[1]
            self.priceTextField.text = self.firestoreRobot.itemInfoGivenItemID[2]
            self.descriptionTextView.text = self.firestoreRobot.itemInfoGivenItemID[3]
            self.imageUrl = self.firestoreRobot.itemInfoGivenItemID[4]
            self.loadImageFromStorage()
            //Add the two image
        }
    }
    
    
    func uploadNewItem() {
        firestoreRobot.document = storeID!
        firestoreRobot.field = itemTitleTextField.text!
        firestoreRobot.itemInfoGivenItemID = [itemTitleTextField.text!,quantityTextField.text!, priceTextField.text!, descriptionTextView.text,imageUrl!]
        firestoreRobot.updateItemInfo()
        firestoreRobot.collection = "stores"
        firestoreRobot.document = storeID!
        firestoreRobot.field = "Items"
        dispatchGroup.enter()
        firestoreRobot.retrieveDataFromSource(type: 4, dispatchGroup: dispatchGroup)
        dispatchGroup.notify(queue: .main){
            self.firestoreRobot.listItemsGivenStoreID.append(self.itemTitleTextField.text!)
            self.firestoreRobot.updateStoreItemList()
        }
    }
    
    func editOldItem() {
        firestoreRobot.field = itemTitleTextField.text!
        firestoreRobot.itemInfoGivenItemID = [itemTitleTextField.text!,quantityTextField.text!, priceTextField.text!, descriptionTextView.text,imageUrl!]
        firestoreRobot.deleteItem(itemName: itemName!)
        firestoreRobot.updateItemInfo()
        firestoreRobot.collection = "stores"
        firestoreRobot.document = storeID!
        firestoreRobot.field = "Items"
        dispatchGroup.enter()
        firestoreRobot.retrieveDataFromSource(type: 4, dispatchGroup: dispatchGroup)
        dispatchGroup.notify(queue: .main){
            if self.itemTitleTextField.text! != self.itemName{
                for i in 0..<self.firestoreRobot.listItemsGivenStoreID.count{
                    if self.firestoreRobot.listItemsGivenStoreID[i] == self.itemName{
                        self.firestoreRobot.listItemsGivenStoreID[i] = self.itemTitleTextField.text!
                    }
                }
                self.firestoreRobot.updateStoreItemList()
            }
        }
        
    }

    
    @IBAction func uploadPressed(_ sender: Any) {
        dispatchGroup.enter()
        uploadToCloud(imageData: imageData, fileName: itemName!+".png",dispatchGroup: dispatchGroup)
        dispatchGroup.notify(queue: .main){
            if self.newItemCheck! == true{
                self.uploadNewItem()
            } else if self.newItemCheck! == false{
                self.editOldItem()
            }
            self.dismiss(animated: true, completion: nil)
            self.view.removeFromSuperview()
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
