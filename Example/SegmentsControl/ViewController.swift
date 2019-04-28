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
        
        let segment = SegmentControl(titles: ["apple", "peach", "lemon", "pear", "banana", "grape", "orange", "cherry", "watermelon"])
        view.addSubview(segment)
        segment.frame = CGRect(x: 15, y: 88, width: view.frame.width - 30, height: 44)
    }

}

