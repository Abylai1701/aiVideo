//
//  View+Extensions.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 11.10.2025.
//

import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
        }
    }
}
extension View {
    /// Открывает системное окно браузера  внутри приложения
    func safari(urlString: String?, isPresented: Binding<Bool>) -> some View {
        modifier(SafariModifier(isPresented: isPresented, urlString: urlString))
    }
    
    func safariWithDismiss(urlString: String?, isPresented: Binding<Bool>, onDismiss: (() -> Void)?) -> some View {
        modifier(SafariModifier(isPresented: isPresented, urlString: urlString, onDismiss: onDismiss))
    }
    
    /// Открывает системное окно создания письма внутри приложения
    func mail(recipients: [String], subject: String, messageBody: String, isPresented: Binding<Bool>) -> some View {
        modifier(
            MailModifier(isPresented: isPresented, recipients: recipients, subject: subject, messageBody: messageBody)
        )
    }
}
