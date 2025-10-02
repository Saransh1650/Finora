//
//  app_config.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import Foundation

class AppConfig {
    static var supabaseInitUrl: String {
        let url = ProcessInfo.processInfo.environment["SUPABASE_INIT_URL"]!
        return "https://\(String(describing: url))"
    }

    static var anonKey: String {
        return ProcessInfo.processInfo.environment["ANON_KEY"]!
    }

    static var geminiApiKey: String {
        return ProcessInfo.processInfo.environment["GEMINI_API_KEY"]!
    }

    static var geminiModeFlash: String {
        return "gemini-2.5-flash"
    }
    
    static var geminiModelPro: String{
        return "gemini-2.5-pro"
    }

    static var geminiBaseUrl: String {
        return "https://generativelanguage.googleapis.com/v1beta"
    }
}
