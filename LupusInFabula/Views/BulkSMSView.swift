//
//  BulkSMSView.swift
//  LupusInFabula
//
//  Created by AI on 30/08/25.
//

import SwiftUI
import MessageUI

struct BulkSMSView: View {
    @Environment(GameService.self) private var gameService: GameService
    @State private var showingMessageComposer = false
    @State private var currentMessageIndex = 0
    @State private var messages: [(player: Player, message: String)] = []
    @State private var showNoMessagingAlert = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        VStack {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "message.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.green)
                
                Text("Send Roles via SMS")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("All players will receive their roles via text message")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                #if targetEnvironment(simulator)
                HStack {
                    Image(systemName: "iphone")
                        .foregroundStyle(.orange)
                    Text("Simulator Mode - Messages will be simulated")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                #endif
            }
            .padding(.top)
            
            // Player list with status
            ScrollView {
                ForEach(gameService.currentSession?.players ?? [], id: \.id) { player in
                    PlayerSMSRow(
                        player: player,
                        message: gameService.generateRoleMessage(for: player) ?? "",
                        isSent: currentMessageIndex > messages.firstIndex(where: { $0.player.id == player.id }) ?? -1
                    )
                }
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 16) {
                if currentMessageIndex < messages.count {
                    Button("Send Next Message") {
                        #if targetEnvironment(simulator)
                        currentMessageIndex += 1
                        #else
                        sendNextMessage()
                        #endif
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!canSendMessages())
                } else {
                    Button("Start Game") {
                        print("🔄 Starting game from BulkSMSView")
                        gameService.skipRevealPhase()
                        print("🔄 skipRevealPhase called")
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                
                Button("Skip SMS (Phone Pass Mode)") {
                    gameService.skipRevealPhase()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(24)
        .navigationTitle("Bulk SMS")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            prepareMessages()
        }
        .sheet(isPresented: $showingMessageComposer) {
            if currentMessageIndex < messages.count {
                let currentMessage = messages[currentMessageIndex]
                MessageComposerView(
                    recipients: [currentMessage.player.phoneNumber ?? ""],
                    bodyText: currentMessage.message
                ) { result in
                    handleMessageResult(result)
                }
            }
        }
        .alert("Messaging Not Available", isPresented: $showNoMessagingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device cannot send messages.")
        }
        .alert("All Messages Sent!", isPresented: $showSuccessAlert) {
            Button("Start Game Now") {
                gameService.skipRevealPhase()
            }
            Button("Wait", role: .cancel) { }
        } message: {
            Text("All players have received their roles via SMS. The game will start automatically in 3 seconds, or you can start it now.")
        }
        .onChange(of: showSuccessAlert) { wasShowing, isShowing in
            if wasShowing && !isShowing {
                // Alert was dismissed - auto-start game after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    gameService.skipRevealPhase()
                }
            }
        }
    }
    
    private func prepareMessages() {
        guard let session = gameService.currentSession else { return }
        messages = session.players.compactMap { player in
            guard let message = gameService.generateRoleMessage(for: player) else { return nil }
            return (player: player, message: message)
        }
    }
    
    private func canSendMessages() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return MFMessageComposeViewController.canSendText()
        #endif
    }
    
    private func sendNextMessage() {
        guard currentMessageIndex < messages.count else { return }
        
        if !canSendMessages() {
            showNoMessagingAlert = true
            return
        }
        
        showingMessageComposer = true
    }
    
    private func handleMessageResult(_ result: Result<MessageComposeResult, Error>) {
        switch result {
        case .success(let composeResult):
            switch composeResult {
            case .sent, .cancelled:
                currentMessageIndex += 1
                // Check if all messages have been sent
                if currentMessageIndex >= messages.count {
                    // All messages sent - show success and auto-start after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showSuccessAlert = true
                    }
                }
            case .failed:
                // Could add retry logic here
                currentMessageIndex += 1
            @unknown default:
                currentMessageIndex += 1
            }
        case .failure:
            currentMessageIndex += 1
        }
    }
}

struct PlayerSMSRow: View {
    let player: Player
    let message: String
    let isSent: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            Image(systemName: isSent ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isSent ? .green : .secondary)
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.displayName)
                    .font(.headline)
                    .foregroundStyle(isSent ? .secondary : .primary)
                
                if let phone = player.phoneNumber {
                    Text(phone)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No phone number")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            
            Spacer()
            
            // Role preview (if sent)
            if isSent {
                Text("✓ Sent")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    BulkSMSView()
}
