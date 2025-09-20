//
//  MessageComposerView.swift
//  LupusInFabula
//
//  Created by AI on 30/08/25.
//

import SwiftUI
import MessageUI

struct MessageComposerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MFMessageComposeViewController
    
    var recipients: [String]
    var bodyText: String
    var onFinish: ((Result<MessageComposeResult, Error>) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        // Check if we're in simulator
        #if targetEnvironment(simulator)
        // Simulate message sending in simulator
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("📱 SIMULATOR: Would send SMS to \(recipients.joined(separator: ", "))")
            print("📱 SIMULATOR: Message: \(bodyText)")
            onFinish?(.success(.sent))
        }
        // Return a dummy view controller that will be dismissed immediately
        let dummyVC = UIViewController()
        dummyVC.view.backgroundColor = .clear
        return MFMessageComposeViewController()
        #else
        // Real device - use actual message composer
        let vc = MFMessageComposeViewController()
        vc.messageComposeDelegate = context.coordinator
        vc.recipients = recipients
        vc.body = bodyText
        return vc
        #endif
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        // no-op
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let onFinish: ((Result<MessageComposeResult, Error>) -> Void)?
        init(onFinish: ((Result<MessageComposeResult, Error>) -> Void)?) {
            self.onFinish = onFinish
        }
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            onFinish?(.success(result))
            controller.dismiss(animated: true)
        }
    }
}
