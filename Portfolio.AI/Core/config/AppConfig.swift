//
//  app_config.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import Foundation

class AppConfig {
    static var supabaseInitUrl: String {
        let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_INIT_URL")
        return "https://\(url as! String)"
    }

    static var anonKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "ANON_KEY") as! String
    }

    static var geminiApiKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY")
            as! String
    }

    static var geminiModeFlash: String {
        return "gemini-2.5-flash"
    }

    static var geminiModelPro: String {
        return "gemini-2.5-pro"
    }

    static var geminiBaseUrl: String {
        return "https://generativelanguage.googleapis.com/v1beta"
    }
}
