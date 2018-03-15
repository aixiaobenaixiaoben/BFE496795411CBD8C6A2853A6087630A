//
//  ExtensionUIViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/18.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

extension UIViewController: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
//        let newLength = text.count + string.count - range.length
        let alphaText = text.pregReplace(pattern: String.ZH_CN_PATTERN, with: "00")
        let newLength = alphaText.count + string.count - range.length
        return newLength <= 32
    }
    
    @IBAction func textFieldEditDone(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func onTapGestureRecognized(_ sender: Any) {
        self.view.endEditing(true)
    }
    
}
