//
//  RegisterApplyViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/15.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class RegisterApplyViewController: UIViewController {
    
    @IBOutlet weak var suimobileField: UITextField!
    @IBOutlet weak var sendVerifyButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var syusrinf: Syusrinf!

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
    
    @IBAction func onTapGestureRecognized(_ sender: UITapGestureRecognizer) {
        suimobileField.resignFirstResponder()
    }
    
    @IBAction func loadRegisterCodeVIew(_ sender: UIButton) {
        sendVerifyButton.isEnabled = false
        syusrinf = Syusrinf()
        syusrinf.suimobile = suimobileField.text?.trimmingCharacters(in: .whitespaces)
        
        Alamofire.request(SERVER + "user/sendRegisterVerifyCode.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            
            if Response<String>.success(response) {
                let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                let registerCodeViewController = storyBoard.instantiateViewController(withIdentifier: "RegisterCodeViewController") as! RegisterCodeViewController
                registerCodeViewController.syusrinf = self.syusrinf
                self.present(registerCodeViewController, animated: true, completion: nil)
                
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
