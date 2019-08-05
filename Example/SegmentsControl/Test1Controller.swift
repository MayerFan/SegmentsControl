//
//  Test1Controller.swift
//  SegmentsControl_Example
//
//  Created by MayerF on 2019/8/5.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class Test1Controller: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(gesAction))
        view.addGestureRecognizer(tapGes)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Test1 - viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Test1 - viewWillDisappear")
    }
    
    @objc func gesAction() {
        let nextVC = UIViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }

}
