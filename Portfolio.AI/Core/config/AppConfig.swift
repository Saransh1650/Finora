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
}
