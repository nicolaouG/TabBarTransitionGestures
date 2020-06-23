//
//  VC2.swift
//  TestTabBarGesture
//
//  Created by george on 17/06/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

class VC2: UIViewController {

    lazy var label: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.text = "This is a label on view controller 2"
        l.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.numberOfLines = 0
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        [label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
         label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
            ].forEach({$0.isActive = true})
    }
}
