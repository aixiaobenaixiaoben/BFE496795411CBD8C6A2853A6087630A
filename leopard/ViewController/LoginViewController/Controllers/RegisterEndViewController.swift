//
//  RegisterEndViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/15.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

class RegisterEndViewController: UIViewController {
    
    @IBAction func backToLogIn(_ sender: UIButton) {
        var rootVC = self.presentingViewController!
        while !rootVC.isKind(of: LoginViewController.self), let parent = rootVC.presentingViewController {
            rootVC = parent
        }
        rootVC.dismiss(animated: true, completion: nil)
    }
}
