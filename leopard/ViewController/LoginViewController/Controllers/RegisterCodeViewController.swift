//
//  RegisterCodeViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/15.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class RegisterCodeViewController: UIViewController {
    
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var svmvrycodField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var syusrinf: Syusrinf!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyButton.isEnabled = false
        svmvrycodField.delegate = self
        if let tipsText = tipsLabel.text, let suimobile = syusrinf.suimobile {
            tipsLabel.text = tipsText + suimobile + "."
        }
    }

    @IBAction func checkValid(_ sender: UITextField) {
        messageLabel.text = nil
        if let svmvrycod = svmvrycodField.text, svmvrycod.verifyDigit(len: 6) {
            verifyButton.isEnabled = true
        } else {
            verifyButton.isEnabled = false
        }
    }
    
    @IBAction func loadRegisterInfoView(_ sender: UIButton) {
        verifyButton.isEnabled = false
        let syvrymbl = Syvrymbl()
        syvrymbl.svmmobile = syusrinf.suimobile
        syvrymbl.svmvrycod = svmvrycodField.text?.trimmingCharacters(in: .whitespaces)
        
        Alamofire.request(SERVER + "user/registerVerifyCode.action", method: .post, parameters: syvrymbl.toJSON()).responseString {
            response in
            
            if Response<String>.success(response) {
                let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                let registerInfoViewController = storyBoard.instantiateViewController(withIdentifier: "RegisterInfoViewController") as! RegisterInfoViewController
                registerInfoViewController.syusrinf = self.syusrinf
                self.present(registerInfoViewController, animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                self.messageLabel.text = error
                print("Error: " + error)
            }
            self.verifyButton.isEnabled = true
        }
    }
    
    @IBAction func resendVerifyCode(_ sender: UIButton) {
        Alamofire.request(SERVER + "user/sendRegisterVerifyCode.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            
            if Response<String>.success(response) {
                self.view.makeToast(NSLocalizedString("SEND_VERIFY_CODE_SUCCESSFULLY", comment: "message when send verify code which expires after 10 minutes"))
                
            } else if let error = Response<String>.error(response) {
                self.view.makeToast(NSLocalizedString("ERROR: ", comment: "preffix of error message") + error)
                print("Error: " + error)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
