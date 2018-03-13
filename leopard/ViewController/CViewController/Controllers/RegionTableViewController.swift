//
//  RegionTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/3/10.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class RegionTableViewController: UITableViewController {

    var regionString: String?
    var countryRegions: [CountryRegion] = []
    var regionSelected: [String] = []
    var regionSelecting: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let regionString = regionString {
            regionSelected = regionString.components(separatedBy: "-")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        regionSelecting.removeAll()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryRegions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        let countryRegion = countryRegions[indexPath.row]
        cell.textLabel?.text = countryRegion.countryRegionName
        cell.detailTextLabel?.text = nil
        
        if countryRegion.states.count > 0 {
            cell.accessoryType = .disclosureIndicator
            if regionSelected.count > 0, regionSelected[0] == countryRegion.countryRegionCode {
                cell.detailTextLabel?.text = NSLocalizedString("SELECTED", comment: "Mark the cell as selected before")
            }
            
        } else {
            if regionSelecting.count > 0 {//有新选择，以新选择为准
                cell.accessoryType = (regionSelecting[0] == countryRegion.countryRegionCode) ? .checkmark : .none
            } else {//无新选择，以旧选择为准
                cell.accessoryType = (regionSelected.count > 0 && regionSelected[0] == countryRegion.countryRegionCode) ? .checkmark : .none
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let countryRegion = countryRegions[indexPath.row]
        if let code = countryRegion.countryRegionCode {
            regionSelecting.removeAll()
            regionSelecting.append(code)
        }
        
        if countryRegion.states.count == 0 {//没有下属州
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            tableView.reloadData()
            
        } else if countryRegion.states.count == 1 {//只有一个下属州
            let storyBoard = UIStoryboard(name: "C", bundle: nil)
            let rcTVC = storyBoard.instantiateViewController(withIdentifier: "RegionCityTableViewController") as! RegionCityTableViewController
            rcTVC.cities = countryRegion.states[0].cities
            rcTVC.regionSelected = regionSelected
            rcTVC.regionSelecting = regionSelecting
            rcTVC.singleState = true
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("BACK", comment: "back button text"), style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(rcTVC, animated: true)
            
        } else {//有多个下属州
            let storyBoard = UIStoryboard(name: "C", bundle: nil)
            let rsTVC = storyBoard.instantiateViewController(withIdentifier: "RegionStateTableViewController") as! RegionStateTableViewController
            rsTVC.states = countryRegion.states
            rsTVC.regionSelected = regionSelected
            rsTVC.regionSelecting = regionSelecting
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("BACK", comment: "back button text"), style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(rsTVC, animated: true)
        }
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        RegionTableViewController.submitRegion(regionSelecting, self)
    }
    
    static func submitRegion(_ regionSelecting: [String], _ VC: UIViewController) {
        guard let string = UserDefaults.standard.string(forKey: "SYPROFIL"), let syprofil = Syprofil.deserialize(from: string) else {
            return
        }
        let region = regionSelecting.joined(separator: "-")
        if syprofil.spfregion == region {
            VC.dismiss(animated: true, completion: nil)
            return
        }
        VC.navigationItem.rightBarButtonItem?.isEnabled = false
        let updateSyprofil = Syprofil()
        updateSyprofil.spfseqcod = syprofil.spfseqcod
        updateSyprofil.spfverson = syprofil.spfverson
        updateSyprofil.spfregion = region
        
        Alamofire.request(SERVER + "user/updateProfile.action", method: .post, parameters: updateSyprofil.toJSON()).responseString { response in
            if let newSyprofil = Response<Syprofil>.data(response) {
                UserDefaults.standard.set(newSyprofil.toJSONString(), forKey: "SYPROFIL")
                VC.dismiss(animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                VC.navigationController?.view.makeToast(error)
                print("Error: " + error)
            }
            VC.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}
