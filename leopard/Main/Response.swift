//
//  Response.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/10.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import Alamofire
import HandyJSON

let SERVER = "https://forfreedomandlove.com/"
//let SERVER = "http://localhost:8080/"

class Response<T: HandyJSON>: HandyJSON {

    var RTNCOD: String!
    var RTNDTA: T?
    var ERRCOD: String?
    var ERRMSG: String?
    
    required init() {}
    
    static func success(_ response: DataResponse<String>) -> Bool {
        if response.result.isSuccess, let data = Response<T>.deserialize(from: response.result.value), data.RTNCOD == "SUC" {
            return true
        }
        return false
    }
    
    static func data(_ response: DataResponse<String>) -> T? {
        if response.result.isSuccess, let data = Response<T>.deserialize(from: response.result.value), data.RTNCOD == "SUC",let successData = data.RTNDTA {
            return successData
        }
        return nil
    }
    
    static func error(_ response: DataResponse<String>) -> String? {
        //请求成功
        if response.result.isSuccess {
            //返回数据格式合法
            if let data = Response<T>.deserialize(from: response.result.value) {
                //服务端抛出异常
                if data.RTNCOD == "ERR" {
                    //服务端返回错误信息
                    if let errorMessage = data.ERRMSG {
                        return errorMessage
                    }
                    //服务端只返回错误码
                    if let errorCode = data.ERRCOD {
                        return errorCode
                    }
                }
            }
            //返回数据格式不合法
            else {
                return "Bad Response"
            }
        }
        //请求失败
        else {
            //请求失败错误信息
            if let error = response.error {
                return error.localizedDescription
            }
        }
        return nil
    }
}







