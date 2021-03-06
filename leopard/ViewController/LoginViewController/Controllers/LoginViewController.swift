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
    @IBOutlet weak var messageLabel: UILabel!
    
    static var isLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.isEnabled = false
        suimobileField.delegate = self
        suipaswrdField.delegate = self
    }
    
    @IBAction func checkValid(_ sender: UITextField) {
        messageLabel.text = nil
        if let suimobile = suimobileField.text, suimobile.verifyDigit(len: 11), let suipaswrd = suipaswrdField.text, suipaswrd.verifyPassword() {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    @IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func login(_ sender: UIButton) {
        loginButton.isEnabled = false
        let syusrinf = Syusrinf()
        syusrinf.suimobile = suimobileField.text?.trimmingCharacters(in: .whitespaces)
        syusrinf.suipaswrd = suipaswrdField.text?.trimmingCharacters(in: .whitespaces).md5().uppercased()
        
        LoginViewController.login(
            syusrinf: syusrinf,
            succHandler: { user in
                self.dismiss(animated: true, completion: nil)
            },
            failHandler: { error in
                self.messageLabel.text = error
                self.loginButton.isEnabled = true
            },
            requestHandler: nil
        )
    }
    
    static func login(syusrinf: Syusrinf, succHandler: ((Syusrinf) -> Void)?, failHandler: ((String) -> Void)?, requestHandler: (() -> Void)?) {
        
        guard let language = UserDefaults.standard.string(forKey: "LANGUAGE") else { return }
        syusrinf.language = language
        
        Alamofire.request(SERVER + "user/login.action", method: .post, parameters: syusrinf.toJSON()).responseString { response in
            
            if let data = Response<Syusrinf>.data(response) {
                data.suipaswrd = syusrinf.suipaswrd
                UserDefaults.standard.set(data.toJSONString(), forKey: "SYUSRINF")
                LoginViewController.isLogin = true
                print(data.toJSONString(prettyPrint: true)!)
                if let handler = succHandler {
                    handler(data)
                }
                
            } else if let error = Response<String>.error(response) {
                LoginViewController.isLogin = false
                print("Error: " + error)
                if let handler = failHandler {
                    handler(error)
                }
            }
            
            if let handler = requestHandler {
                handler()
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
        let syusrinf = Syusrinf()
        syusrinf.suimobile = "15925648080"
        syusrinf.suipaswrd = "3E677D133FEC4B263E4365F9C36DAB72"
        UserDefaults.standard.set(syusrinf.toJSONString(), forKey: "SYUSRINF")
        LoginViewController.isLogin = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
