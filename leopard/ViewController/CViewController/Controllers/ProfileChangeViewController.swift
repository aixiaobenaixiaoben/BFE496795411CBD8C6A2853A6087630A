//
//  ProfileChangeViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/2/6.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

class ProfileChangeViewController: UIViewController {

    override func shouldPopOnBackButton() -> Bool {
        let alert = UIAlertController(title: "Confirm Go Back?", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: "Confirm", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        return false
    }
    
    // Handle the pop gesture
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil { // When the user swipe to back, the parent is nil
            //do something
            print("--user swipe to back")
            return
        }
        super.willMove(toParentViewController: parent)
    }
    
    @IBAction func Submit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
