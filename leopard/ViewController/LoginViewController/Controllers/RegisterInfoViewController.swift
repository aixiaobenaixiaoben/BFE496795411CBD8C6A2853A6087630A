//
//  RegisterInfoViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/15.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class RegisterInfoViewController: UIViewController {
    
    @IBOutlet weak var suiusrnamField: UITextField!
    @IBOutlet weak var suipaswrdField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var syusrinf: Syusrinf!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.isEnabled = false
        suiusrnamField.delegate = self
        suipaswrdField.delegate = self
    }
    
    @IBAction func checkValid(_ sender: UITextField) {
        if let suiusrnam = suiusrnamField.text, suiusrnam.verifyUsername(), let suipaswrd = suipaswrdField.text, suipaswrd.verifyPassword() {
            registerButton.isEnabled = true
        } else {
            registerButton.isEnabled = false
        }
    }
    
    @IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func onTapGestureRecognized(_ sender: UITapGestureRecognizer) {
        suiusrnamField.resignFirstResponder()
        suipaswrdField.resignFirstResponder()
    }
    
    @IBAction func loadRegisterEndView(_ sender: UIButton) {
        registerButton.isEnabled = false
        syusrinf.suiusrnam = suiusrnamField.text?.trimmingCharacters(in: .whitespaces)
        syusrinf.suipaswrd = suipaswrdField.text?.trimmingCharacters(in: .whitespaces).md5().uppercased()
        
        Alamofire.request(SERVER + "user/register.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            
            if Response<String>.success(response) {
                let storyBoard = UIStoryboard(name: "Login", bundle: nil)
                let registerEndViewController = storyBoard.instantiateViewController(withIdentifier: "RegisterEndViewController") as! RegisterEndViewController
                self.present(registerEndViewController, animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                print("Error: " + error)
                let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            self.registerButton.isEnabled = true
        }
    }
    
    @IBAction func showPrivacyPolicy(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let termsPrivacyViewController = storyBoard.instantiateViewController(withIdentifier: "TermsPrivacyViewController") as! TermsPrivacyViewController
        self.present(termsPrivacyViewController, animated: true, completion: nil)
    }
    
    @IBAction func backToLogIn(_ sender: UIButton) {
        var rootVC = self.presentingViewController!
        while !rootVC.isKind(of: LoginViewController.self), let parent = rootVC.presentingViewController {
            rootVC = parent
        }
        rootVC.dismiss(animated: true, completion: nil)
    }
    
}
