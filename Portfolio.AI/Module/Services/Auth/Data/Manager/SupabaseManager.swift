//
//  SupabaseManager.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 6/9/25.
//

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: AppConfig.supabaseInitUrl)!,
            supabaseKey: AppConfig.anonKey
        )
    }
}
