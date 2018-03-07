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

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var portraitCell: UITableViewCell!
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var genderCell: UITableViewCell!
    @IBOutlet weak var regionCell: UITableViewCell!
    @IBOutlet weak var whatsupCell: UITableViewCell!
    @IBOutlet weak var portraitImageView: UIImageView!
    
    var flag = ""
    var photoImage: UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let string = UserDefaults.standard.string(forKey: "SYUSRINF"), let syusrinf = Syusrinf.deserialize(from: string) {
            nameCell.detailTextLabel?.text = syusrinf.suiusrnam
        }
        if let string = UserDefaults.standard.string(forKey: "SYPROFIL"), let syprofil = Syprofil.deserialize(from: string) {
            genderCell.detailTextLabel?.text = syprofil.spfgender
            regionCell.detailTextLabel?.text = syprofil.spfregion
            if let remote = syprofil.spfphotog {
                Download.image(of: remote, for: portraitImageView, in: self)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell == portraitCell {
                
            } else if cell == nameCell {
                loadNameView()
            } else if cell == genderCell {
                
            } else if cell == regionCell {
                
            } else if cell == whatsupCell {
                
            }
            cell.isSelected = false
        }
    }
    
    func loadNameView() {
        let storyBoard = UIStoryboard(name: "C", bundle: nil)
        let nameTVC = storyBoard.instantiateViewController(withIdentifier: "NameTableViewController") as! NameTableViewController
        let nameNC = UINavigationController(rootViewController: nameTVC)
        self.present(nameNC, animated: true, completion: nil)
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
