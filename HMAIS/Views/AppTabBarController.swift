//
//  AppTabBarController.swift
//  HMAIS
//
//  Created by Shayne Torres on 3/15/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

class AppTabBarController: UITabBarController {

    var selectedImage = UIImage()
    var unselectedImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.items?.enumerated().forEach({ index, _ in
            switch index {
            case 0: // dashboard
                selectedImage = #imageLiteral(resourceName: "home_icon_green.png")
                unselectedImage = #imageLiteral(resourceName: "home_icon.png")
                self.tabBar.items?[index].selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
                self.tabBar.items?[index].image = unselectedImage.withRenderingMode(.alwaysOriginal)
            case 1: // lists
                selectedImage = #imageLiteral(resourceName: "list_icon_green.png")
                unselectedImage = #imageLiteral(resourceName: "list_icon.png")
                self.tabBar.items?[index].selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
                self.tabBar.items?[index].image = unselectedImage.withRenderingMode(.alwaysOriginal)
            default:
                break
            }
        })
            
        
        
        let selectedColor   = #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1)
        let unselectedColor = #colorLiteral(red: 0.6819999814, green: 0.6819999814, blue: 0.6819999814, alpha: 1)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: unselectedColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: selectedColor], for: .selected)
    }

}
