//
//  ViewController.swift
//  SegmentsControl
//
//  Created by yuren805@163.com on 04/28/2019.
//  Copyright (c) 2019 yuren805@163.com. All rights reserved.
//

import UIKit
import SegmentsControl

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let segment = SegmentsControl(titles: ["apple", "peach", "lemon", "pear", "banana", "grape", "orange", "cherry", "watermelon"])
        segment.selectedFont = UIFont.systemFont(ofSize: 25)
        view.addSubview(segment)
        segment.frame = CGRect(x: 15, y: 88, width: view.frame.width - 30, height: 44)
        
        let nextBtn = UIButton()
        nextBtn.addTarget(self, action: #selector(gesAction), for: .touchUpInside)
        nextBtn.setTitle("next", for: .normal)
        nextBtn.frame = CGRect(x: 100, y: 200, width: 200, height: 80)
        nextBtn.backgroundColor = .red
        view.addSubview(nextBtn)
    }
    
    @objc func gesAction() {
        let nextVC = ShowController()
        navigationController?.pushViewController(nextVC, animated: true)
    }

}

