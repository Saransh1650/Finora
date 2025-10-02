//
//  ForceUpdateDialog.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 10/1/25.
//

import SwiftUI

struct ForceUpdateDialog: View {
    let updateResult: UpdateCheckResult
    let onUpdatePressed: () -> Void
    let onLaterPressed: (() -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Dialog content
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text(updateResult.isForceUpdate ? "Update Required" : "Update Available")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                
                // Content
                VStack(spacing: 16) {
                    if updateResult.isForceUpdate {
                        Text("A new version of Portfolio AI is required to continue using the app.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    } else {
                        Text("A new version of Portfolio AI is available with exciting new features and improvements.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    
                    // Version info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Version")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(updateResult.currentVersion)
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Latest Version")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(updateResult.latestVersion)
                                .font(.body)
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Release notes if available
                    if let releaseNotes = updateResult.releaseNotes, !releaseNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What's New")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(releaseNotes)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    // Update button
                    Button(action: onUpdatePressed) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Update Now")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                       
                    }
                    
                    // Later button (only for optional updates)
                    if !updateResult.isForceUpdate, let laterAction = onLaterPressed {
                        Button(action: laterAction) {
                            Text("Maybe Later")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 20)
            )
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Preview
#Preview {
    ForceUpdateDialog(
        updateResult: UpdateCheckResult(
            isUpdateRequired: true,
            isForceUpdate: true,
            latestVersion: "2.1.0",
            currentVersion: "2.0.0",
            updateUrl: "https://apps.apple.com/app/portfolio-ai",
            releaseNotes: "• Enhanced portfolio analysis\n• Improved chat experience\n• Bug fixes and performance improvements"
        ),
        onUpdatePressed: {
            print("Update pressed")
        },
        onLaterPressed: {
            print("Later pressed")
        }
    )
}

#Preview("Optional Update") {
    ForceUpdateDialog(
        updateResult: UpdateCheckResult(
            isUpdateRequired: true,
            isForceUpdate: false,
            latestVersion: "2.0.1",
            currentVersion: "2.0.0",
            updateUrl: "https://apps.apple.com/app/portfolio-ai",
            releaseNotes: "• Minor bug fixes\n• Performance improvements"
        ),
        onUpdatePressed: {
            print("Update pressed")
        },
        onLaterPressed: {
            print("Later pressed")
        }
    )
}
