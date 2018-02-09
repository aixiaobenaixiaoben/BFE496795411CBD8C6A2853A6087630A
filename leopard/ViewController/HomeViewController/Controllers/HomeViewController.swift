//
//  HomeViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/12.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: UITabBarController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if !LoginViewController.isLogin {
            if let string = UserDefaults.standard.string(forKey: "Syusrinf"), let syusrinf = Syusrinf.deserialize(from: string) {
                Alamofire.request(SERVER + "user/login.action", method: .post, parameters: syusrinf.toJSON()).responseString {
                    response in
                    if let data = Response<Syusrinf>.data(response) {
                        data.suipaswrd = syusrinf.suipaswrd
                        UserDefaults.standard.set(data.toJSONString(), forKey: "Syusrinf")
                        print("--log in after HomeViewController viewdidappear")
                        print(data.toJSONString(prettyPrint: true)!)
                        LoginViewController.isLogin = true
                        
                        if let aVC = self.selectedViewController as? AViewController {
                            aVC.reloadData()
                        }
                    } else  {
                        UserDefaults.standard.set(nil, forKey: "Syusrinf")
                        self.loadLoginView()
                    }
                }
            } else {
                loadLoginView()
            }
        }
    }
    
    func loadLoginView() {
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }

}
