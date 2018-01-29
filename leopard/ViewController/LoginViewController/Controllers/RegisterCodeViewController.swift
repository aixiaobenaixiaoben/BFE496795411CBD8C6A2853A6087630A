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
    
    var syusrinf: Syusrinf!
    var syvrymbl: Syvrymbl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyButton.isEnabled = false
        svmvrycodField.delegate = self
        if let tipsText = tipsLabel.text, let suimobile = syusrinf.suimobile {
            tipsLabel.text = tipsText + suimobile + "."
        }
    }

    @IBAction func checkValid(_ sender: UITextField) {
        if let svmvrycod = svmvrycodField.text, svmvrycod.verifyDigit(len: 6) {
            verifyButton.isEnabled = true
        } else {
            verifyButton.isEnabled = false
        }
    }
    
    @IBAction func onTapGestureRecognized(_ sender: UITapGestureRecognizer) {
        svmvrycodField.resignFirstResponder()
    }
    
    @IBAction func loadRegisterInfoView(_ sender: UIButton) {
        verifyButton.isEnabled = false
        syvrymbl = Syvrymbl()
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
                print("Error: " + error)
                let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            self.verifyButton.isEnabled = true
        }
    }
    
    @IBAction func resendVerifyCode(_ sender: UIButton) {
        Alamofire.request(SERVER + "user/sendRegisterVerifyCode.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            
            if Response<String>.success(response) {
                let alert = UIAlertController(title: nil, message: "Send verify code successfully, the code will expire after 10 minutes", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                print("Error: " + error)
                let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
