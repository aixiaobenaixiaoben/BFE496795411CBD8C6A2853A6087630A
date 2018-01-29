//
//  ExtensionString.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/16.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import HandyJSON

extension String: HandyJSON {
    
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        
        return String(format: hash as String)
    }
    
    func verifyDigit(len: Int) -> Bool {
        let mobile = "^[0-9]{\(len)}$"
        let regexMobile = NSPredicate.init(format: "SELF MATCHES %@", mobile)
        return regexMobile.evaluate(with: self)
    }

    func verifyPassword() -> Bool {
        let password = "^[A-Za-z0-9_]{8,14}$"
        let regexPassword = NSPredicate.init(format: "SELF MATCHES %@", password)
        return regexPassword.evaluate(with: self)
    }

    func verifyUsername() -> Bool {
        let username = "^[\u{4E00}-\u{9FA5}A-Za-z0-9_]{2,32}$"
        let regexUsername = NSPredicate.init(format: "SELF MATCHES %@", username)
        return regexUsername.evaluate(with: self)
    }
    
    func pregReplace(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        let range = NSMakeRange(0, self.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: with)
    }
    
}
