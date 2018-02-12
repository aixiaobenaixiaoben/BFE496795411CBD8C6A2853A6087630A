//
//  ModPasswordViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/2/12.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class ModPasswordViewController: UIViewController {

    @IBOutlet weak var oldSuipaswrdField: UITextField!
    @IBOutlet weak var newSuipaswrdField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oldSuipaswrdField.delegate = self
        newSuipaswrdField.delegate = self
        submitButton.isEnabled = false
    }
    
    @IBAction func checkValid(_ sender: Any) {
        messageLabel.text = nil
        if let suipaswrd = oldSuipaswrdField.text, suipaswrd.verifyPassword(), let newpaswrd = newSuipaswrdField.text, newpaswrd.verifyPassword() {
            submitButton.isEnabled = true
        } else {
            submitButton.isEnabled = false
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        submitButton.isEnabled = false
        self.navigationController?.view.makeToastActivity(.center)
        
        if let string = UserDefaults.standard.string(forKey: "Syusrinf"), let syusrinf = Syusrinf.deserialize(from: string) {
            syusrinf.suipaswrd = oldSuipaswrdField.text?.trimmingCharacters(in: .whitespaces).md5().uppercased()
            syusrinf.newpaswrd = newSuipaswrdField.text?.trimmingCharacters(in: .whitespaces).md5().uppercased()
            
            Alamofire.request(SERVER + "user/modPassword.action", method: .post, parameters: syusrinf.toJSON()).responseString { response in
                
                if let newSyusrinf = Response<Syusrinf>.data(response) {
                    newSyusrinf.suipaswrd = syusrinf.newpaswrd
                    UserDefaults.standard.set(newSyusrinf.toJSONString(), forKey: "Syusrinf")
                    
                    let alert = UIAlertController(title: NSLocalizedString("CHANGE_PASSWORD_SUCCESS", comment: "response after change password successfully"),
                                                  message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "ok button text"), style: .default, handler: { action in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                } else if let error = Response<String>.error(response) {
                    self.messageLabel.text = error
                    print("Error: " + error)
                }
                self.submitButton.isEnabled = true
                self.navigationController?.view.hideToastActivity()
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
