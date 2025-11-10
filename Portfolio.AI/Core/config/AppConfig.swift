//
//  app_config.swift
//  med_tech
//
//  Created by Saransh Singhal on 11/8/25.
//

import Foundation

class AppConfig {

    private static func secrets() -> [String: Any] {
        let fileName = "secrets"
        let path = Bundle.main.path(forResource: fileName, ofType: "json")!
        let data = try! Data(
            contentsOf: URL(fileURLWithPath: path),
            options: .mappedIfSafe
        )
        return try! JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    static var supabaseInitUrl: String {
        let url =
            secrets()["SUPABASE_INIT_URL"]
        return "https://\(url as! String)"
    }

    static var anonKey: String {
        return  secrets()["ANON_KEY"] as! String
    }

    static var geminiApiKey: String {
        return  secrets()["GEMINI_API_KEY"] as! String
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

    static var backendUrl: String {
        return secrets()["BACKEND_URL"] as! String
    }
}
