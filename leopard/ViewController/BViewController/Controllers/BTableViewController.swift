//
//  BTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/4/16.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

class BTableViewController: UITableViewController {

    @IBAction func addContacts(_ sender: Any) {
        let addTVC = UIStoryboard(name: "B", bundle: nil).instantiateViewController(withIdentifier: "AddTableViewController") as! AddTableViewController
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addTVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
}
