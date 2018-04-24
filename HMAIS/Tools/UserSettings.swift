//
//  UserSettings.swift
//  HMAIS
//
//  Created by Shayne Torres on 4/23/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation

struct UserSettings {
    
    static let instance = UserSettings()
    
    let defaults = UserDefaults.standard
    
    func resetAllSettings() {
        defaults.removeObject(forKey: OnboardingView.dashboard.defaultsKey)
        defaults.removeObject(forKey: OnboardingView.lists.defaultsKey)
        defaults.removeObject(forKey: OnboardingView.listDetails.defaultsKey)
    }
}
