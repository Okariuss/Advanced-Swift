//
//  ProfileView.swift
//  NilSafeProfile
//
//  Created by Okan Orkun on 9.06.2026.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    
    @State private var isAlertPresented = false
    @State private var isToastPresented = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.6), .purple.opacity(0.4), .cyan.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // --- CONTENT LAYER ---
                ScrollView {
                    VStack(spacing: 20) {
                        
                        if viewModel.isLoading {
                            ProgressView("Loading Profile...")
                                .padding()
                                .glassCardStyle()
                        } else if let profile = viewModel.profile {
                            
                            // 1. PROFILE HEADER CARD
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    AsyncImage(url: viewModel.avatarURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Circle().fill(Color.secondary.opacity(0.2))
                                    }
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        // Nil Coalescing (??)
                                        Text(profile.name ?? "Anonymous User")
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.primary)
                                        
                                        // String Interpolation (Swift 6.2)
                                        Text("Age: \(profile.age, default: "Unknown")")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                
                                Button("Test Optional Assignment (a? = 10)") {
                                    viewModel.clearProfileNameOnlyIfProfileExists()
                                }
                                .font(.caption)
                                .buttonStyle(.borderedProminent)
                            }
                            .glassCardStyle()
                            
                            // 2. CONTACT INFORMATION CARD
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Contact Information")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.secondary)
                                
                                CustomLabeledContent(title: "Email", value: profile.email ?? "Not provided")
                                
                                Divider().background(.white.opacity(0.2))
                                
                                CustomLabeledContent(
                                    title: "Security Status",
                                    value: profile.phone ?? viewModel.getExpensiveSystemStatus()
                                )
                            }
                            .glassCardStyle()
                            
                            // 3. WORK INFORMATION CARD
                            // ── Shorthand if let limitation ──
                            if let company = profile.company {
                                if let name = company.name {
                                    VStack(alignment: .leading, spacing: 14) {
                                        Text("Work Information").font(.caption).bold().foregroundColor(.secondary)
                                        CustomLabeledContent(title: "Company", value: name)
                                        
                                        // ── map on Optional ──
                                        if let departmentText = company.department.map({ "Dept: \($0)" }) {
                                            Text(departmentText).font(.caption).foregroundColor(.secondary)
                                        }
                                    }
                                    .glassCardStyle()
                                }
                            }
                            
                            // 4. SKILLS CARD
                            if !viewModel.validatedSkills.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("Skills (Cleaned via compactMap)")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.secondary)
                                    
                                    FlowLayout(items: viewModel.validatedSkills) { skill in
                                        Text(skill)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(.white.opacity(0.2))
                                            .clipShape(Capsule())
                                    }
                                    
                                    Button("Trigger 'for case let' console log") {
                                        viewModel.triggerPatternMatchingData()
                                    }
                                    .font(.caption2).buttonStyle(.bordered)
                                }
                                .glassCardStyle()
                            }
                            
                        } else if let error = viewModel.errorMessage {
                            ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                                .glassCardStyle()
                        }
                        
                        // 5. EDUCATIONAL NOTES CARD
                        EducationalGuidanceSection()
                    }
                    .padding()
                }
                
                if isToastPresented {
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text(viewModel.toastMessage)
                                .font(.subheadline).bold()
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
                        .shadow(radius: 10)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("NilSafe Profile")
            .onChange(of: viewModel.alertMessage) { _, newValue in
                if !newValue.isEmpty {
                    isAlertPresented = true
                }
            }
            .onChange(of: viewModel.toastMessage) { _, newValue in
                if !newValue.isEmpty {
                    withAnimation(.spring()) {
                        isToastPresented = true
                    }
                    
                    Task {
                        try? await Task.sleep(nanoseconds: 2_500_000_000)
                        withAnimation(.easeOut) {
                            isToastPresented = false
                            viewModel.clearToast()
                        }
                    }
                }
            }
            .alert(viewModel.alertTitle, isPresented: $isAlertPresented) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .task {
                await viewModel.loadProfile()
                
                // ── Custom Force-Unwrap !! ──
                let _ = Bundle.main.path(forResource: "Info", ofType: "plist") !! "CRITICAL: Info.plist missing!"
            }
        }
    }
}
