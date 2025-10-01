//
//  SupportAndFeedbackCard.swift
//  Finora
//
//  Created by Saransh Singhal on 16/9/25.
//

import SwiftUI
import MessageUI

struct SupportFeedbackCard: View {
    @State private var showingMailComposer = false
    @State private var showingFeedbackComposer = false
    @State private var showingHelpCenter = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var showingMailError = false
    
    var body: some View {
        VStack(spacing: 16) {
            SettingsRow(
                icon: "questionmark.circle.fill",
                title: "Help Center",
                subtitle: "Get help and find answers",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    showingHelpCenter = true
                }
            )
            
            SettingsRow(
                icon: "envelope.fill",
                title: "Contact Support",
                subtitle: "Get personalized help",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    openSupportEmail()
                }
            )
            
            SettingsRow(
                icon: "heart.fill",
                title: "Send Feedback",
                subtitle: "Help us improve the app",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    openFeedbackEmail()
                }
            )
            
            SettingsRow(
                icon: "star.fill",
                title: "Rate Finora",
                subtitle: "Leave a review on the App Store",
                trailing: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                },
                action: {
                    openAppStoreReview()
                }
            )
        }
        .settingsCardStyle()
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(
                recipients: ["singhalsaransh40@gmail.com"],
                subject: "Finora Support Request",
                messageBody: """
                
                
                ---
                App Version: \(Bundle.main.appVersion)
                iOS Version: \(UIDevice.current.systemVersion)
                Device: \(UIDevice.current.modelName)
                """,
                result: $mailResult
            )
        }
        .sheet(isPresented: $showingFeedbackComposer) {
            MailComposeView(
                recipients: ["singhalsaransh40@gmail.com"],
                subject: "Finora Feedback",
                messageBody: """
                
                
                ---
                App Version: \(Bundle.main.appVersion)
                iOS Version: \(UIDevice.current.systemVersion)
                """,
                result: $mailResult
            )
        }
        .navigationDestination(isPresented: $showingHelpCenter) {
            HelpCenterPage()
        }
        .alert("Email Not Available", isPresented: $showingMailError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please configure your email account in Settings or contact us at singhalsaransh40@gmail.com")
        }
    }
    
    // MARK: - Helper Functions
    
    private func openSupportEmail() {
        if MFMailComposeViewController.canSendMail() {
            showingMailComposer = true
        } else {
            // Fallback to mailto URL
            let email = "singhalsaransh40@gmail.com"
            let subject = "Finora Support Request"
            let body = "Please describe your issue:\n\n\n---\nApp Version: \(Bundle.main.appVersion)"
            
            if let emailURL = createEmailUrl(to: email, subject: subject, body: body),
               UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL)
            } else {
                showingMailError = true
            }
        }
    }
    
    private func openFeedbackEmail() {
        if MFMailComposeViewController.canSendMail() {
            showingFeedbackComposer = true
        } else {
            // Fallback to mailto URL
            let email = "singhalsaransh40@gmail.com"
            let subject = "Finora Feedback"
            let body = "Your feedback:\n\n"
            
            if let emailURL = createEmailUrl(to: email, subject: subject, body: body),
               UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL)
            } else {
                showingMailError = true
            }
        }
    }
    
    private func openAppStoreReview() {
        // Replace with your actual App Store ID when available
        let appStoreID = "YOUR_APP_ID"
        if let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        return URL(string: urlString)
    }
}

// MARK: - Mail Compose View
struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let messageBody: String
    @Binding var result: Result<MFMailComposeResult, Error>?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(messageBody, isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            parent.dismiss()
        }
    }
}

// MARK: - Extensions
extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}


