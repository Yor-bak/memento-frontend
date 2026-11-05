//
//  PsychologistCardView.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import SwiftUI
import MapKit

/// Tarjeta de presentación para un profesional en el directorio de salud mental.
/// Integra un mapa `MapKit` recortado en el fondo con un overlay oscuro translúcido,
/// avatar artesanal, credenciales clínicas, distancia estimada y botón de selección.
public struct PsychologistCardView: View {
    public let psychologist: Psychologist
    public let onSelect: () -> Void
    
    public init(psychologist: Psychologist, onSelect: @escaping () -> Void) {
        self.psychologist = psychologist
        self.onSelect = onSelect
    }
    
    public var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onSelect()
        }) {
            ZStack(alignment: .bottom) {
                // 1. Fondo: MapKit centrado en el consultorio
                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: psychologist.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
                    )
                )) {
                    Marker(psychologist.name, coordinate: psychologist.coordinate)
                        .tint(Color.mementoGold)
                }
                .frame(height: 230)
                .allowsHitTesting(false) // Permite el desplazamiento suave en el ScrollView
                .clipShape(RoundedRectangle(cornerRadius: 22))
                
                // 2. Gradiente protector de contraste (Acuarela Gouache)
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.mementoDarkPurple.opacity(0.4),
                        Color.mementoDarkPurple.opacity(0.92),
                        Color.mementoBlack.opacity(0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
                
                // 3. Badge superior de distancia estimada
                VStack {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.mementoGold)
                            Text(psychologist.distanceEstimate)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(Color.mementoWhite)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.mementoDarkPurple.opacity(0.85))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.mementoSoftBlue.opacity(0.35), lineWidth: 1.0)
                                )
                        )
                        
                        Spacer()
                        
                        // Rating estelar
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.mementoGold)
                            Text(String(format: "%.1f", psychologist.rating))
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color.mementoWhite)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.mementoDeepViolet.opacity(0.85))
                        )
                    }
                    .padding(14)
                    
                    Spacer()
                }
                
                // 4. Panel inferior de información y acción
                HStack(spacing: 14) {
                    // Avatar con borde sketch
                    avatarView
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(psychologist.name)
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundColor(Color.mementoWhite)
                            .lineLimit(1)
                        
                        Text(psychologist.specialty)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.mementoSoftBlue)
                            .lineLimit(1)
                        
                        Text(psychologist.address)
                            .font(.system(size: 11))
                            .foregroundColor(Color.mementoWhite.opacity(0.65))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Flecha sketch de selección
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color.mementoGold)
                        .shadow(color: Color.mementoGold.opacity(0.4), radius: 6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            // Marco exterior con bisel sketch
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(Color.mementoSoftBlue.opacity(0.4), lineWidth: 1.4)
            )
            .shadow(color: Color.mementoBlack.opacity(0.6), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.mementoDeepViolet, Color.mementoNavyBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
            
            // Iniciales
            Text(initials(for: psychologist.name))
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(Color.mementoGold)
            
            // Contorno sketch artesanal
            Circle()
                .strokeBorder(Color.mementoSoftBlue.opacity(0.6), lineWidth: 1.2)
                .frame(width: 48, height: 48)
        }
    }
    
    private func initials(for name: String) -> String {
        let clean = name.replacingOccurrences(of: "Dra. ", with: "")
            .replacingOccurrences(of: "Dr. ", with: "")
            .replacingOccurrences(of: "Lic. ", with: "")
            .replacingOccurrences(of: "Mtra. ", with: "")
        let components = clean.components(separatedBy: " ").filter { !$0.isEmpty }
        let letters = components.compactMap { $0.first }
        return String(letters.prefix(2)).uppercased()
    }
}
