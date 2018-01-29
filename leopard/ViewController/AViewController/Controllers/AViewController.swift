//
//  AViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/14.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

class AViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isLogin {
            loginButton.isHidden = true
        } else {
            loginButton.isHidden = false
        }
    }
    
    @IBAction func loadLoginViewController(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }

}
