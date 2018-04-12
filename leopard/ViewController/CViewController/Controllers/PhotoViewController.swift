//
//  PhotoViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/3/19.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

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
    
    @IBAction func chooseAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhoto = UIAlertAction(title: NSLocalizedString("TAKE-PHOTO", comment: "take photo action"), style: .default) { action in
            self.takePhoto()
        }
        let choosePhoto = UIAlertAction(title: NSLocalizedString("CHOOSE-PHOTO", comment: "choose photo action"), style: .default) { action in
            self.openPhotoLib()
        }
        let savePhoto = UIAlertAction(title: NSLocalizedString("SAVE-PHOTO", comment: "save photo action"), style: .default) { action in
            self.savePhoto()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "cancel action"), style: .cancel, handler: nil)
        
        alert.addAction(takePhoto)
        alert.addAction(choosePhoto)
        alert.addAction(savePhoto)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openPhotoLib() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            //TODO: - 系统编辑模式
//            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        } else {
            self.view.makeToast(NSLocalizedString("PHOTOLIBRARY-IS-UNAVAILABLE", comment: "photoLibrary is unavailable"))
        }
    }
    
    func takePhoto() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  .authorized {
            takePicture()
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (granted: Bool) in
                if granted {
                    self.takePicture()
                } else {
                    DispatchQueue.main.async {
                        self.view.makeToast(NSLocalizedString("NO-PERMISSION-TO-USE-CAMERA", comment: "no permission to use camera"))
                    }
                }
            }
        }
    }

    func takePicture() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        } else {
            self.view.makeToast(NSLocalizedString("CAMERA-IS-UNAVAILABLE", comment: "camera is unavailable"))
        }
    }
    
    func savePhoto() {
        if let image = photoImageView.image {
            saveImage(image)
        } else {
            self.view.makeToast(NSLocalizedString("NO-PHOTO-TO-BE-SAVED", comment: "no photo to be saved"))
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //MARK: - 不编辑模式
//        let pickerImage = info[UIImagePickerControllerOriginalImage] as! UIImage
//        guard let jpegData = UIImageJPEGRepresentation(pickerImage, 1) else {
//            return
//        }
//        uploadImage(imageData: jpegData)
//        self.dismiss(animated: true, completion: nil)
        
        //MARK: - 系统编辑模式
//        let pickerImage = info[UIImagePickerControllerEditedImage] as! UIImage
//        guard let jpegData = UIImageJPEGRepresentation(pickerImage, 1) else {
//            return
//        }
//        uploadImage(imageData: jpegData)
//        self.dismiss(animated: true, completion: nil)
        
        if picker.sourceType == .photoLibrary {
            //MARK: - 自定义编辑模式
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
            
        } else if picker.sourceType == .camera {
            let pickerImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            guard let jpegData = UIImageJPEGRepresentation(pickerImage, 1) else {
                return
            }
            saveImage(pickerImage)
            uploadImage(imageData: jpegData)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func saveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.view.makeToast(error.localizedDescription)
        } else {
            self.view.makeToast(NSLocalizedString("SAVED", comment: "saved"))
        }
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
