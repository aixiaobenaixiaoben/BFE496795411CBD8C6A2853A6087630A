//
//  ModPhoneViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/2/1.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class ModPhoneViewController: UIViewController {
    
    @IBOutlet weak var suimobileField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    var syusrinf: Syusrinf!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        suimobileField.delegate = self
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @IBAction func checkValid(_ sender: Any) {
        messageLabel.text = nil
        if let suimobile = suimobileField.text, suimobile.verifyDigit(len: 11) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @IBAction func onTapGestureRecognized(_ sender: UITapGestureRecognizer) {
        suimobileField.resignFirstResponder()
    }
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Next(_ sender: Any) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        syusrinf = Syusrinf()
        syusrinf.suimobile = suimobileField.text?.trimmingCharacters(in: .whitespaces)
        
        Alamofire.request(SERVER + "user/sendModPhoneVerifyCode.action", method: .post, parameters: syusrinf.toJSON()).responseString { response in
            
            if Response<String>.success(response) {
                let storyBoard = UIStoryboard(name: "C", bundle: nil)
                let modPhoneVerifyVC = storyBoard.instantiateViewController(withIdentifier: "ModPhoneVerifyViewController") as! ModPhoneVerifyViewController
                modPhoneVerifyVC.syusrinf = self.syusrinf
                
                let button = UIBarButtonItem(title: NSLocalizedString("BACK", comment: "back button text"), style: .plain, target: nil, action: nil)
                self.navigationItem.backBarButtonItem = button
                
                self.navigationController?.pushViewController(modPhoneVerifyVC, animated: true)
                
            } else if let error = Response<String>.error(response) {
                self.messageLabel.text = error
                print("Error: " + error)
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}
