//
//  PlanetNodeView.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import SwiftUI

/// Componente visual del nodo celestial permanente "Planeta de Ayuda".
/// Ilustrado vectorialmente con trazos en `Color.mementoGold` y cuerpo sombreado en `Color.mementoNavyBlue`.
/// Proyecta un halo acogedor y anillos orbitales que invitan al usuario a buscar apoyo profesional.
public struct PlanetNodeView: View {
    public let size: CGFloat
    public let onTap: () -> Void
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var ringTilt: Double = -22.0
    
    public init(size: CGFloat = 64, onTap: @escaping () -> Void) {
        self.size = size
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onTap()
        }) {
            ZStack {
                // Halo de irradiación cálida en mementoGold
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.mementoGold.opacity(0.45),
                                Color.mementoSkyBlue.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: size * 0.2,
                            endRadius: size * 0.85
                        )
                    )
                    .frame(width: size * 1.7, height: size * 1.7)
                    .scaleEffect(pulseScale)
                
                // Anillo orbital posterior (detrás de la esfera)
                Ellipse()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.mementoGold.opacity(0.85),
                                Color.mementoSoftBlue.opacity(0.4)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2.0
                    )
                    .frame(width: size * 1.55, height: size * 0.45)
                    .rotationEffect(.degrees(ringTilt))
                
                // Cuerpo del Planeta (esfera gouache con sombreado mementoNavyBlue y mementoDeepViolet)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.mementoSkyBlue.opacity(0.9),
                                Color.mementoNavyBlue,
                                Color.mementoDarkPurple
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay(
                        // Contorno orgánico sketch
                        Circle()
                            .strokeBorder(
                                Color.mementoGold.opacity(0.6),
                                lineWidth: 1.4
                            )
                    )
                    .overlay(
                        // Destello de cráter o atmósfera
                        Circle()
                            .strokeBorder(
                                Color.mementoSoftBlue.opacity(0.25),
                                style: StrokeStyle(lineWidth: 1.0, dash: [4, 4])
                            )
                            .padding(4)
                    )
                    .shadow(color: Color.mementoGold.opacity(0.3), radius: 8)
                
                // Anillo orbital frontal (delante de la esfera, recortado en ángulo para efecto de profundidad 3D)
                Ellipse()
                    .trim(from: 0.0, to: 0.5)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.mementoGold,
                                Color.mementoSoftBlue.opacity(0.9)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2.4, lineCap: .round)
                    )
                    .frame(width: size * 1.55, height: size * 0.45)
                    .rotationEffect(.degrees(ringTilt))
                    .offset(y: size * 0.06)
                
                // Icono sutil de salud mental / corazón estelar en el centro
                Image(systemName: "cross.fill")
                    .font(.system(size: size * 0.22, weight: .bold))
                    .foregroundColor(Color.mementoWhite.opacity(0.9))
                    .shadow(color: Color.mementoGold, radius: 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                pulseScale = 1.12
            }
        }
    }
}
