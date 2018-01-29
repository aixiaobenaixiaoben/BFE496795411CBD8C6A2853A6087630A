//
//  TermsPrivacyViewController.swift
//  leopard
//
//  Created by 李瑞锋 on 2018/1/20.
//  Copyright © 2018年 forfreedomandlove. All rights reserved.
//

import UIKit

class TermsPrivacyViewController: UIViewController {

    @IBOutlet weak var termsAndPrivacy: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termsAndPrivacy.text = "\n\n\n\n歌者文明\n\n\n\n我看到了我的爱恋\n\n我飞到她的身边\n\n我捧出给她的礼物\n\n那是一小块凝固的时间\n\n时间上有美丽的条纹\n\n摸起来像浅海的泥一样柔软\n\n她把时间涂满全身\n\n然后拉起我飞向存在的边缘\n\n这是灵态的飞行\n\n我们眼中的星星像幽灵\n\n星星眼中的我们也像幽灵\n\n\n\n"
        termsAndPrivacy.text = termsAndPrivacy.text + "\n\n\n\n穿过大半个中国去睡你\n\n\n\n其实，睡你和被你睡是差不多的，无非是\n\n两具肉体碰撞的力，无非是这力催开的花朵\n\n无非是这花朵虚拟出的春天让我们误以为生命被重新打开\n\n大半个中国，什么都在发生：火山在喷，河流在枯\n\n一些不被关心的政治犯和流民\n\n一路在枪口的麋鹿和丹顶鹤\n\n我是穿过枪林弹雨去睡你\n\n我是把无数的黑夜摁进一个黎明去睡你\n\n我是无数个我奔跑成一个我去睡你\n\n当然我也会被一些蝴蝶带入歧途\n\n把一些赞美当成春天\n\n把一个和横店类似的村庄当成故乡\n\n而它们\n\n都是我去睡你必不可少的理由\n\n\n\n"
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
