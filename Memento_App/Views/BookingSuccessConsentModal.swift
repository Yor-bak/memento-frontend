//
//  BookingSuccessConsentModal.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import SwiftUI

/// Modal animado con efecto pop/spring presentado tras agendar exitosamente una cita.
/// Contiene el check circular artesanal y la Matriz de Privacidad Dinámica (Acordeón Reactivo)
/// para que el usuario decida qué fragmentos de su universo compartir para el prediagnóstico clínico.
public struct BookingSuccessConsentModal: View {
    public let psychologistName: String
    public let onConfirmAndSend: (ClinicalDataSharingConsent) -> Void
    
    @State private var consent: ClinicalDataSharingConsent
    @State private var appearScale: CGFloat = 0.85
    @State private var appearOpacity: Double = 0.0
    @State private var checkmarkScale: CGFloat = 0.0
    
    public init(
        psychologistName: String,
        initialConsent: ClinicalDataSharingConsent = .default,
        onConfirmAndSend: @escaping (ClinicalDataSharingConsent) -> Void
    ) {
        self.psychologistName = psychologistName
        self._consent = State(initialValue: initialConsent)
        self.onConfirmAndSend = onConfirmAndSend
    }
    
    public var body: some View {
        ZStack {
            // Fondo oscuro difuminado
            Color.mementoBlack.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ScrollView {
                    VStack(spacing: 22) {
                        // 1. Icono de Check dibujado a mano animado
                        checkCircleIcon
                            .padding(.top, 8)
                        
                        // 2. Títulos
                        VStack(spacing: 8) {
                            Text("CITA AGENDADA EXITOSAMENTE")
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .tracking(1.5)
                                .foregroundColor(Color.mementoWhite)
                                .multilineTextAlignment(.center)
                            
                            Text("Le notificaremos a \(psychologistName). ¿Qué información de tu universo deseas compartir para su prediagnóstico?")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color.mementoSoftBlue)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                                .padding(.horizontal, 12)
                        }
                        
                        // 3. Matriz de Privacidad Dinámica (Acordeón Reactivo)
                        privacyMatrixCard
                        
                        // 4. Botón de Acción Final
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            onConfirmAndSend(consent)
                        }) {
                            HStack(spacing: 10) {
                                Text("Guardar y Enviar al Especialista")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                Image(systemName: "checkmark.shield.fill")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .sketchButtonStyle(
                            strokeColor: Color.mementoGold,
                            fillColor: Color.mementoGold.opacity(0.28),
                            cornerRadius: 16
                        )
                        .padding(.top, 6)
                        .padding(.bottom, 12)
                    }
                    .padding(22)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.mementoDarkPurple,
                                Color.mementoDeepViolet,
                                Color.mementoBlack
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .strokeBorder(Color.mementoSoftBlue.opacity(0.4), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 36)
            .scaleEffect(appearScale)
            .opacity(appearOpacity)
        }
        .onAppear {
            // Efecto pop / spring de entrada
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                appearScale = 1.0
                appearOpacity = 1.0
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6).delay(0.2)) {
                checkmarkScale = 1.0
            }
        }
    }
    
    // MARK: - Subcomponente del Check
    private var checkCircleIcon: some View {
        ZStack {
            // Halo exterior
            Circle()
                .fill(Color.mementoGold.opacity(0.2))
                .frame(width: 80, height: 80)
            
            Circle()
                .strokeBorder(Color.mementoGold, lineWidth: 2.2)
                .frame(width: 66, height: 66)
            
            // Checkmark dibujado
            Image(systemName: "checkmark")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.mementoGold)
                .scaleEffect(checkmarkScale)
        }
    }
    
    // MARK: - Matriz de Privacidad
    private var privacyMatrixCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Toggle Maestro
            Toggle(isOn: Binding(
                get: { consent.shareGraph },
                set: { newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        consent.shareGraph = newValue
                        if !newValue {
                            // Si se desactiva el grafo, desactivar permisos granulares
                            consent.shareMiniStars = false
                            consent.shareMediumStars = false
                            consent.shareMoonNodes = false
                            consent.shareAIPrediagnosis = false
                        } else {
                            // Al activar, sugerir compartir estrellas y síntesis
                            consent.shareMiniStars = true
                            consent.shareMediumStars = true
                            consent.shareMoonNodes = true
                            consent.shareAIPrediagnosis = true
                        }
                    }
                }
            )) {
                HStack(spacing: 10) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.mementoGold)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Compartir Grafo del Universo")
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .foregroundColor(Color.mementoWhite)
                        Text("Permiso global para transferir datos emocionales")
                            .font(.system(size: 11))
                            .foregroundColor(Color.mementoSoftBlue.opacity(0.8))
                    }
                }
            }
            .tint(Color.mementoGold)
            
            // Acordeón Reactivo (se despliega si el toggle principal está encendido)
            if consent.shareGraph {
                Divider()
                    .background(Color.mementoSoftBlue.opacity(0.2))
                    .padding(.vertical, 4)
                
                VStack(spacing: 12) {
                    consentSubToggle(
                        title: "Estrellitas Diarias",
                        detail: "Hábitos de sueño, ánimo y registros matutinos",
                        icon: "sparkle",
                        isOn: $consent.shareMiniStars
                    )
                    
                    consentSubToggle(
                        title: "Estrellas Focales",
                        detail: "Patrones detectados en cada set de 10 reflexiones",
                        icon: "sun.max.fill",
                        isOn: $consent.shareMediumStars
                    )
                    
                    consentSubToggle(
                        title: "Lunas de Consciencia",
                        detail: "Hitos consolidados de autoconocimiento",
                        icon: "moon.stars.fill",
                        isOn: $consent.shareMoonNodes
                    )
                    
                    consentSubToggle(
                        title: "Prediagnóstico del LLM",
                        detail: "Resumen conceptual de emociones generado por IA",
                        icon: "brain.head.profile",
                        isOn: $consent.shareAIPrediagnosis
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.mementoDarkPurple.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            consent.shareGraph ? Color.mementoGold.opacity(0.4) : Color.mementoSoftBlue.opacity(0.2),
                            lineWidth: 1.2
                        )
                )
        )
    }
    
    private func consentSubToggle(
        title: String,
        detail: String,
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
                    Text(detail)
                        .font(.system(size: 10))
                        .foregroundColor(Color.mementoWhite.opacity(0.6))
                }
            }
        }
        .tint(Color.mementoSkyBlue)
    }
}
