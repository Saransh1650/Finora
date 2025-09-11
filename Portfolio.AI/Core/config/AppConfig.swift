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
        return "https://ojghztuggyzvmilgeaxn.supabase.co"
        
    }
    
    static var anonKey: String {
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9qZ2h6dHVnZ3l6dm1pbGdlYXhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY3MTIzMjAsImV4cCI6MjA3MjI4ODMyMH0.GTqRQrBn1QnfOKgONQQv5lapN-1QO4ngrZxn2X8b3a4"
    }
    
    // Gemini API Configuration
    static var geminiApiKey: String {
        return "AIzaSyD2kdF7XP8aX1PYXXZ-eU8yA2MhR73SO4U"
    }
    
    static var geminiModelId: String {
        return "gemini-2.5-flash"
    }
    
    static var geminiBaseUrl: String {
        return "https://generativelanguage.googleapis.com/v1beta"
    }
}
