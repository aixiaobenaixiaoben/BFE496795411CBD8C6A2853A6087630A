//
//  LoginViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/12.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var suimobileField: UITextField!
    @IBOutlet weak var suipaswrdField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var syusrinf: Syusrinf!
    static var isLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.isEnabled = false
        suimobileField.delegate = self
        suipaswrdField.delegate = self
    }
    
    @IBAction func checkValid(_ sender: UITextField) {
        if let suimobile = suimobileField.text, suimobile.verifyDigit(len: 11), let suipaswrd = suipaswrdField.text, suipaswrd.verifyPassword() {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    @IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func onTapGestureRecognized(_ sender: UITapGestureRecognizer) {
        suimobileField.resignFirstResponder()
        suipaswrdField.resignFirstResponder()
    }
    
    @IBAction func login(_ sender: UIButton) {
        loginButton.isEnabled = false
        syusrinf = Syusrinf()
        syusrinf.suimobile = suimobileField.text?.trimmingCharacters(in: .whitespaces)
        syusrinf.suipaswrd = suipaswrdField.text?.trimmingCharacters(in: .whitespaces).md5().uppercased()
        
        Alamofire.request(SERVER + "user/login.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            
            if let data = Response<Syusrinf>.data(response) {
                UserDefaults.standard.set(self.syusrinf.toJSONString(), forKey: "Syusrinf")
                print(data.toJSONString(prettyPrint: true)!)
                self.syusrinf = data
                LoginViewController.isLogin = true
                self.dismiss(animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                print("Error: " + error)
                let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: {
                    self.loginButton.isEnabled = true
                })
            }
        }
    }
    
    static func loginAutomatic(_ syusrinf: Syusrinf) {
        Alamofire.request(SERVER + "user/login.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            if Response<Syusrinf>.data(response) != nil {
                LoginViewController.isLogin = true
            } else  {
                LoginViewController.isLogin = false
                UserDefaults.standard.set(nil, forKey: "Syusrinf")
            }
        }
    }

    @IBAction func loadRegisterApplyView(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let registerApplyViewController = storyBoard.instantiateViewController(withIdentifier: "RegisterApplyViewController") as! RegisterApplyViewController
        self.present(registerApplyViewController, animated: true, completion: nil)
    }
    
    @IBAction func loadResetApplyView(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let resetApplyViewController = storyBoard.instantiateViewController(withIdentifier: "ResetApplyViewController") as! ResetApplyViewController
        self.present(resetApplyViewController, animated: true, completion: nil)
    }
    
    @IBAction func backHome(_ sender: UIButton) {
        LoginViewController.isLogin = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
