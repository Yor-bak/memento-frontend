//
//  GalaxyHomeView.swift
//  Memento_App
//
//  Created by Senior iOS UI/UX Engineer on 15/10/2026.
//

import SwiftUI
import SwiftData

/// Vista Principal de Memento: Grafo del Universo Interno (`GalaxyHomeView`).
/// Diseñada con un Custom Layout de galería de arte:
/// - Cabecera exterior con título tipográfico de grabado ("MEMENTO") y acceso a Ajustes.
/// - Marco tipo passepartout / lámina de acuarela con elevación y doble bisel artesanal.
/// - Lienzo cósmico interactivo confinado con Pan, Zoom, Gatito Espacial y el nodo permanente "Planeta".
/// - Apertura automática de `GraphOnboardingView` en la primera visita (`hasSeenGraphOnboarding = false`).
/// - Integración con el directorio de psicólogos mediante `HelpPlanetSheetView` y `PsychologistsDirectoryView`.
public struct GalaxyHomeView: View {
    public let userProfile: UserProfile
    public var onLockApp: (() -> Void)? = nil
    public let onTriggerDailyCheckIn: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StarNode.date, order: .forward) private var starNodes: [StarNode]
    
    @State private var viewModel = GalaxyViewModel()
    
    // Control de Onboarding Didáctico de Constelaciones
    @AppStorage("hasSeenGraphOnboarding") private var hasSeenGraphOnboarding: Bool = false
    @State private var isShowingGraphOnboarding: Bool = false
    
    // Hojas y Navegación
    @State private var isHelpPlanetPresented: Bool = false
    @State private var isDirectoryPresented: Bool = false
    @State private var isSettingsPresented: Bool = false
    @State private var bookedAppointmentPayload: AppointmentBookingPayload? = nil
    
    public init(
        userProfile: UserProfile,
        onLockApp: (() -> Void)? = nil,
        onTriggerDailyCheckIn: @escaping () -> Void
    ) {
        self.userProfile = userProfile
        self.onLockApp = onLockApp
        self.onTriggerDailyCheckIn = onTriggerDailyCheckIn
    }
    
    public var body: some View {
        ZStack {
            // 1. Fondo de Galería (Pared / Sala exterior en mementoDarkPurple a mementoBlack)
            LinearGradient(
                colors: [
                    Color.mementoDarkPurple,
                    Color.mementoBlack
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 14) {
                // 2. Cabecera Exterior: Título de Galería fuera del Passepartout + Botón de Ajustes
                galleryHeaderSection
                    .padding(.top, 8)
                
                // 3. Marco Passepartout / Lámina de Acuarela
                passepartoutCanvasFrame
                
                // 4. Barra Inferior: Introspección diaria pendiente (fuera de la lámina)
                if !userProfile.hasCompletedDailyCheckInToday {
                    dailyCheckInButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 14)
                }
            }
        }
        // Hoja de Detalle de Nodo Estelar
        .sheet(isPresented: $viewModel.isDetailSheetPresented) {
            if let selected = viewModel.selectedNode {
                NodeDetailSheet(node: selected)
                    .presentationDetents([.medium, .large])
            }
        }
        // Hoja de Ayuda y Salud Mental al pulsar el Planeta
        .sheet(isPresented: $isHelpPlanetPresented) {
            HelpPlanetSheetView {
                isDirectoryPresented = true
            }
            .presentationDetents([.medium])
        }
        // Hoja de Ajustes y Privacidad de Datos Compartidos
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
        }
        // Onboarding de Constelaciones (se dispara en el primer arribo a GalaxyHomeView)
        .sheet(isPresented: $isShowingGraphOnboarding) {
            GraphOnboardingView {
                isShowingGraphOnboarding = false
            }
        }
        // Directorio de Psicólogos a Pantalla Completa
        .fullScreenCover(isPresented: $isDirectoryPresented) {
            PsychologistsDirectoryView(
                onBookingConfirmed: { payload in
                    bookedAppointmentPayload = payload
                }
            )
        }
        .task {
            viewModel.seedInitialUniverseIfNeeded(modelContext: modelContext)
            viewModel.refreshConstellations(from: starNodes)
            
            // Presentar onboarding didáctico si es la primera vez que ingresa a la Galaxia
            if !hasSeenGraphOnboarding {
                // Pequeño retardo suave para permitir que cargue la interfaz visual
                try? await Task.sleep(nanoseconds: 350_000_000)
                isShowingGraphOnboarding = true
            }
        }
        .onChange(of: starNodes) { _, newNodes in
            viewModel.refreshConstellations(from: newNodes)
        }
    }
    
    // MARK: - Cabecera Exterior (Fuera del Passepartout)
    private var galleryHeaderSection: some View {
        HStack {
            // Espaciador izquierdo compensatorio
            Color.clear
                .frame(width: 40, height: 40)
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("MEMENTO")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .tracking(8)
                    .foregroundColor(Color.mementoWhite)
                    .shadow(color: Color.mementoSoftBlue.opacity(0.4), radius: 8)
                
                Text("\(starNodes.count) cuerpos celestes • \(userProfile.totalQuestionsAnswered) reflexiones")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.mementoSoftBlue.opacity(0.75))
            }
            
            Spacer()
            
            // Botón de Ajustes y Privacidad
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                isSettingsPresented = true
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.mementoSoftBlue)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.mementoDeepViolet.opacity(0.3))
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.mementoSoftBlue.opacity(0.25), lineWidth: 1.0)
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Marco Passepartout / Lámina de Acuarela
    private var passepartoutCanvasFrame: some View {
        ZStack {
            // Sombra profunda de la lámina de arte sobre la pared
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.mementoDarkPurple.opacity(0.5))
                .shadow(color: Color.mementoBlack.opacity(0.85), radius: 24, x: 0, y: 12)
                .shadow(color: Color.mementoDeepViolet.opacity(0.3), radius: 36, x: 0, y: 0)
            
            // Lienzo cósmico recortado estrictamente dentro de la ventana de la lámina
            GalaxyCanvasView(
                nodes: starNodes,
                links: viewModel.links,
                onSelectNode: { node in
                    viewModel.selectNode(node)
                },
                onSelectPlanet: {
                    isHelpPlanetPresented = true
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            // Marco exterior artesanal (Bisel sketch y textura de papel de grabado)
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    Color.mementoSoftBlue.opacity(0.35),
                    lineWidth: 1.5
                )
            
            // Segundo trazo interior sutil punteado
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(
                    Color.mementoSoftBlue.opacity(0.18),
                    style: StrokeStyle(lineWidth: 1.0, dash: [6, 4])
                )
                .padding(2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
    }
    
    // MARK: - Botón Inferior de Introspección Diaria
    private var dailyCheckInButton: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onTriggerDailyCheckIn()
        }) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundColor(Color.mementoGold)
                Text("Realizar Introspección Diaria")
                    .font(.system(.body, design: .serif, weight: .medium))
            }
            .frame(maxWidth: .infinity)
        }
        .sketchButtonStyle(
            strokeColor: Color.mementoGold,
            fillColor: Color.mementoDeepViolet.opacity(0.45),
            cornerRadius: 18
        )
    }
}
