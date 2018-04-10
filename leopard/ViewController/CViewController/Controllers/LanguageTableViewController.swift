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
        syusrinf.language = newLanguage
        Alamofire.request(SERVER + "user/login.action", method: .post, parameters: syusrinf.toJSON()).responseString { response in
            if let data = Response<Syusrinf>.data(response) {
                data.suipaswrd = syusrinf.suipaswrd
                UserDefaults.standard.set(data.toJSONString(), forKey: "SYUSRINF")
                print(data.toJSONString(prettyPrint: true)!)
                LoginViewController.isLogin = true
                
                UserDefaults.standard.set(newLanguage, forKey: "LANGUAGE")
                self.dismiss(animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                LoginViewController.isLogin = false
                UserDefaults.standard.set(nil, forKey: "SYUSRINF")
                self.view.makeToast(error)
                print("Error: " + error)
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}
