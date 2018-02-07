//
//  CTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/2/1.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class CTableViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sections = tableView.numberOfSections
        if section == sections - 1 {
            return 0.00001
        }
        if !LoginViewController.isLogin {
            return 0.00001
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sections = tableView.numberOfSections
        if !LoginViewController.isLogin && section != sections - 1 {
            return 0.00001
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath), let identifier = cell.reuseIdentifier {
            if LoginViewController.isLogin {
                return identifier == "LOGIN" ? 0 : super.tableView(tableView, heightForRowAt: indexPath)
            } else {
                return identifier != "LOGIN" ? 0 : super.tableView(tableView, heightForRowAt: indexPath)
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), let identifier = cell.reuseIdentifier {
            if identifier == "PROFILE" {
                loadProfileView(tableView, indexPath, cell)
            } else if identifier == "NOTIFICATION" {
                loadNotificationView(tableView, indexPath, cell)
            } else if identifier == "PHONE" {
                loadPhoneView(tableView, indexPath, cell)
            } else if identifier == "PASSWORD" {
                loadPasswordView(tableView, indexPath, cell)
            } else if identifier == "LOGOUT" {
                logout(tableView, indexPath, cell)
            } else if identifier == "LOGIN" {
                loginView(tableView, indexPath, cell)
            }
            cell.isSelected = false
        }
    }
    
    func loadProfileView(_ tableView: UITableView, _ indexPath: IndexPath, _ cell: UITableViewCell) {
    }
    
    func loadNotificationView(_ tableView: UITableView, _ indexPath: IndexPath, _ cell: UITableViewCell) {
    }
    
    func loadPhoneView(_ tableView: UITableView, _ indexPath: IndexPath, _ cell: UITableViewCell) {
        let storyBoard = UIStoryboard(name: "C", bundle: nil)
        let modPhoneVC = storyBoard.instantiateViewController(withIdentifier: "ModPhoneViewController") as! ModPhoneViewController
        let modPhoneNC = UINavigationController(rootViewController: modPhoneVC)
        self.present(modPhoneNC, animated: true, completion: nil)
    }
    
    func loadPasswordView(_ tableView: UITableView, _ indexPath: IndexPath, _ cell: UITableViewCell) {
    }
    
    func logout(_ tableView: UITableView, _ indexPath: IndexPath, _ cell: UITableViewCell) {
        
        let alert = UIAlertController(title: NSLocalizedString("LOG_OUT_CONFIRM", comment: "log out confirm title"),
                                      message: NSLocalizedString("LOG_OUT_CONFIRM_MESSAGE", comment: "log out confirm message"),
                                      preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "cancel action"), style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: NSLocalizedString("CONFIRM", comment: "confirm action"), style: .default, handler: {
            action in
            
            UserDefaults.standard.set(nil, forKey: "Syusrinf")
            LoginViewController.isLogin = false
            
            Alamofire.request(SERVER + "user/logout.action", method: .post).responseString {
                response in
                if let error = Response<String>.error(response) {
                    print("Error: " + error)
                }
            }
            self.tableView.reloadData()
        })
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func loginView(_ tableView: UITableView, _ indexPath: IndexPath, _ cell: UITableViewCell) {
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }

}
