//
//  SettingsView.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import SwiftUI

/// Vista de Ajustes Generales de Memento.
/// Incluye la sección "Privacidad y Datos Compartidos" que permite al usuario auditar y revocar
/// en cualquier momento los permisos de datos clínicos que se comparten con psicólogos.
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Preferencias persistentes de consentimiento de datos clínicos
    @AppStorage("consent_shareGraph") private var shareGraph: Bool = false
    @AppStorage("consent_shareMiniStars") private var shareMiniStars: Bool = false
    @AppStorage("consent_shareMediumStars") private var shareMediumStars: Bool = false
    @AppStorage("consent_shareMoonNodes") private var shareMoonNodes: Bool = false
    @AppStorage("consent_shareAIPrediagnosis") private var shareAIPrediagnosis: Bool = false
    
    // Bandera para relanzar el onboarding de constelaciones
    @AppStorage("hasSeenGraphOnboarding") private var hasSeenGraphOnboarding: Bool = true
    
    @State private var isShowingOnboardingSheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.mementoDarkPurple
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Sección 1: Privacidad y Datos Compartidos
                        privacySection
                            .padding(.top, 12)
                        
                        // Sección 2: Guía Didáctica del Cosmos
                        onboardingGuideSection
                        
                        // Sección 3: Información de Seguridad y Versión
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Ajustes del Santuario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                    .foregroundColor(Color.mementoGold)
                }
            }
            .sheet(isPresented: $isShowingOnboardingSheet) {
                GraphOnboardingView {
                    isShowingOnboardingSheet = false
                }
            }
        }
    }
    
    // MARK: - Sección de Privacidad
    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("PRIVACIDAD Y DATOS COMPARTIDOS", systemImage: "hand.raised.shield.fill")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(Color.mementoGold)
            
            VStack(spacing: 14) {
                // Toggle Maestro
                Toggle(isOn: Binding(
                    get: { shareGraph },
                    set: { newValue in
                        withAnimation(.easeInOut) {
                            shareGraph = newValue
                            if !newValue {
                                shareMiniStars = false
                                shareMediumStars = false
                                shareMoonNodes = false
                                shareAIPrediagnosis = false
                            }
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Compartir Grafo del Universo")
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .foregroundColor(Color.mementoWhite)
                        Text("Habilita o revoca todo el intercambio de datos con psicólogos")
                            .font(.system(size: 11))
                            .foregroundColor(Color.mementoSoftBlue)
                    }
                }
                .tint(Color.mementoGold)
                
                if shareGraph {
                    Divider().background(Color.mementoSoftBlue.opacity(0.2))
                    
                    VStack(spacing: 12) {
                        subToggleRow(
                            title: "Estrellitas Diarias",
                            subtitle: "Hábitos y check-ins de bienestar",
                            icon: "sparkle",
                            isOn: $shareMiniStars
                        )
                        subToggleRow(
                            title: "Estrellas Focales",
                            subtitle: "Patrones detectados en tus reflexiones",
                            icon: "sun.max.fill",
                            isOn: $shareMediumStars
                        )
                        subToggleRow(
                            title: "Lunas de Consciencia",
                            subtitle: "Diagnósticos consolidados y mapa interior",
                            icon: "moon.stars.fill",
                            isOn: $shareMoonNodes
                        )
                        subToggleRow(
                            title: "Prediagnóstico del LLM",
                            subtitle: "Síntesis psicológica automatizada",
                            icon: "brain.head.profile",
                            isOn: $shareAIPrediagnosis
                        )
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.mementoDeepViolet.opacity(0.35))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color.mementoSoftBlue.opacity(0.25), lineWidth: 1.0)
                    )
            )
        }
    }
    
    private func subToggleRow(
        title: String,
        subtitle: String,
        icon: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(isOn.wrappedValue ? Color.mementoGold : Color.mementoSoftBlue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.mementoWhite)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(Color.mementoWhite.opacity(0.6))
                }
            }
        }
        .tint(Color.mementoSkyBlue)
    }
    
    // MARK: - Guía Didáctica
    private var onboardingGuideSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("GUÍA DEL COSMOS", systemImage: "sparkles")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(Color.mementoGold)
            
            Button(action: {
                isShowingOnboardingSheet = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Repasar Guía de Constelaciones")
                            .font(.system(size: 14, weight: .semibold, design: .serif))
                            .foregroundColor(Color.mementoWhite)
                        Text("Aprende cómo nacen las estrellas, soles y lunas")
                            .font(.system(size: 11))
                            .foregroundColor(Color.mementoSoftBlue)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.mementoSoftBlue)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.mementoDeepViolet.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.mementoSoftBlue.opacity(0.25), lineWidth: 1.0)
                        )
                )
            }
        }
    }
    
    // MARK: - Información y Seguridad
    private var aboutSection: some View {
        VStack(spacing: 8) {
            Text("MEMENTO • DIARIO DE INTROSPECCIÓN")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundColor(Color.mementoSoftBlue.opacity(0.6))
            
            Text("Tus datos clínicos y reflexiones están resguardados bajo estándares estrictos de confidencialidad ética.")
                .font(.system(size: 11))
                .foregroundColor(Color.mementoWhite.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }
}
