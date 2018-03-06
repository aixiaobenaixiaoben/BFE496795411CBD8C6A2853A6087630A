//
//  Download.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/2/28.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class Download: NSObject {
    
    static func image(of remote: String, for imageView: UIImageView, in parentVC: UIViewController, useCache: Bool = true) {
        let imagePath = NSHomeDirectory() + "/Documents/" + remote
        
        if FileManager.default.fileExists(atPath: imagePath), useCache {
            imageView.image = UIImage(contentsOfFile: imagePath)
            print("--Load image in cache-" + remote)
            
        } else {
            print("--Download image-" + remote)
            let errorPath = NSHomeDirectory() + "/Documents/f.txt"
            if FileManager.default.fileExists(atPath: errorPath) {
                try! FileManager.default.removeItem(atPath: errorPath)
            }
            if FileManager.default.fileExists(atPath: imagePath) {
                try! FileManager.default.removeItem(atPath: imagePath)
            }
            
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            let para: Parameters = ["remote": remote];
            Alamofire.download(SERVER + "attachment/download.action", method: .post, parameters: para, to: destination).responseData { response in
                switch response.result {
                case .success:
                    if FileManager.default.fileExists(atPath: errorPath), let message = Download.error(at: errorPath) {
                        parentVC.view.makeToast(message)
                    } else {
                        imageView.image = UIImage(contentsOfFile: imagePath)
                    }
                case .failure(let error):
                    parentVC.view.makeToast(error.localizedDescription)
                }
            }
        }
    }
    
    static func error(at path: String) -> String? {
        if let errorData = FileManager.default.contents(atPath: path),
            let errorString = String(data: errorData, encoding: String.Encoding.utf8),
            let data = Response<String>.deserialize(from: errorString),
            data.RTNCOD == "ERR",
            let errorMessage = data.ERRMSG {
            return errorMessage
        }
        return nil
    }

}
