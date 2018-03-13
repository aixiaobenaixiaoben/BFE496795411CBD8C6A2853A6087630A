//
//  RegionCityTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/3/11.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

class RegionCityTableViewController: UITableViewController {

    var cities: [City] = []
    var regionSelected: [String] = []
    var regionSelecting: [String] = []
    var singleState: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        let city = cities[indexPath.row]
        cell.textLabel?.text = city.cityName
        cell.detailTextLabel?.text = nil
        
        if singleState {
            if regionSelecting.count > 1 {//有新选择，以新选择为准
                cell.accessoryType = (regionSelecting[1] == city.cityCode) ? .checkmark : .none
            } else {//无新选择，以旧选择为准
                cell.accessoryType = (regionSelected.count > 1 && regionSelected[1] == city.cityCode
                                    && regionSelected[0] == regionSelecting[0]) ? .checkmark : .none
            }
            
        } else {
            if regionSelecting.count > 2 {//有新选择，以新选择为准
                cell.accessoryType = (regionSelecting[2] == city.cityCode) ? .checkmark : .none
            } else {//无新选择，以旧选择为准
                cell.accessoryType = (regionSelected.count > 2 && regionSelected[2] == city.cityCode
                                    && regionSelected[1] == regionSelecting[1]
                                    && regionSelected[0] == regionSelecting[0]) ? .checkmark : .none
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = cities[indexPath.row]
        
        if let code = city.cityCode {
            if singleState {
                if regionSelecting.count > 1 {
                    regionSelecting.removeLast()
                }
            } else {
                if regionSelecting.count > 2 {
                    regionSelecting.removeLast()
                }
            }
            regionSelecting.append(code)
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        tableView.reloadData()
    }

    @IBAction func done(_ sender: Any) {
        RegionTableViewController.submitRegion(regionSelecting, self)
    }
    
}
