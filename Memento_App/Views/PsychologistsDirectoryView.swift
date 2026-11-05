//
//  PsychologistsDirectoryView.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import SwiftUI

/// Vista principal del Directorio de Psicólogos Cercanos.
/// Muestra filtros de búsqueda rápida, encabezado con estética sketch y listado interactivo
/// de tarjetas `PsychologistCardView` con mapas embebidos de MapKit.
public struct PsychologistsDirectoryView: View {
    @Environment(\.dismiss) private var dismiss
    public let onBookingConfirmed: (AppointmentBookingPayload) -> Void
    
    @State private var psychologists: [Psychologist] = []
    @State private var selectedFilter: String = "Todos"
    @State private var isLoading: Bool = false
    @State private var selectedPsychologist: Psychologist? = nil
    
    private let directoryService: PsychologistDirectoryServiceProtocol
    private let filters = ["Todos", "Más cercanos", "Mejor valorados", "Próximas citas"]
    
    public init(
        directoryService: PsychologistDirectoryServiceProtocol = MockPsychologistDirectoryService(),
        onBookingConfirmed: @escaping (AppointmentBookingPayload) -> Void = { _ in }
    ) {
        self.directoryService = directoryService
        self.onBookingConfirmed = onBookingConfirmed
    }
    
    public var body: some View {
        NavigationStack {
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
                
                VStack(spacing: 16) {
                    // Barra superior con filtros rápidos
                    quickFiltersScrollView
                    
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .tint(Color.mementoGold)
                        Text("Buscando terapeutas en tu órbita...")
                            .font(.system(size: 13, design: .serif))
                            .foregroundColor(Color.mementoSoftBlue)
                            .padding(.top, 8)
                        Spacer()
                    } else {
                        // Lista de tarjetas de psicólogos con mapa MapKit
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(filteredPsychologists) { psychologist in
                                    PsychologistCardView(psychologist: psychologist) {
                                        selectedPsychologist = psychologist
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("PSICÓLOGOS cerca de ti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Galaxia")
                        }
                        .foregroundColor(Color.mementoSoftBlue)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "cross.case.fill")
                        .foregroundColor(Color.mementoGold)
                }
            }
            .navigationDestination(item: $selectedPsychologist) { psychologist in
                PsychologistDetailView(
                    psychologist: psychologist,
                    onBookingFinished: { payload in
                        onBookingConfirmed(payload)
                        dismiss()
                    }
                )
            }
        }
        .task {
            await loadPsychologists()
        }
    }
    
    // MARK: - Filtros Rápidos
    private var quickFiltersScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    let isSelected = selectedFilter == filter
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedFilter = filter
                        }
                    }) {
                        Text(filter)
                            .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .serif))
                            .foregroundColor(isSelected ? Color.mementoDarkPurple : Color.mementoWhite)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.mementoGold : Color.mementoDeepViolet.opacity(0.4))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(
                                                isSelected ? Color.mementoGold : Color.mementoSoftBlue.opacity(0.3),
                                                lineWidth: 1.0
                                            )
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    // MARK: - Lógica de Filtrado
    private var filteredPsychologists: [Psychologist] {
        switch selectedFilter {
        case "Más cercanos":
            return psychologists.sorted { $0.distanceEstimate < $1.distanceEstimate }
        case "Mejor valorados":
            return psychologists.sorted { $0.rating > $1.rating }
        default:
            return psychologists
        }
    }
    
    private func loadPsychologists() async {
        isLoading = true
        do {
            psychologists = try await directoryService.fetchNearbyPsychologists()
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}
