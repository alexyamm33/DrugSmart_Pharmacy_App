//
//  ManageItemsViewController.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-08-17.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit

class ManageItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTransactionTextField.text = pickerData[row]
        selectedTransactionTextField.resignFirstResponder()
        //Alert
        let alertRobot = AlertRobot(title: "Order Record", message: firestoreRobot.saleHistoryGivenStoreID[row], button: "Ok")
        self.present(alertRobot.creatAlert(), animated: true, completion: nil)
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemName = tableData[indexPath.row]
        newItemCheck = false
        self.performSegue(withIdentifier: "goToAddItem", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row]
        return cell
    }
    
    var storeID: String?
    var itemName = ""
    var newItemCheck = false
    
    var tableData = [String]()
    var pickerData: [String] = [String]()

    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var selectedTransactionTextField: UITextField!
    
    
    let dispatchGroup = DispatchGroup()
    var pickerView = UIPickerView()
    var firestoreRobot = FirestoreRobot(collection: "stores", document: "", field: "Items")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayAllItems()
        
        // Do any additional setup after loading the view.
    }
    
    func displayAllItems() {
        firestoreRobot.document = storeID!
        dispatchGroup.enter()
        firestoreRobot.retrieveDataFromSource(type: 4, dispatchGroup: dispatchGroup)
        dispatchGroup.notify(queue: .main){
            self.tableData = self.firestoreRobot.listItemsGivenStoreID
            self.itemsTableView.delegate = self
            self.itemsTableView.dataSource = self
            
        }
    }
    
    @IBAction func loadSaleHistoryPressed(_ sender: Any) {
        firestoreRobot = FirestoreRobot(collection: "stores", document: storeID!, field: "Sale History")
        dispatchGroup.enter()
        firestoreRobot.retrieveDataFromSource(type: 6, dispatchGroup: dispatchGroup)
        dispatchGroup.notify(queue: .main){
            for sale in self.firestoreRobot.saleHistoryGivenStoreID{
                self.pickerData.append(String(sale.split(separator: ",")[0]))
            }
            self.selectedTransactionTextField.inputView = self.pickerView
            self.selectedTransactionTextField.textAlignment = .center
            self.pickerView.delegate = self
            self.pickerView.dataSource = self

        }
        
    }
    
    
    @IBAction func newItemPressed(_ sender: Any) {
        newItemCheck = true
        self.performSegue(withIdentifier: "goToAddItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddItem"{
            let destinationVC = segue.destination as! NewItemViewController
            destinationVC.storeID = storeID
            destinationVC.itemName = itemName
            destinationVC.newItemCheck = newItemCheck
        }
    }
    @IBAction func reloadPressed(_ sender: Any) {
        tableData = []
        self.itemsTableView.reloadData()
        displayAllItems()
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
