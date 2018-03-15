//
//  WhatsUpTableViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/3/15.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit
import Alamofire

class WhatsUpTableViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var whatsUpTextView: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    
    var syprofil: Syprofil!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        whatsUpTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if syprofil != nil {
            whatsUpTextView.text = syprofil.spfwhatup
            countLabel.text = String((60 - whatsUpTextView.text.pregReplace(pattern: "[\u{4E00}-\u{9FA5}]", with: "00").count) / 2)
        }
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            done(textView)
            return true
        }
        guard let string = textView.text else { return true }
        let alphaText = string.pregReplace(pattern: "[\u{4E00}-\u{9FA5}]", with: "00")
        let newLength = alphaText.count + text.count - range.length
        
        countLabel.text = String((60 - newLength) / 2)
        return newLength <= 60
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        guard syprofil != nil else {
            return
        }
        if whatsUpTextView.text == syprofil.spfwhatup {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        let updateSyprofil = Syprofil()
        updateSyprofil.spfseqcod = syprofil.spfseqcod
        updateSyprofil.spfverson = syprofil.spfverson
        updateSyprofil.spfwhatup = whatsUpTextView.text
        
        Alamofire.request(SERVER + "user/updateProfile.action", method: .post, parameters: updateSyprofil.toJSON()).responseString { response in
            if let newSyprofil = Response<Syprofil>.data(response) {
                UserDefaults.standard.set(newSyprofil.toJSONString(), forKey: "SYPROFIL")
                self.dismiss(animated: true, completion: nil)
                
            } else if let error = Response<String>.error(response) {
                self.view.makeToast(error)
                print("Error: " + error)
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}
