//
//  ProfileViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/2/1.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Next(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "C", bundle: nil)
        let profileChangeViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileChangeViewController") as! ProfileChangeViewController
        
        profileChangeViewController.navigationItem.title = "Verification Code"
        let button = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = button
        
        self.navigationController?.pushViewController(profileChangeViewController, animated: true)
    }
}
