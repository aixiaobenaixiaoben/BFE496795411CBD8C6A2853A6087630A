//
//  PhotoEditViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/3/19.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

typealias PhotoEditVCSuccHandlerBlock = (_ message: String) -> Void

class PhotoEditViewController: UIViewController {

    override var prefersStatusBarHidden: Bool { return true }
    //FIXME: - callback test
    var photoEditVCSuccHandler: PhotoEditVCSuccHandlerBlock?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var maskView: UIImageView!
    var image: UIImage?
    
    var scale = CGFloat(1)//图片伸缩比例
    var scaleOld = CGFloat(1)//记录上次的图片伸缩比例
    var distanceX = CGFloat(0)//图片横向偏移值(相对于imageView.center)
    var distanceY = CGFloat(0)//图片纵向偏移值
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.isToolbarHidden = false
        maskView.layer.borderWidth = 1
        maskView.layer.borderColor = UIColor.blue.cgColor
        imageView.image = image
    }
    
    @IBAction func onPanGestureRecognized(_ panGesture: UIPanGestureRecognizer) {
        let newDistanceX = distanceX + panGesture.translation(in: imageView).x * scaleOld
        let newDistanceY = distanceY + panGesture.translation(in: imageView).y * scaleOld
        imageView.transform = CGAffineTransform(translationX: newDistanceX, y: newDistanceY).scaledBy(x: scale * scaleOld, y: scale * scaleOld)
        
        if panGesture.state == .ended {
            distanceX = newDistanceX
            distanceY = newDistanceY
            adjustImageView()
        }
    }
    
    @IBAction func onPinchGestureRecognized(_ pinchGesture: UIPinchGestureRecognizer) {
        scale = pinchGesture.scale
        imageView.transform = CGAffineTransform(translationX: distanceX, y: distanceY).scaledBy(x: scale * scaleOld, y: scale * scaleOld)
        
        if pinchGesture.state == .ended {
            scaleOld = scale * scaleOld
            scale = 1
            distanceX = imageView.frame.origin.x + imageView.frame.width / 2 - imageView.center.x
            distanceY = imageView.frame.origin.y + imageView.frame.height / 2 - imageView.center.y
            adjustImageView()
        }
    }
    
    func adjustImageView() {
        guard let image = imageView.image else {
            return
        }
        if scaleOld < 1 {
            scaleOld = 1
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.imageView.transform = CGAffineTransform(translationX: self.distanceX, y: self.distanceY).scaledBy(x: self.scaleOld, y: self.scaleOld)
            }, completion: nil)
        }
        
        let scaleImageFromOrigin = min(image.size.width, image.size.height) / imageView.frame.width
        let currentImageWidth = image.size.width / scaleImageFromOrigin
        let currentImageHeight = image.size.height / scaleImageFromOrigin
        
        let coordinateX = distanceX + imageView.center.x
        let coordinateY = distanceY + imageView.center.y
        
        let leftTopPoint = CGPoint(x: coordinateX - 0.5 * currentImageWidth, y: coordinateY - 0.5 * currentImageHeight)
        let rightBottomPoint = CGPoint(x: coordinateX + 0.5 * currentImageWidth, y: coordinateY + 0.5 * currentImageHeight)
        
        let maskX = maskView.frame.origin.x
        let maskY = maskView.frame.origin.y
        let maskWidth = maskView.frame.width
        let maskHeight = maskView.frame.height
        
        if leftTopPoint.x > maskX {
            distanceX = distanceX + maskX - leftTopPoint.x
        }
        if leftTopPoint.y > maskY {
            distanceY = distanceY + maskY - leftTopPoint.y
        }
        if rightBottomPoint.x < maskX + maskWidth {
            distanceX = distanceX + maskX + maskWidth - rightBottomPoint.x
        }
        if rightBottomPoint.y < maskY + maskHeight {
            distanceY = distanceY + maskY + maskHeight - rightBottomPoint.y
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.imageView.transform = CGAffineTransform(translationX: self.distanceX, y: self.distanceY).scaledBy(x: self.scaleOld, y: self.scaleOld)
        }, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        let imageScale = min(image.size.width, image.size.height) / imageView.frame.width
        let currentImageWidth = image.size.width / imageScale
        let currentImageHeight = image.size.height / imageScale
        
        let rectx = maskView.frame.origin.x - imageView.frame.origin.x + (currentImageWidth - imageView.frame.width) * 0.5
        let recty = maskView.frame.origin.y - imageView.frame.origin.y + (currentImageHeight - imageView.frame.height) * 0.5
        let rectWidth = imageView.bounds.width * imageScale
        let rect = CGRect(x: rectx * imageScale, y: recty * imageScale, width: rectWidth, height: rectWidth)
        
        if let originImage = imageView.image, let cgImage = originImage.cgImage, let cropCgImage = cgImage.cropping(to: rect) {
            let cropImage = UIImage(cgImage: cropCgImage)
            guard let jpegData = UIImageJPEGRepresentation(cropImage, 1) else {
                return
            }
            uploadImage(imageData: jpegData)
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
                self.navigationController?.view.hideToastActivity()
                
                //FIXME: - callback test
                if let callBack = self.photoEditVCSuccHandler {
                    callBack("Profile Updated")
                }
                
                self.dismiss(animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                self.navigationController?.view.hideToastActivity()
                self.view.makeToast(error)
                print("Error: " + error)
            }
        }
    }
    
}
