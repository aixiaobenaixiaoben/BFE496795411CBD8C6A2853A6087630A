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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: "LANGUAGE") == nil {
            //TODO: - 取系统语言-简体中文-英文-默认英文
            UserDefaults.standard.set("EN-US", forKey: "LANGUAGE")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if !LoginViewController.isLogin {
            if let string = UserDefaults.standard.string(forKey: "SYUSRINF"), let syusrinf = Syusrinf.deserialize(from: string), let language = UserDefaults.standard.string(forKey: "LANGUAGE") {
                syusrinf.language = language
                Alamofire.request(SERVER + "user/login.action", method: .post, parameters: syusrinf.toJSON()).responseString {
                    response in
                    if let data = Response<Syusrinf>.data(response) {
                        data.suipaswrd = syusrinf.suipaswrd
                        UserDefaults.standard.set(data.toJSONString(), forKey: "SYUSRINF")
                        print("--log in after HomeViewController viewdidappear")
                        print(data.toJSONString(prettyPrint: true)!)
                        LoginViewController.isLogin = true
                        
                        if let aVC = self.selectedViewController as? AViewController {
                            aVC.reloadData()
                        }
                    } else  {
                        UserDefaults.standard.set(nil, forKey: "SYUSRINF")
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
