//
//  RegionTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/3/10.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class RegionTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var locationSelecting: String?
    var locationInfo: String? = NSLocalizedString("LOADING", comment: "Label when loading location")
    var locationIsable = false

    var regionString: String?
    var countryRegions: [CountryRegion] = []
    var regionSelected: [String] = []
    var regionSelecting: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        
        if let regionString = regionString, !regionString.hasPrefix("#") {
            regionSelected = regionString.components(separatedBy: "-")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        regionSelecting.removeAll()
        locationSelecting = nil
        tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("--Authorization status changed to \(status.rawValue)")
        locationIsable = false
        switch status {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            print("--Authorized When In Use")
        default:
            locationInfo = NSLocalizedString("UNABLE-TO-ACCESS-LOCATION", comment: "Unable to access user's current location")
            print("--Not Authorized")
            tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locations[0], completionHandler: { (placemarks, error) in
            
            //将城市-州-国家拼接，前面加#，存储数据库，要确保不超过字段长度
            func canAppend(_ origin: String, _ string: String) -> Bool {
                return origin.pregReplace(pattern: "[\u{4E00}-\u{9FA5}]", with: "00").count + string.pregReplace(pattern: "[\u{4E00}-\u{9FA5}]", with: "00").count <= 31
            }
            
            if let places = placemarks, places.count > 0 {
                let place = places[0]
                var region = ""
                if let locality = place.locality {
                    region.append(locality + ",")
                }
                if let administrativeArea = place.administrativeArea, canAppend(region, administrativeArea) {
                    region.append(administrativeArea + ",")
                }
                if let country = place.country, canAppend(region, country) {
                    region.append(country)
                }
                if region.hasSuffix(",") {
                    region = String(region.dropLast())
                }
                self.locationInfo = region
                self.locationIsable = true
                
            } else {
                self.locationInfo = NSLocalizedString("FAIL-TO-READ-LOCATION", comment: "Unable to reverse geocode location")
            }
            self.tableView.reloadData()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.navigationController?.view.makeToast(error.localizedDescription)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : countryRegions.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? NSLocalizedString("LOCATION", comment: "Header for location section") : NSLocalizedString("ALL-REGIONS", comment: "Header for region section")
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 0 ? NSLocalizedString("SETTINGS-PRIVACY-LOCATION-SERVICES-GUIDE", comment: "Footer for location section") : nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = locationInfo
            cell.detailTextLabel?.text = nil
            cell.accessoryType = locationSelecting == nil ? .none : .checkmark
            return cell
        }
        
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
        
        if indexPath.section == 0 {
            if locationIsable {
                locationSelecting = locationInfo
                regionSelecting.removeAll()
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            tableView.reloadData()
            return
        }
        
        let countryRegion = countryRegions[indexPath.row]
        if let code = countryRegion.countryRegionCode {
            regionSelecting.removeAll()
            regionSelecting.append(code)
            locationSelecting = nil
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
        if let locationSelecting = locationSelecting {
            RegionTableViewController.submitRegion(["#" + locationSelecting], self)
        } else {
            RegionTableViewController.submitRegion(regionSelecting, self)
        }
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
