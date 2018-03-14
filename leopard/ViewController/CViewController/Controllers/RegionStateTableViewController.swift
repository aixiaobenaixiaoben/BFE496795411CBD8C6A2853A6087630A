//
//  RegionStateTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/3/11.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

class RegionStateTableViewController: UITableViewController {

    var states: [State] = []
    var regionSelected: [String] = []
    var regionSelecting: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        if regionSelecting.count > 1 {
            regionSelecting.removeLast()
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("ALL-REGIONS", comment: "Header for region section")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        let state = states[indexPath.row]
        cell.textLabel?.text = state.stateName
        cell.detailTextLabel?.text = nil
        
        if state.cities.count > 0 {
            cell.accessoryType = .disclosureIndicator
            if regionSelected.count > 1, regionSelected[1] == state.stateCode, regionSelected[0] == regionSelecting[0] {
                cell.detailTextLabel?.text = NSLocalizedString("SELECTED", comment: "Mark the cell as selected before")
            }
            
        } else {
            if regionSelecting.count > 1 {//有新选择，以新选择为准
                cell.accessoryType = (regionSelecting[1] == state.stateCode) ? .checkmark : .none
            } else {//无新选择，以旧选择为准
                cell.accessoryType = (regionSelected.count > 1 && regionSelected[1] == state.stateCode
                                    && regionSelected[0] == regionSelecting[0]) ? .checkmark : .none
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = states[indexPath.row]
        
        if let code = state.stateCode {
            if regionSelecting.count > 1 {
                regionSelecting.removeLast()
            }
            regionSelecting.append(code)
        }
        
        if state.cities.count == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            tableView.reloadData()
        } else {
            let storyBoard = UIStoryboard(name: "C", bundle: nil)
            let rcTVC = storyBoard.instantiateViewController(withIdentifier: "RegionCityTableViewController") as! RegionCityTableViewController
            rcTVC.cities = state.cities
            rcTVC.regionSelected = regionSelected
            rcTVC.regionSelecting = regionSelecting
            
            let button = UIBarButtonItem(title: NSLocalizedString("BACK", comment: "back button text"), style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = button
            self.navigationController?.pushViewController(rcTVC, animated: true)
        }
    }
    
    @IBAction func done(_ sender: Any) {
        RegionTableViewController.submitRegion(regionSelecting, self)
    }
    
}
