//
//  NodeDetailSheet.swift
//  Memento_App
//
//  Created by Senior iOS UI/UX Engineer on 15/10/2026.
//

import SwiftUI

/// Hoja modal / popover que presenta el detalle de las reflexiones pasadas al tocar un nodo del grafo galáctico.
/// Construida con la paleta estricta del Design System oficial de Memento.
public struct NodeDetailSheet: View {
    public let node: StarNode
    @Environment(\.dismiss) private var dismiss
    
    public init(node: StarNode) {
        self.node = node
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.mementoDarkPurple
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // Icono y Tipo de Nodo
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(node.accentColor.opacity(0.25))
                                    .frame(width: 58, height: 58)
                                
                                Image(systemName: iconForNodeType(node.starType))
                                    .font(.system(size: 26))
                                    .foregroundColor(node.accentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(node.starType.displayTitle)
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(Color.mementoWhite)
                                
                                Text(node.date.formatted(date: .long, time: .shortened))
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(Color.mementoSoftBlue.opacity(0.7))
                            }
                        }
                        .padding(.top, 16)
                        
                        Divider().background(Color.mementoSoftBlue.opacity(0.2))
                        
                        // Etiqueta de Categoría
                        HStack {
                            Text("Dimensión:")
                                .font(.system(size: 14))
                                .foregroundColor(Color.mementoSoftBlue.opacity(0.8))
                            
                            Text(node.category)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(node.accentColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(node.accentColor.opacity(0.18))
                                )
                        }
                        
                        // Resumen Introspectivo
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Esencia de la Reflexión")
                                .font(.system(size: 16, weight: .semibold, design: .serif))
                                .foregroundColor(Color.mementoWhite)
                            
                            Text(node.contentSummary)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color.mementoWhite.opacity(0.88))
                                .lineSpacing(6)
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.mementoDeepViolet.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(Color.mementoSoftBlue.opacity(0.2), lineWidth: 1.0)
                                        )
                                )
                        }
                        
                        // Información del Grafo Cósmico
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Topología Estelar")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.mementoSoftBlue.opacity(0.7))
                            
                            HStack {
                                Label(
                                    node.parentNodeId != nil ? "Conectada a Constelación Madre" : "Nodo Autónomo / Raíz",
                                    systemImage: node.parentNodeId != nil ? "point.3.connected.trianglepath.dotted" : "circle.dashed"
                                )
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(Color.mementoSoftBlue)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.mementoBlack.opacity(0.25))
                        )
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(Color.mementoSoftBlue)
                }
            }
        }
    }
    
    private func iconForNodeType(_ type: StarNodeType) -> String {
        switch type {
        case .mini: return "sparkle"
        case .medium: return "star.circle.fill"
        case .moon: return "moon.stars.fill"
        }
    }
}

