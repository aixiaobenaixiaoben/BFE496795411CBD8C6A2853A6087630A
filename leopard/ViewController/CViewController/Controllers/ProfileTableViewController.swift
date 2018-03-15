//
//  ProfileTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/2/17.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Alamofire

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, XMLParserDelegate {

    @IBOutlet weak var portraitCell: UITableViewCell!
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var genderCell: UITableViewCell!
    @IBOutlet weak var regionCell: UITableViewCell!
    @IBOutlet weak var whatsupCell: UITableViewCell!
    @IBOutlet weak var portraitImageView: UIImageView!
    
    var countryRegions: [CountryRegion] = []
    var syusrinf: Syusrinf!
    var syprofil: Syprofil!
    var flag = ""
    var photoImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: - 根据用户选择的app语言确定加载地理文件
        let locFilePath = "zh-LocList"
        if let path = Bundle.main.url(forResource: locFilePath, withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let string = UserDefaults.standard.string(forKey: "SYUSRINF"), let syusrinf = Syusrinf.deserialize(from: string) {
            self.syusrinf = syusrinf
            nameCell.detailTextLabel?.text = syusrinf.suiusrnam
        }
        if let string = UserDefaults.standard.string(forKey: "SYPROFIL"), let syprofil = Syprofil.deserialize(from: string) {
            print(syprofil.toJSONString(prettyPrint: true)!)
            self.syprofil = syprofil
            genderCell.detailTextLabel?.text = syprofil.spfgenderText
            
            parserRegion(syprofil.spfregion)
            
            if let remote = syprofil.spfphotog {
                Download.image(of: remote, for: portraitImageView, in: self)
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell == portraitCell {
                
            } else if cell == nameCell {
                loadNameView()
            } else if cell == genderCell {
                loadGenderView()
            } else if cell == regionCell {
                loadRegionView()
            } else if cell == whatsupCell {
                
            }
            cell.isSelected = false
        }
    }
    
    func loadNameView() {
        let storyBoard = UIStoryboard(name: "C", bundle: nil)
        let nameTVC = storyBoard.instantiateViewController(withIdentifier: "NameTableViewController") as! NameTableViewController
        nameTVC.syusrinf = syusrinf
        let nameNC = UINavigationController(rootViewController: nameTVC)
        self.present(nameNC, animated: true, completion: nil)
    }
    
    func loadGenderView() {
        let storyBoard = UIStoryboard(name: "C", bundle: nil)
        let genderTVC = storyBoard.instantiateViewController(withIdentifier: "GenderTableViewController") as! GenderTableViewController
        genderTVC.syprofil = syprofil
        let genderNC = UINavigationController(rootViewController: genderTVC)
        self.present(genderNC, animated: true, completion: nil)
    }
    
    func loadRegionView() {
        let storyBoard = UIStoryboard(name: "C", bundle: nil)
        let regionTVC = storyBoard.instantiateViewController(withIdentifier: "RegionTableViewController") as! RegionTableViewController
        regionTVC.countryRegions = countryRegions
        regionTVC.regionString = syprofil.spfregion
        let regionNC = UINavigationController(rootViewController: regionTVC)
        self.present(regionNC, animated: true, completion: nil)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "CountryRegion" {
            let countryRegion = CountryRegion()
            countryRegion.countryRegionCode = attributeDict["Code"]
            countryRegion.countryRegionName = attributeDict["Name"]
            countryRegions.append(countryRegion)
        } else if elementName == "State" {
            if let countryRegion = countryRegions.last {
                let state = State()
                state.stateCode = attributeDict["Code"]
                state.stateName = attributeDict["Name"]
                countryRegion.states.append(state)
            }
        } else if elementName == "City" {
            if let countryRegion = countryRegions.last, let state = countryRegion.states.last {
                let city = City()
                city.cityCode = attributeDict["Code"]
                city.cityName = attributeDict["Name"]
                state.cities.append(city)
            }
        }
    }
    
    func parserRegion(_ spfregion: String?) {
        let regionText = NSLocalizedString("NOTSET", comment: "Tip when region info is empty")
        guard let regionString = spfregion else {
            regionCell.detailTextLabel?.text = regionText
            return
        }
        if regionString.hasPrefix("#") {
            regionCell.detailTextLabel?.text = String(regionString.dropFirst())
            return
        }
        var regionSelected: [String] = regionString.components(separatedBy: "-")
        
        for countryRegion in countryRegions {
            if regionSelected.count > 0, regionSelected[0] == countryRegion.countryRegionCode {//国家名匹配
                
                if countryRegion.states.count == 0, regionSelected.count == 1 {
                    regionCell.detailTextLabel?.text = countryRegion.countryRegionName
                    return
                }
                
                if countryRegion.states.count == 1, regionSelected.count == 2 {
                    for city in countryRegion.states[0].cities {
                        if regionSelected[1] == city.cityCode, let cityName = city.cityName, let countryRegionName = countryRegion.countryRegionName {
                            regionCell.detailTextLabel?.text = cityName + "," + countryRegionName
                            return
                        }
                    }
                }
                
                if countryRegion.states.count > 1 {
                    for state in countryRegion.states {
                        if regionSelected.count > 1, regionSelected[1] == state.stateCode {//州名匹配
                            
                            if state.cities.count == 0, regionSelected.count == 2,
                                let stateName = state.stateName, let countryRegionName = countryRegion.countryRegionName {
                                regionCell.detailTextLabel?.text = stateName + "," + countryRegionName
                                return
                            }
                            
                            if state.cities.count > 0, regionSelected.count > 2 {
                                for city in state.cities {
                                    if regionSelected[2] == city.cityCode, let cityName = city.cityName, let stateName = state.stateName, let countryRegionName = countryRegion.countryRegionName {//城市名匹配
                                        regionCell.detailTextLabel?.text = cityName + "," + stateName + "," + countryRegionName
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        regionCell.detailTextLabel?.text = regionText
    }
    
    
    //FIXME: - choose image
    func photoLib() {
        flag = "PHOTO"
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        } else {
            self.view.makeToast("no permission to read photoLibrary")
        }
    }
    
    //FIXME: - choose video
    func videoLib() {
        flag = "VIDEO"
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        } else {
            self.view.makeToast("no permission to read photoLibrary")
        }
    }
    
    //FIXME: - upload delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        if flag == "PHOTO" {
            let pickerImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            guard let jpegData = UIImageJPEGRepresentation(pickerImage, 1) else {
                return
            }
            photoImage = pickerImage
            uploadImage(imageData: jpegData)
            self.dismiss(animated: true, completion: nil)
            
//            let outpath = NSHomeDirectory() + "/Documents/00000000.mp4"
//            let pathString = NSHomeDirectory() + "/Documents/IMG_7488.MOV"
//            print("--video upload test " + pathString)
//            transformMoive(inputPath: pathString, outputPath: outpath)
            
        } else {
            let videoURL = info[UIImagePickerControllerMediaURL] as! URL
            print("--video address: \(videoURL.path)")
            let outpath = NSHomeDirectory() + "/Documents/\(Date().timeIntervalSince1970).mp4"
            transformMoive(inputPath: videoURL.path, outputPath: outpath)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //FIXME: - upload image
    func uploadImage(imageData: Data) {
        self.navigationController?.view.makeToastActivity(.center)
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "FILE", fileName: ".JPG", mimeType: "image/jpeg")
            },
            to: SERVER + "attachment/upload.action",
            method: .post,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in // main queue by default
                        print("上传完成\(String(format: "%.0f", progress.fractionCompleted * 100))%")
                    }
                    upload.responseString { response in
                        if let remote = Response<String>.data(response) {
                            self.portraitImageView.image = self.photoImage
                            print(remote)
                            self.navigationController?.view.hideToastActivity()

                        } else if let error = Response<String>.error(response) {
                            self.navigationController?.view.hideToastActivity()
                            self.view.makeToast(error)
                        }
                    }
                case .failure(let encodingError):
                    self.navigationController?.view.hideToastActivity()
                    self.view.makeToast(encodingError.localizedDescription)
                }
            }
        )
    }
    
    //FIXME: - upload video
    func transformMoive(inputPath:String, outputPath:String){
        
        let avAsset:AVURLAsset = AVURLAsset(url: URL.init(fileURLWithPath: inputPath), options: nil)
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
        
        if compatiblePresets.contains(AVAssetExportPresetLowQuality) {
            
            let exportSession:AVAssetExportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)!
            exportSession.outputURL = URL.init(fileURLWithPath: outputPath)
            exportSession.outputFileType = AVFileTypeMPEG4
            exportSession.shouldOptimizeForNetworkUse = true;
            
            exportSession.exportAsynchronously(
                completionHandler: {
                    switch exportSession.status{
                    case .completed:
                        print("--转码成功")
                        let mp4Path = URL.init(fileURLWithPath: outputPath)
                        self.uploadVideo(mp4Path: mp4Path)
                        break;
                    case .failed:
                        print("--转码失败:\(String(describing: exportSession.error?.localizedDescription))")
                        break
                    case .cancelled:
                        print("--转码取消")
                        break;
                    default:
                        print("--转码其它错误")
                        break;
                    }
                }
            )
        }
    }
    
    //FIXME: - upload video
    func uploadVideo(mp4Path: URL) {
        DispatchQueue.main.async {
            self.navigationController?.view.makeToastActivity(.center)
        }
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(mp4Path, withName: "FILE", fileName: ".mp4", mimeType: "video/mp4")
            },
            to: SERVER + "attachment/upload.action",
            method: .post,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        if let data = Response<String>.data(response) {
                            DispatchQueue.main.async {
                                self.navigationController?.view.hideToastActivity()
                                self.view.makeToast(data)
                            }
                        } else if let error = Response<String>.error(response) {
                            DispatchQueue.main.async {
                                self.navigationController?.view.hideToastActivity()
                                self.view.makeToast(error)
                            }
                        }
                    }
                case .failure(let encodingError):
                    DispatchQueue.main.async {
                        self.navigationController?.view.hideToastActivity()
                        self.view.makeToast(encodingError.localizedDescription)
                    }
                }
            }
        )
    }
    
    
}
