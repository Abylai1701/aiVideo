//
//  SafariHelpers.swift
//  Helpers
//
//  Created by Abylaikhan Abilkayr on 05.11.2025.
//

import SwiftUI
import SafariServices
import MessageUI

struct SafariModifier: ViewModifier {
    
    // MARK: - Public Properties
    
    @Binding var isPresented: Bool
    let urlString: String?
    
    var onDismiss: (() -> Void)?
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                if let urlString, let url = URL(string: urlString) {
                    SafariView(url: url)
                }
            }
    }
}


struct SafariView {
    
    // MARK: - Public Properties
    
    let url: URL
}

// MARK: - UIViewControllerRepresentable

extension SafariView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let viewController = SFSafariViewController(url: url, configuration: config)
        viewController.dismissButtonStyle = .close
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct MailModifier: ViewModifier {
    
    // MARK: - Public Properties
    
    @Binding var isPresented: Bool
    let recipients: [String]
    let subject: String
    let messageBody: String
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                MailView(recipients: recipients, subject: subject, messageBody: messageBody)
            }
    }
}

struct MailView {
    
    // MARK: - Public Properties
    
    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    let recipients: [String]
    let subject: String
    let messageBody: String
    
    // MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
}

extension MailView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients(recipients)
        controller.setSubject(subject)
        controller.setMessageBody(messageBody, isHTML: false)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}


extension MailView {
    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        // MARK: - Public Properties
        
        var parent: MailView
        
        // MARK: - Initializers
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        // MARK: - Public Methods
        
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                parent.dismiss()
            }
        }
    }
}
