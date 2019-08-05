//
//  ShowController.swift
//  SegmentsControl_Example
//
//  Created by MayerF on 2019/8/5.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SegmentsControl

public let kHexRGB:((Int) -> UIColor) = { (rgbValue : Int) -> UIColor in
    return kHexRGBAlpha(rgbValue,1.0)
}
public let kHexRGBAlpha:((Int,Float) -> UIColor) = { (rgbValue : Int, alpha : Float) -> UIColor in
    return UIColor(red: CGFloat(CGFloat((rgbValue & 0xFF0000) >> 16)/255),
                   green: CGFloat(CGFloat((rgbValue & 0xFF00) >> 8)/255),
                   blue: CGFloat(CGFloat(rgbValue & 0xFF)/255),
                   alpha: CGFloat(alpha))
}

class ShowController: SegmentsController {
    var segments = SegmentsControl(titles: ["规则设置", "交易通知"])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
//        segments.contentAlign = .center
//        segments.textFont = UIFont.systemFont(ofSize: 16)
//        segments.textColor = kHexRGB(0x24324c)
//        segments.selectedTextColor = kHexRGB(0x23c0af)
//        segments.frame = CGRect.init(x: 0, y: 0, width: 200, height: 44)
//        segments.selectedBlock = { [unowned self](index) in
//            self.swtichController(index: index)
//        }
        
//        let settingVC = UIViewController()
//        let notifyVC = UIViewController()
//        let setVC = UIViewController()
//        let notVC = UIViewController()
//        settingVC.view.backgroundColor = .red
//        notifyVC.view.backgroundColor = .blue
//        setVC.view.backgroundColor = .purple
//        notVC.view.backgroundColor = .gray
        
        let test1 = Test1Controller()
        let test2 = Test2Controller()
        let test3 = Test3Controller()
        test1.view.backgroundColor = .gray
        test2.view.backgroundColor = .red
        test3.view.backgroundColor = .purple
        
        
        self.segments.textColor = kHexRGB(0x23c0af)
        self.segments.selectedTextColor = kHexRGB(0x23c0af)
        self.addChildControllers([test1, test2, test3], titles: ["规则设置", "交易通知", "知"]) { [unowned self](index) in
            self.segments.switchIndex(index)
        }
        
//        self.navigationItem.titleView = segments
    }

}
