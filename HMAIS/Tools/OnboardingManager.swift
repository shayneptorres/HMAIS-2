//
//  OnboardingManager.swift
//  HMAIS
//
//  Created by Shayne Torres on 4/23/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation

enum OnboardingView {
    case dashboard
    case lists
    case listDetails
    
    var defaultsKey: String {
        switch self {
        case .dashboard:
            return "dashboardOnboarding"
        case .lists:
            return "listsOnboarding"
        case .listDetails:
            return "listDetailsOnboarding"
        }
    }
}

class OnboardingManager {
    
    static let instance = OnboardingManager()
    
    func shouldShowOnboarding(forView view: OnboardingView) -> Bool {
        let defaults = UserDefaults.standard
        
        return defaults.bool(forKey: view.defaultsKey)
    }
    
    func didShowOnboarding(forView view: OnboardingView) {
        let defaults = UserDefaults.standard
        
        defaults.setValue(true, forKey: view.defaultsKey)
    }
}
