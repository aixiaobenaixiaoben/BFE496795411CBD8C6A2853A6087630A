//
//  ViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/9.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire
import HandyJSON

class ViewController: UIViewController {

    override func viewDidLoad() {
        
/**
        Alamofire.request(SERVER + "index/hello.action", method: .post).responseString {
            response in
            if let data = Response<String>.data(response) {
                print("-------------------string-----------------------")
                print("rtndta: " + data)
            } else if let error = Response<String>.error(response) {
                print("Error: " + error)
            }
        }
        
        Alamofire.request(SERVER + "user/userList.action", method: .post).responseString {
            response in
            if let data = Response<[Syusrinf]>.data(response) {
                print("-------------------object list------------------")
                print("user count: \(data.count)")
                print("user1 name: " + data[0].suiusrnam!)
                print("user2 name: " + data[1].suiusrnam!)
            } else if let error = Response<[Syusrinf]>.error(response) {
                print("Error: " + error)
            }
        }

        let syusrinf = Syusrinf()
        syusrinf.suimobile = "13300000000"
        syusrinf.suipaswrd = "9D5E3ECDEB4CDB7ACFD63075AE046672"
        Alamofire.request(SERVER + "user/login.action", method: .post, parameters: syusrinf.toJSON()).responseString {
            response in
            if let data = Response<Syusrinf>.data(response) {
                print("-------------------object-----------------------")
                print("suiseqcod: " + data.suiseqcod!)
                print("suiverson: " + data.suiverson!)
                print("suiusrnam: " + data.suiusrnam!)
                print("suimobile: " + data.suimobile!)
            } else if let error = Response<Syusrinf>.error(response) {
                print("Error: " + error)
            }
        }
 */

        
        super.viewDidLoad()
    }


}

//temp extension
extension UIViewController {
    @IBAction func close(_ sendor: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
