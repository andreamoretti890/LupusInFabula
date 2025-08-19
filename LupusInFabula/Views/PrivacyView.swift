//
//  PrivacyView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text("Privacy & Data")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Your privacy is important to us")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    // Privacy sections
                    VStack(alignment: .leading, spacing: 20) {
                        PrivacySection(
                            icon: "wifi.slash",
                            title: "Offline Only",
                            description: "This app works completely offline. No internet connection is required, and no data is sent to external servers."
                        )
                        
                        PrivacySection(
                            icon: "iphone",
                            title: "Local Storage",
                            description: "All game data, including saved configurations and game history, is stored locally on your device using Apple's SwiftData framework."
                        )
                        
                        PrivacySection(
                            icon: "eye.slash",
                            title: "No Tracking",
                            description: "We don't collect any personal information, analytics, or usage data. Your game sessions remain private."
                        )
                        
                        PrivacySection(
                            icon: "trash",
                            title: "Data Control",
                            description: "You can delete all app data at any time by removing the app from your device. No data persists beyond your control."
                        )
                    }
                    
                    // Additional info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Technical Details")
                            .font(.headline)
                        
                        Text("• Game configurations are saved using SwiftData\n• No cloud synchronization\n• No third-party analytics\n• No advertising networks\n• No data sharing with external services")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacySection: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    PrivacyView()
}
