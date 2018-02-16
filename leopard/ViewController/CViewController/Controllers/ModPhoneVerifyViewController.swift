//
//  ModPhoneVerifyViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/2/6.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class ModPhoneVerifyViewController: UIViewController {
    
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var svmvrycodField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    var syusrinf: Syusrinf!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false
        svmvrycodField.delegate = self
        if let tipsText = tipsLabel.text, let suimobile = syusrinf.suimobile {
            tipsLabel.text = tipsText + suimobile + "."
        }
    }
    
    override func shouldPopOnBackButton() -> Bool {
        let alert = UIAlertController(title: NSLocalizedString("CONFIRM_GO_BACK", comment: "confirm title before go back"), message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "cancel button text"), style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: NSLocalizedString("CONFIRM", comment: "confirm button text"), style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        return false
    }
    
    @IBAction func checkValid(_ sender: Any) {
        messageLabel.text = nil
        if let svmvrycod = svmvrycodField.text, svmvrycod.verifyDigit(len: 6) {
            submitButton.isEnabled = true
        } else {
            submitButton.isEnabled = false
        }
    }
    
    @IBAction func Submit(_ sender: Any) {
        submitButton.isEnabled = false
        let syvrymbl = Syvrymbl()
        syvrymbl.svmmobile = syusrinf.suimobile
        syvrymbl.svmvrycod = svmvrycodField.text?.trimmingCharacters(in: .whitespaces)
        
        if let syusrinfString = UserDefaults.standard.string(forKey: "SYUSRINF"), let loginSyusrinf = Syusrinf.deserialize(from: syusrinfString) {
            syusrinf.suiverson = loginSyusrinf.suiverson
        }
        
        let parameter = syusrinf.toJSON()?.merging(syvrymbl.toJSON()!) { (current, _) in current }
        Alamofire.request(SERVER + "user/modPhoneVerifyCode.action", method: .post, parameters: parameter).responseString { response in
            
            if let newSyusrinf = Response<Syusrinf>.data(response) {
                
                if let syusrinfString = UserDefaults.standard.string(forKey: "SYUSRINF"), let loginSyusrinf = Syusrinf.deserialize(from: syusrinfString) {
                    newSyusrinf.suipaswrd = loginSyusrinf.suipaswrd
                    UserDefaults.standard.set(newSyusrinf.toJSONString(), forKey: "SYUSRINF")
                }
                
                let alert = UIAlertController(title: NSLocalizedString("CHANGE_MOBILE_SUCCESS", comment: "response after change mobile successfully"),
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
        }
    }
    
    @IBAction func resendVerifyCode(_ sender: Any) {
        Alamofire.request(SERVER + "user/sendModPhoneVerifyCode.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            
            if Response<String>.success(response) {
                self.view.makeToast(NSLocalizedString("SEND_VERIFY_CODE_SUCCESSFULLY", comment: "message when send verify code which expires after 10 minutes"))
                
            } else if let error = Response<String>.error(response) {
                self.view.makeToast(NSLocalizedString("ERROR: ", comment: "preffix of error message") + error)
                print("Error: " + error)
            }
        }
    }
    
}
