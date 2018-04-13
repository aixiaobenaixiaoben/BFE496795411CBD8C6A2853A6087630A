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
            var lang = "EN-US"
            if let region = Locale.current.regionCode {
                let sysLang = Locale.preferredLanguages[0].dropLast(region.count + 1)
                if sysLang == "zh-Hans" {
                    lang = "ZH-CN"
                }
            }
            UserDefaults.standard.set(lang, forKey: "LANGUAGE")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if !LoginViewController.isLogin {
            if let string = UserDefaults.standard.string(forKey: "SYUSRINF"), let syusrinf = Syusrinf.deserialize(from: string) {
                
                print("--log in after HomeViewController viewdidappear")
                LoginViewController.login(
                    syusrinf: syusrinf,
                    succHandler: { user in
                        if let aVC = self.selectedViewController as? AViewController {
                            aVC.reloadData()
                        }
                    },
                    failHandler: { error in
                        self.loadLoginView()
                    },
                    requestHandler: nil
                )
                
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
