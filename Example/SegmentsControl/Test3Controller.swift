//
//  Test3Controller.swift
//  SegmentsControl_Example
//
//  Created by MayerF on 2019/8/5.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class Test3Controller: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Test3 - viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Test3 - viewWillDisappear")
    }

}
