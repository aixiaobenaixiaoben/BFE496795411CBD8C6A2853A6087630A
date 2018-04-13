//
//  LanguageTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/4/8.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class LanguageTableViewController: UITableViewController {

    @IBOutlet weak var ZHCNCell: UITableViewCell!
    @IBOutlet weak var ENUSCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        if let language = UserDefaults.standard.string(forKey: "LANGUAGE") {
            if language == ZHCNCell.reuseIdentifier {
                ZHCNCell.accessoryType = .checkmark
            } else if language == ENUSCell.reuseIdentifier {
                ENUSCell.accessoryType = .checkmark
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell == ZHCNCell {
                ZHCNCell.accessoryType = .checkmark
                ENUSCell.accessoryType = .none
            } else if cell == ENUSCell {
                ZHCNCell.accessoryType = .none
                ENUSCell.accessoryType = .checkmark
            }
            cell.isSelected = false
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        guard let selectPath = tableView.indexPathForSelectedRow, let cell = tableView.cellForRow(at: selectPath),
            let newLanguage = cell.reuseIdentifier,
            let oldLanguage = UserDefaults.standard.string(forKey: "LANGUAGE"),
            let string = UserDefaults.standard.string(forKey: "SYUSRINF"), let syusrinf = Syusrinf.deserialize(from: string) else {
            return
        }
        if newLanguage == oldLanguage {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        UserDefaults.standard.set(newLanguage, forKey: "LANGUAGE")
        LoginViewController.login(
            syusrinf: syusrinf,
            succHandler: { user in
                self.dismiss(animated: true, completion: nil)
            },
            failHandler: { error in
                UserDefaults.standard.set(oldLanguage, forKey: "LANGUAGE")
                self.view.makeToast(error)
            },
            requestHandler: {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        )
    }
    
}
