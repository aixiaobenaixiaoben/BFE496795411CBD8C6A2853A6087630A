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
    
    @IBAction func valueChanged(_ sender: Any) {
        UserDefaults.standard.set(notifiSwitch.isOn, forKey: "notifiSwitch")
    }


}
