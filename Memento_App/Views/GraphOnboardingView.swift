//
//  GraphOnboardingView.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import SwiftUI

/// Carrusel interactivo didáctico que explica la mecánica cósmica de Memento:
/// 1. MiniStar (Semillas de luz diarias)
/// 2. MediumStar (Patrones de 10 reflexiones)
/// 3. MoonNode (Lunas de consolidación)
/// Persiste `hasSeenGraphOnboarding = true` en `@AppStorage` al completarse.
public struct GraphOnboardingView: View {
    @AppStorage("hasSeenGraphOnboarding") private var hasSeenGraphOnboarding: Bool = false
    public let onFinish: () -> Void
    
    @State private var currentStep: Int = 0
    @State private var pulseAnim: CGFloat = 1.0
    
    public init(onFinish: @escaping () -> Void = {}) {
        self.onFinish = onFinish
    }
    
    public var body: some View {
        ZStack {
            // Fondo noche cósmico
            LinearGradient(
                colors: [
                    Color.mementoDarkPurple,
                    Color.mementoDeepViolet,
                    Color.mementoBlack
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Barra superior con botón de saltar
                HStack {
                    Spacer()
                    Button("Saltar") {
                        completeOnboarding()
                    }
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(Color.mementoSoftBlue.opacity(0.8))
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)
                
                // Carrusel paginado
                TabView(selection: $currentStep) {
                    onboardingCard(
                        step: 0,
                        title: "Semillas de Luz",
                        subtitle: "Mini Estrellas Diarias",
                        description: "Cada día, al responder tus 2 reflexiones y registrar tu bienestar, creas una pequeña estrella en tu firmamento. Son las semillas de tu consciencia cotidiana.",
                        iconContent: AnyView(miniStarIllustration)
                    )
                    .tag(0)
                    
                    onboardingCard(
                        step: 1,
                        title: "Patrones Celestiales",
                        subtitle: "Estrellas Focales",
                        description: "Al responder múltiplos de 10 preguntas, el universo de Memento detecta patrones en tus respuestas y condensa tus estrellas en un sol mayor que ilumina una nueva dimensión.",
                        iconContent: AnyView(mediumStarIllustration)
                    )
                    .tag(1)
                    
                    onboardingCard(
                        step: 2,
                        title: "El Mapa de tu Alma",
                        subtitle: "Lunas de Consciencia",
                        description: "Cuando dos constelaciones se consolidan, emerge una Luna brillante. Es el testimonio de tu evolución personal y el mapa definitivo de tu autoconocimiento.",
                        iconContent: AnyView(moonNodeIllustration)
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                
                // Barra inferior de navegación
                HStack(spacing: 16) {
                    if currentStep < 2 {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentStep += 1
                            }
                        }) {
                            HStack(spacing: 10) {
                                Text("Siguiente")
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .sketchButtonStyle(
                            strokeColor: Color.mementoGold,
                            fillColor: Color.mementoGold.opacity(0.18),
                            cornerRadius: 18
                        )
                    } else {
                        Button(action: {
                            completeOnboarding()
                        }) {
                            HStack(spacing: 10) {
                                Text("Comenzar a Explorar")
                                Image(systemName: "sparkles")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .sketchButtonStyle(
                            strokeColor: Color.mementoGold,
                            fillColor: Color.mementoGold.opacity(0.35),
                            cornerRadius: 18
                        )
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulseAnim = 1.15
            }
        }
    }
    
    private func completeOnboarding() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        hasSeenGraphOnboarding = true
        onFinish()
    }
    
    // MARK: - Tarjeta de Papel Gouache / Sketch
    private func onboardingCard(
        step: Int,
        title: String,
        subtitle: String,
        description: String,
        iconContent: AnyView
    ) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Ilustración estelar
            iconContent
                .frame(height: 140)
            
            // Títulos
            VStack(spacing: 6) {
                Text(subtitle.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(2)
                    .foregroundColor(Color.mementoNavyBlue)
                
                Text(title)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(Color.mementoDarkPurple)
            }
            
            // Descripción en texto claro
            Text(description)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.mementoDarkPurple.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 16)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .background(
            ZStack {
                // Fondo papel blanco / textura gouache
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.mementoWhite.opacity(0.96))
                
                // Trazo sketch orgánico
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(Color.mementoSoftBlue.opacity(0.5), lineWidth: 1.6)
                
                // Segundo contorno tenue punteado
                RoundedRectangle(cornerRadius: 26)
                    .strokeBorder(
                        Color.mementoNavyBlue.opacity(0.2),
                        style: StrokeStyle(lineWidth: 1.0, dash: [6, 4])
                    )
                    .padding(3)
            }
        )
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .shadow(color: Color.mementoBlack.opacity(0.45), radius: 18, x: 0, y: 8)
    }
    
    // MARK: - Ilustraciones vectoriales
    
    private var miniStarIllustration: some View {
        ZStack {
            Circle()
                .fill(Color.mementoGold.opacity(0.25))
                .frame(width: 100, height: 100)
                .scaleEffect(pulseAnim)
            
            Image(systemName: "sparkle")
                .font(.system(size: 64))
                .foregroundColor(Color.mementoGold)
                .shadow(color: Color.mementoGold.opacity(0.6), radius: 10)
        }
    }
    
    private var mediumStarIllustration: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    Color.mementoGold.opacity(0.4),
                    style: StrokeStyle(lineWidth: 1.4, dash: [6, 4])
                )
                .frame(width: 120, height: 120)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.mementoGold.opacity(0.4), Color.clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 55
                    )
                )
                .frame(width: 110, height: 110)
            
            Image(systemName: "sun.max.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.mementoGold, Color.mementoSkyBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.mementoGold.opacity(0.7), radius: 12)
        }
    }
    
    private var moonNodeIllustration: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    Color.mementoGold,
                    style: StrokeStyle(lineWidth: 1.8, dash: [4, 4])
                )
                .frame(width: 130, height: 130)
                .scaleEffect(pulseAnim * 0.95)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.mementoGold.opacity(0.5), Color.clear],
                        center: .center,
                        startRadius: 15,
                        endRadius: 65
                    )
                )
                .frame(width: 130, height: 130)
            
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 66))
                .foregroundColor(Color.mementoGold)
                .shadow(color: Color.mementoGold, radius: 14)
        }
    }
}
