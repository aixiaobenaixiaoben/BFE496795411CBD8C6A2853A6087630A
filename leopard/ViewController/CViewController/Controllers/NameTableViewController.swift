//
//  NameTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/3/7.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class NameTableViewController: UITableViewController {

    @IBOutlet weak var suiusrnamField: UITextField!
    
    var syusrinf: Syusrinf!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        suiusrnamField.delegate = self
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let string = UserDefaults.standard.string(forKey: "SYUSRINF"), let user = Syusrinf.deserialize(from: string) {
            syusrinf = user
            suiusrnamField.text = user.suiusrnam
        }
    }
    
    @IBAction func checkValid(_ sender: Any) {
        if let suiusrnam = suiusrnamField.text, suiusrnam.verifyUsername() {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        guard let suiusrnam = suiusrnamField.text, suiusrnam.verifyUsername() else {
            return
        }
        if  suiusrnam == syusrinf.suiusrnam {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        syusrinf.suipaswrd = nil
        syusrinf.suiusrnam = suiusrnam.trimmingCharacters(in: .whitespaces)
        
        Alamofire.request(SERVER + "user/updateUserInfo.action", method: .post, parameters: syusrinf.toJSON()).responseString { response in
            if let newSyusrinf = Response<Syusrinf>.data(response) {
                if let syusrinfString = UserDefaults.standard.string(forKey: "SYUSRINF"), let loginSyusrinf = Syusrinf.deserialize(from: syusrinfString) {
                    newSyusrinf.suipaswrd = loginSyusrinf.suipaswrd
                    UserDefaults.standard.set(newSyusrinf.toJSONString(), forKey: "SYUSRINF")
                }
                self.dismiss(animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                self.view.makeToast(error)
                print("Error: " + error)
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}




