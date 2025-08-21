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
                        
                        Text("privacy.title")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("privacy.subtitle")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    // Privacy sections
                    VStack(alignment: .leading, spacing: 20) {
                        PrivacySection(
                            icon: "wifi.slash",
                            title: "privacy.offline_only.title".localized,
                            description: "privacy.offline_only.description".localized
                        )
                        
                        PrivacySection(
                            icon: "iphone",
                            title: "privacy.local_storage.title".localized,
                            description: "privacy.local_storage.description".localized
                        )
                        
                        PrivacySection(
                            icon: "eye.slash",
                            title: "privacy.no_tracking.title".localized,
                            description: "privacy.no_tracking.description".localized
                        )
                        
                        PrivacySection(
                            icon: "trash",
                            title: "privacy.data_control.title".localized,
                            description: "privacy.data_control.description".localized
                        )
                    }
                    
                    // Additional info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("privacy.technical_details")
                            .font(.headline)
                        
                        Text("privacy.technical_details_list")
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("button.close", systemImage: "xmark") {
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
