//
//  HelpPlanetSheetView.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import SwiftUI

/// Hoja modal presentada al pulsar el nodo permanente "Planeta" en la galaxia.
/// Ofrece un espacio compasivo con el Gatito Espacial y da acceso directo al directorio de psicólogos.
public struct HelpPlanetSheetView: View {
    @Environment(\.dismiss) private var dismiss
    public let onNavigateToDirectory: () -> Void
    
    public init(onNavigateToDirectory: @escaping () -> Void) {
        self.onNavigateToDirectory = onNavigateToDirectory
    }
    
    public var body: some View {
        ZStack {
            // Fondo noche en acuarela
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
            
            VStack(spacing: 24) {
                // Barra superior de cierre
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.mementoSoftBlue.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                
                // Mascota cósmica acompañante
                SpaceCatView(size: 78)
                    .padding(.top, 6)
                
                // Encabezado amigable
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color.mementoGold)
                        
                        Text("Encuentra ayuda cerca de ti")
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .foregroundColor(Color.mementoWhite)
                    }
                    
                    Text("Cuidar tu universo interior también significa pedir apoyo. Conecta con especialistas en salud mental cercanos a tu ubicación.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.mementoWhite.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 28)
                }
                
                Spacer()
                
                // Botón de acción principal "Ir"
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    dismiss()
                    onNavigateToDirectory()
                }) {
                    HStack(spacing: 12) {
                        Text("Ir al Directorio de Psicólogos")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                }
                .sketchButtonStyle(
                    strokeColor: Color.mementoGold,
                    fillColor: Color.mementoGold.opacity(0.22),
                    cornerRadius: 18
                )
                .padding(.horizontal, 28)
                .padding(.bottom, 32)
            }
        }
    }
}
