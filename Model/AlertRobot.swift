//
//  AlertRobot.swift
//  pharmacy
//
//  Created by Alex Yeh on 2020-06-25.
//  Copyright © 2020 Alex Yeh. All rights reserved.
//

import UIKit

class AlertRobot {
    var title: String?
    var message: String?
    var button: String?
    
    var buttonTwo: String?
    var buttonThree: String?
    
    var buttonNumberClicked: Int?

    
    init(title: String, message: String, button: String) {
        self.title = title
        self.message = message
        self.button = button
    }
    
    func creatAlert ()->UIAlertController{
        let alert = UIAlertController(title: title!, message: message!, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button!, style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        return alert
    }
    
    func multipleButtons(dispatchGroup:DispatchGroup) -> UIAlertController {
        let alert = UIAlertController(title: title!, message: message!, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button!, style: UIAlertAction.Style.default, handler: { (action) in
            self.buttonNumberClicked = 1
            alert.dismiss(animated: true, completion: nil)
            dispatchGroup.leave()
        }))
        alert.addAction(UIAlertAction(title: buttonTwo!, style: UIAlertAction.Style.cancel, handler: { (action) in
            self.buttonNumberClicked = 2
            alert.dismiss(animated: true, completion: nil)
            dispatchGroup.leave()
        }))
        alert.addAction(UIAlertAction(title: buttonThree!, style: UIAlertAction.Style.destructive, handler: { (action) in
            self.buttonNumberClicked = 3
            alert.dismiss(animated: true, completion: nil)
            dispatchGroup.leave()
        }))
        return alert
    }
    
}
