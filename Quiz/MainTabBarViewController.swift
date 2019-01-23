//
//  MainTabBarViewController.swift
//  Quiz
//
//  Created by Celia Falcón Lozano on 24/11/2018.
//  Copyright © 2018 Alfonso  Jiménez Martínez. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = UIColor.darkGray
        tabBar.items?[0].title = "Quizzes"
        tabBar.items?[1].title = "Play"
    }
    


}
