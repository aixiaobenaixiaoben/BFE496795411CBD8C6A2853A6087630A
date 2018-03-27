//
//  PhotoViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/3/19.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

typealias PhotoVCSuccHandlerBlock = (_ message: String) -> Void

class PhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    
    //FIXME: - callback test
    var photoVCSuccHandler: PhotoVCSuccHandlerBlock?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let string = UserDefaults.standard.string(forKey: "SYPROFIL"), let syprofil = Syprofil.deserialize(from: string) {
            if let remote = syprofil.spfphotog, remote.count > 0 {
                Download.image(of: remote, for: photoImageView, in: self)
            }
        }
    }
    @IBAction func openPhotoLib(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            //TODO: - 系统编辑模式
//            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        } else {
            self.view.makeToast("no permission to read photoLibrary")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //TODO: - 不编辑模式
//        let pickerImage = info[UIImagePickerControllerOriginalImage] as! UIImage
//        guard let jpegData = UIImageJPEGRepresentation(pickerImage, 1) else {
//            return
//        }
//        uploadImage(imageData: jpegData)
//        self.dismiss(animated: true, completion: nil)
        
        //TODO: - 系统编辑模式
//        let pickerImage = info[UIImagePickerControllerEditedImage] as! UIImage
//        guard let jpegData = UIImageJPEGRepresentation(pickerImage, 1) else {
//            return
//        }
////        photoImage = pickerImage
//        uploadImage(imageData: jpegData)
//        self.dismiss(animated: true, completion: nil)
        
        //TODO: - 自定义编辑模式
        let pickerImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let storyBoard = UIStoryboard(name: "C", bundle: nil)
        let photoEditVC = storyBoard.instantiateViewController(withIdentifier: "PhotoEditViewController") as! PhotoEditViewController
        //FIXME: - callback test
        photoEditVC.photoEditVCSuccHandler = { [weak self]message in
            if let callBack = self?.photoVCSuccHandler {
                callBack(message)
            }
        }
        photoEditVC.image = pickerImage
        picker.pushViewController(photoEditVC, animated: true)
    }
    
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
                            FileManager.default.createFile(atPath: NSHomeDirectory() + "/Documents/" + remote, contents: imageData, attributes: nil)
                            self.updateProfile(remote)
                            
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
    
    func updateProfile(_ remote: String) {
        guard let string = UserDefaults.standard.string(forKey: "SYPROFIL"), let syprofil = Syprofil.deserialize(from: string) else {
            return
        }
        let updateSyprofil = Syprofil()
        updateSyprofil.spfseqcod = syprofil.spfseqcod
        updateSyprofil.spfverson = syprofil.spfverson
        updateSyprofil.spfphotog = remote
        
        Alamofire.request(SERVER + "user/updateProfile.action", method: .post, parameters: updateSyprofil.toJSON()).responseString { response in
            if let newSyprofil = Response<Syprofil>.data(response) {
                UserDefaults.standard.set(newSyprofil.toJSONString(), forKey: "SYPROFIL")
                Download.image(of: remote, for: self.photoImageView, in: self)
                self.navigationController?.view.hideToastActivity()
                
            } else if let error = Response<String>.error(response) {
                self.navigationController?.view.hideToastActivity()
                self.view.makeToast(error)
                print("Error: " + error)
            }
        }
    }

}
