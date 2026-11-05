//
//  BookingTimeView.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import SwiftUI

/// Vista de selección de horario y modalidad de consulta (`Presencial` vs `En Línea`).
/// Conecta la selección con la presentación del modal de consentimiento de datos clínicos.
public struct BookingTimeView: View {
    public let psychologist: Psychologist
    public let selectedDate: Date
    public let onBookingFinished: (AppointmentBookingPayload) -> Void
    
    @State private var availableSlots: [TimeSlot] = []
    @State private var selectedSlot: TimeSlot? = nil
    @State private var selectedModality: ConsultationModality = .inPerson
    @State private var isLoading: Bool = false
    @State private var isConsentModalPresented: Bool = false
    
    private let directoryService: PsychologistDirectoryServiceProtocol
    
    public init(
        psychologist: Psychologist,
        selectedDate: Date,
        directoryService: PsychologistDirectoryServiceProtocol = MockPsychologistDirectoryService(),
        onBookingFinished: @escaping (AppointmentBookingPayload) -> Void
    ) {
        self.psychologist = psychologist
        self.selectedDate = selectedDate
        self.directoryService = directoryService
        self.onBookingFinished = onBookingFinished
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public var body: some View {
        ZStack {
            // Fondo noche galáctica
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
            
            ScrollView {
                VStack(spacing: 28) {
                    // Cabecera de fecha y terapeuta
                    headerSummaryCard
                        .padding(.top, 12)
                    
                    // 1. Selector de Horarios Disponibles
                    slotsSection
                    
                    // 2. Selector de Modalidad "¿CÓMO PREFIERES?"
                    modalitySection
                    
                    Spacer(minLength: 20)
                    
                    // Botón de Confirmar Cita
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        isConsentModalPresented = true
                    }) {
                        HStack(spacing: 10) {
                            Text("Confirmar Cita")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                            Image(systemName: "calendar.badge.checkmark")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .sketchButtonStyle(
                        strokeColor: Color.mementoGold,
                        fillColor: Color.mementoGold.opacity(0.32),
                        cornerRadius: 18
                    )
                    .disabled(selectedSlot == nil)
                    .opacity(selectedSlot != nil ? 1.0 : 0.4)
                    .padding(.bottom, 28)
                }
                .padding(.horizontal, 22)
            }
        }
        .navigationTitle("Seleccionar Hora")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadSlots()
        }
        .fullScreenCover(isPresented: $isConsentModalPresented) {
            BookingSuccessConsentModal(
                psychologistName: psychologist.name,
                onConfirmAndSend: { finalConsent in
                    isConsentModalPresented = false
                    if let slot = selectedSlot {
                        let payload = AppointmentBookingPayload(
                            psychologistId: psychologist.id,
                            selectedDate: selectedDate,
                            selectedSlot: slot.timeString,
                            modality: selectedModality,
                            sharedDataPermissions: finalConsent
                        )
                        onBookingFinished(payload)
                    }
                }
            )
        }
    }
    
    // MARK: - Subcomponentes
    
    private var headerSummaryCard: some View {
        VStack(spacing: 6) {
            Text("SESIÓN CON")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundColor(Color.mementoSoftBlue)
            
            Text(psychologist.name)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(Color.mementoWhite)
            
            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.system(size: 13, weight: .medium, design: .serif))
                .foregroundColor(Color.mementoGold)
                .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.mementoDeepViolet.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.mementoSoftBlue.opacity(0.3), lineWidth: 1.0)
                )
        )
    }
    
    private var slotsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("HORARIOS DISPONIBLES", systemImage: "clock.fill")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(Color.mementoGold)
            
            if isLoading {
                ProgressView()
                    .tint(Color.mementoGold)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(availableSlots) { slot in
                        slotButton(for: slot)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.mementoDarkPurple.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.mementoSoftBlue.opacity(0.25), lineWidth: 1.2)
                )
        )
    }
    
    private func slotButton(for slot: TimeSlot) -> some View {
        let isSelected = selectedSlot?.id == slot.id
        
        return Button(action: {
            guard slot.isAvailable else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedSlot = slot
            }
        }) {
            VStack(spacing: 4) {
                Text(slot.timeString)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(
                        !slot.isAvailable
                        ? Color.mementoWhite.opacity(0.25)
                        : (isSelected ? Color.mementoDarkPurple : Color.mementoWhite)
                    )
                
                Text(slot.isAvailable ? "Libre" : "Ocupado")
                    .font(.system(size: 10))
                    .foregroundColor(
                        !slot.isAvailable
                        ? Color.mementoWhite.opacity(0.2)
                        : (isSelected ? Color.mementoDarkPurple.opacity(0.8) : Color.mementoSoftBlue)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected
                        ? Color.mementoGold
                        : (slot.isAvailable ? Color.mementoDeepViolet.opacity(0.4) : Color.mementoBlack.opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isSelected ? Color.mementoGold : Color.mementoSoftBlue.opacity(slot.isAvailable ? 0.3 : 0.1),
                                lineWidth: 1.0
                            )
                    )
            )
        }
        .disabled(!slot.isAvailable)
    }
    
    private var modalitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("¿CÓMO PREFIERES?", systemImage: "figure.walk.arrival")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(Color.mementoGold)
            
            HStack(spacing: 12) {
                ForEach(ConsultationModality.allCases, id: \.self) { modality in
                    let isSelected = selectedModality == modality
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedModality = modality
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: modality.iconName)
                                .font(.system(size: 15))
                            Text(modality.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(isSelected ? Color.mementoDarkPurple : Color.mementoWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? Color.mementoGold : Color.mementoDeepViolet.opacity(0.35))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            isSelected ? Color.mementoGold : Color.mementoSoftBlue.opacity(0.3),
                                            lineWidth: isSelected ? 2.0 : 1.0
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.mementoDarkPurple.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.mementoSoftBlue.opacity(0.25), lineWidth: 1.2)
                )
        )
    }
    
    private func loadSlots() async {
        isLoading = true
        do {
            availableSlots = try await directoryService.fetchAvailableSlots(for: psychologist.id, on: selectedDate)
            selectedSlot = availableSlots.first { $0.isAvailable }
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}
