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
    @IBOutlet weak var messageLabel: UILabel!
    
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
        messageLabel.text = nil
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
                self.messageLabel.text = error
                print("Error: " + error)
            }
            self.verifyButton.isEnabled = true
        }
    }
    
    @IBAction func resendResetVerifyCode(_ sender: UIButton) {
        Alamofire.request(SERVER + "user/sendResetVerifyCode.action", method: .post, parameters: syusrinf.toJSON()).responseString {
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
