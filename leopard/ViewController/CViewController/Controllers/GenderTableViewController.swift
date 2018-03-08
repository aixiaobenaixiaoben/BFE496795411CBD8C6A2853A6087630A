//
//  GenderTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/3/8.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class GenderTableViewController: UITableViewController {

    @IBOutlet weak var maleCell: UITableViewCell!
    @IBOutlet weak var femaleCell: UITableViewCell!
    
    var syprofil: Syprofil!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        if syprofil != nil, let gender = syprofil.spfgender {
            if gender == maleCell.reuseIdentifier {
                maleCell.accessoryType = .checkmark
            } else if gender == femaleCell.reuseIdentifier {
                femaleCell.accessoryType = .checkmark
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell == maleCell {
                maleCell.accessoryType = .checkmark
                femaleCell.accessoryType = .none
            } else if cell == femaleCell {
                maleCell.accessoryType = .none
                femaleCell.accessoryType = .checkmark
            }
            cell.isSelected = false
        }
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        guard let selectPath = tableView.indexPathForSelectedRow, let cell = tableView.cellForRow(at: selectPath), let gender = cell.reuseIdentifier, syprofil != nil else {
            return
        }
        if syprofil.spfgender == gender {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        let updateSyprofil = Syprofil()
        updateSyprofil.spfseqcod = syprofil.spfseqcod
        updateSyprofil.spfverson = syprofil.spfverson
        updateSyprofil.spfgender = gender
        
        Alamofire.request(SERVER + "user/updateProfile.action", method: .post, parameters: updateSyprofil.toJSON()).responseString { response in
            if let newSyprofil = Response<Syprofil>.data(response) {
                UserDefaults.standard.set(newSyprofil.toJSONString(), forKey: "SYPROFIL")
                self.dismiss(animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                self.view.makeToast(error)
                print("Error: " + error)
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}
