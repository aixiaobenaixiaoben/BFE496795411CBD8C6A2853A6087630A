//
//  ResetCodeViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/15.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class ResetCodeViewController: UIViewController {
    
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var svmvrycodField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    
    var syusrinf: Syusrinf!
    var syvrymbl: Syvrymbl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        svmvrycodField.delegate = self
        verifyButton.isEnabled = false
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
    
    @IBAction func loadResetInfoView(_ sender: UIButton) {
        verifyButton.isEnabled = false
        syvrymbl = Syvrymbl()
        syvrymbl.svmmobile = syusrinf.suimobile
        syvrymbl.svmvrycod = svmvrycodField.text?.trimmingCharacters(in: .whitespaces)
        
        Alamofire.request(SERVER + "user/resetVerifyCode.action", method: .post, parameters: syvrymbl.toJSON()).responseString {
            response in
            
            if let remoteSyusrinf = Response<Syusrinf>.data(response) {
                let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                let resetInfoViewController = storyBoard.instantiateViewController(withIdentifier: "ResetInfoViewController") as! ResetInfoViewController
                resetInfoViewController.syusrinf = remoteSyusrinf
                self.present(resetInfoViewController, animated: true, completion: nil)
                
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
    
    @IBAction func resendResetVerifyCode(_ sender: UIButton) {
        Alamofire.request(SERVER + "user/sendResetVerifyCode.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            
            if Response<String>.success(response) {
                //TODO: - 提示已经发送验证码，10分钟后过期
                let alert = UIAlertController(title: nil, message: "Resend verify code successfully, the code will expire after 10 minutes", preferredStyle: .alert)
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
