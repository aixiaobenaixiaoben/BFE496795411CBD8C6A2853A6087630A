//
//  ResetApplyViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/15.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class ResetApplyViewController: UIViewController {
    
    @IBOutlet weak var suimobileField: UITextField!
    @IBOutlet weak var sendVerifyButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendVerifyButton.isEnabled = false
        suimobileField.delegate = self
    }
    
    @IBAction func checkValid(_ sender: UITextField) {
        messageLabel.text = nil
        if let suimobile = suimobileField.text, suimobile.verifyDigit(len: 11) {
            sendVerifyButton.isEnabled = true
        } else {
            sendVerifyButton.isEnabled = false
        }
    }
    
    @IBAction func loadResetCodeView(_ sender: UIButton) {
        sendVerifyButton.isEnabled = false
        let syusrinf = Syusrinf()
        syusrinf.suimobile = suimobileField.text?.trimmingCharacters(in: .whitespaces)
        
        Alamofire.request(SERVER + "user/sendResetVerifyCode.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            
            if Response<String>.success(response) {
                let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                let resetCodeViewController = storyBoard.instantiateViewController(withIdentifier: "ResetCodeViewController") as! ResetCodeViewController
                resetCodeViewController.syusrinf = syusrinf
                self.present(resetCodeViewController, animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                self.messageLabel.text = error
                print("Error: " + error)
            }
            self.sendVerifyButton.isEnabled = true
        }
    }
    
    @IBAction func backToLogIn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
