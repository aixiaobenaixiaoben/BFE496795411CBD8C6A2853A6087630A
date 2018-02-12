//
//  ResetInfoViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/15.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class ResetInfoViewController: UIViewController {
    
    @IBOutlet weak var suipaswrdField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var syusrinf: Syusrinf!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        suipaswrdField.delegate = self
        resetButton.isEnabled = false
    }
    
    @IBAction func checkValid(_ sender: UITextField) {
        messageLabel.text = nil
        if let suipaswrd = suipaswrdField.text, suipaswrd.verifyPassword() {
            resetButton.isEnabled = true
        } else {
            resetButton.isEnabled = false
        }
    }
    
    @IBAction func textFieldDoneEditing(_ sender: UITextField) {
        suipaswrdField.resignFirstResponder()
    }
    
    @IBAction func loadResetEndView(_ sender: UIButton) {
        resetButton.isEnabled = false
        syusrinf.suipaswrd = suipaswrdField.text?.trimmingCharacters(in: .whitespaces).md5().uppercased()
        
        Alamofire.request(SERVER + "user/resetPassword.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            
            if Response<String>.success(response) {
                let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                let resetEndViewController = storyBoard.instantiateViewController(withIdentifier: "ResetEndViewController") as! ResetEndViewController
                self.present(resetEndViewController, animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                self.messageLabel.text = error
                print("Error: " + error)
            }
            self.resetButton.isEnabled = true
        }
    }
    
    @IBAction func backToLogIn(_ sender: UIButton) {
        var rootVC = self.presentingViewController!
        while !rootVC.isKind(of: LoginViewController.self), let parent = rootVC.presentingViewController {
            rootVC = parent
        }
        rootVC.dismiss(animated: true, completion: nil)
    }
    
}
