//
//  NotifiTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/2/9.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import UserNotifications

class NotifiTableViewController: UITableViewController {
    
    @IBOutlet weak var notifiSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notifiSwitch.isOn = UserDefaults.standard.bool(forKey: "NOTIFISWITCH")
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    self.notifiSwitch.isEnabled = false
                }
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        UserDefaults.standard.set(notifiSwitch.isOn, forKey: "NOTIFISWITCH")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), let identifier = cell.reuseIdentifier {
            if identifier == "JUMPTOSETTINGSAPP" {
                UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
            }
            cell.isSelected = false
        }
    }


}
