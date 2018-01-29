//
//  BViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/14.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class BViewController: UIViewController {

    @IBOutlet weak var userCountLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if LoginViewController.isLogin {
            userCountLabel.isHidden = false
        } else {
            userCountLabel.isHidden = true
        }
        
        if LoginViewController.isLogin {
            Alamofire.request(SERVER + "index/hello.action", method: .post).responseString {
                response in
                if let data = Response<String>.data(response) {
                    self.userCountLabel.text = data
                } else if let error = Response<String>.error(response) {
                    self.userCountLabel.text = error
                }
            }
        }
    }
}
