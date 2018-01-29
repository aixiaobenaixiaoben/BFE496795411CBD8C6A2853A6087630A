//
//  HomeViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/12.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

var isLogin: Bool = false

class HomeViewController: UITabBarController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if let syusrinfString = UserDefaults.standard.string(forKey: "Syusrinf"), let syusrinf = Syusrinf.deserialize(from: syusrinfString) {
            LoginViewController.loginAutomatic(syusrinf)
        } else {
            let storyBoard = UIStoryboard(name: "Login", bundle: nil)
            let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
