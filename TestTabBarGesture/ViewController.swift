//
//  ViewController.swift
//  TestTabBarGesture
//
//  Created by george on 17/06/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var button: UIButton = {
        let b = UIButton()
        b.setTitle("Go to tabbar", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 10
        b.clipsToBounds = true
        b.addTarget(self, action: #selector(goToTabbar), for: .touchUpInside)
        return b
    }()
    
    lazy var vc1: UINavigationController = {
        let vc = VC1()
        vc.title = "vc1"
        vc.view.backgroundColor = .systemRed
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 3)
        let n = UINavigationController(rootViewController: vc)
        return n
    }()

    lazy var vc2: UINavigationController = {
        let vc = VC2()
        vc.title = "vc2"
        vc.view.backgroundColor = .systemPink
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        let n = UINavigationController(rootViewController: vc)
        return n
    }()

    lazy var tvc1: UINavigationController = {
        let vc = TVC1()
        vc.title = "tvc1"
        vc.view.backgroundColor = .systemBlue
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        let n = UINavigationController(rootViewController: vc)
        return n
    }()

    lazy var tvc2: UINavigationController = {
        let vc = TVC2()
        vc.title = "tvc2"
        vc.view.backgroundColor = .systemYellow
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        let n = UINavigationController(rootViewController: vc)
        return n
    }()

    lazy var tvc3: UINavigationController = {
        let vc = TVC3()
        vc.title = "tvc3"
        vc.view.backgroundColor = .systemPurple
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 4)
        let n = UINavigationController(rootViewController: vc)
        return n
    }()
    
    lazy var cvc1: UINavigationController = {
        let vc = CVC1()
        vc.title = "cvc1"
        vc.view.backgroundColor = .systemPurple
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 4)
        let n = UINavigationController(rootViewController: vc)
        return n
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        [button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
         button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         button.widthAnchor.constraint(equalToConstant: 160),
         button.heightAnchor.constraint(equalToConstant: 55)
        ].forEach({ $0.isActive = true })
    }
    
    
    @objc func goToTabbar() {
        let tb = BaseTabBarController()
        tb.viewControllers = [tvc1, vc1, tvc2, vc2, cvc1]
        changeRoot(to: tb)
    }
    
    func changeRoot(to controller: UIViewController?) {
        guard let window = view.window,
            let destinationView = controller?.view
            else { return }
        
        let overlayView = UIScreen.main.snapshotView(afterScreenUpdates: false)
        destinationView.addSubview(overlayView)
        window.rootViewController = controller
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
            overlayView.alpha = 0
        }, completion: { finished in
            overlayView.removeFromSuperview()
        })
    }
}
