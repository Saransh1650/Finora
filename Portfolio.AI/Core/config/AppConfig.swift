//
//  app_config.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import Foundation

class AppConfig {
    static var defaultHost: String {
        return Bundle.main.object(forInfoDictionaryKey: "DEFAULT_HOST")
            as! String

    }

    static var supabaseInitUrl: String {
        return Bundle.main.object(forInfoDictionaryKey: "SUPABASE_INIT_URL")
            as! String

    }

    static var anonKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "ANON_KEY")
            as! String
    }
}
