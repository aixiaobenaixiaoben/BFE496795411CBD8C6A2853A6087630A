//
//  NotifiTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/2/9.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

class NotifiTableViewController: UITableViewController {
    
    @IBOutlet weak var notifiSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notifiSwitch.isOn = UserDefaults.standard.bool(forKey: "notifiSwitch")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        UserDefaults.standard.set(notifiSwitch.isOn, forKey: "notifiSwitch")
    }


}
