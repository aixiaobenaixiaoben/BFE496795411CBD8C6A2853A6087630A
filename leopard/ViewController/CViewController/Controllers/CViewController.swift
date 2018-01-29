//
//  CViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/14.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class CViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LoginViewController.isLogin {
            logoutButton.isHidden = false
        } else {
            logoutButton.isHidden = true
        }
    }
    
    @IBAction func logout(_ sender: UIButton) {
        logoutButton.isEnabled = false
        
        Alamofire.request(SERVER + "user/logout.action", method: .post).responseString {
            response in
            
            if Response<String>.success(response) {
                UserDefaults.standard.set(nil, forKey: "Syusrinf")
                print("Logout Success")
                let alert = UIAlertController(title: nil, message: "Logout Success", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: {
                    alertAction in
                    
                    LoginViewController.isLogin = false
                    self.logoutButton.isEnabled = true
                    self.logoutButton.isHidden = true
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                print("Error: " + error)
                let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: {
                    alertAction in
                    LoginViewController.isLogin = false
                    self.logoutButton.isEnabled = true
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
