//
//  PsychologistDetailView.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import SwiftUI
import MapKit

/// Vista de perfil y detalle del psicólogo.
/// Integra la sección de contacto con enlaces nativos `tel://` y `https://wa.me/`,
/// mapa de consultorio y calendario interactivo con fechas destacadas en `Color.mementoGold`.
public struct PsychologistDetailView: View {
    public let psychologist: Psychologist
    public let onBookingFinished: (AppointmentBookingPayload) -> Void
    
    @State private var selectedDate: Date = Date()
    @State private var currentMonthOffset: Int = 0
    @State private var navigateToTimeSelection: Bool = false
    
    public init(
        psychologist: Psychologist,
        onBookingFinished: @escaping (AppointmentBookingPayload) -> Void
    ) {
        self.psychologist = psychologist
        self.onBookingFinished = onBookingFinished
    }
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["D", "L", "M", "M", "J", "V", "S"]
    
    public var body: some View {
        ZStack {
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
                VStack(spacing: 24) {
                    // 1. Cabecera con Avatar, Datos y Mini-Mapa
                    headerCard
                        .padding(.top, 8)
                    
                    // 2. Sección de Contacto Directo (Llamada & WhatsApp)
                    contactSection
                    
                    // 3. Sección "AGENDA TU CITA" (Calendario Interactivo)
                    calendarSection
                    
                    // 4. Botón "Continuar a Horarios"
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        navigateToTimeSelection = true
                    }) {
                        HStack(spacing: 12) {
                            Text("Continuar a Horarios")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                            Image(systemName: "clock.arrow.circlepath")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .sketchButtonStyle(
                        strokeColor: Color.mementoGold,
                        fillColor: Color.mementoGold.opacity(0.3),
                        cornerRadius: 18
                    )
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Perfil del Terapeuta")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToTimeSelection) {
            BookingTimeView(
                psychologist: psychologist,
                selectedDate: selectedDate,
                onBookingFinished: onBookingFinished
            )
        }
    }
    
    // MARK: - Cabecera y Mapa
    private var headerCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Avatar grande
                ZStack {
                    Circle()
                        .fill(Color.mementoNavyBlue)
                        .frame(width: 70, height: 70)
                    
                    Text(initials(for: psychologist.name))
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color.mementoGold)
                    
                    Circle()
                        .strokeBorder(Color.mementoSoftBlue.opacity(0.6), lineWidth: 1.5)
                        .frame(width: 70, height: 70)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(psychologist.name)
                        .font(.system(size: 19, weight: .bold, design: .serif))
                        .foregroundColor(Color.mementoWhite)
                    
                    Text(psychologist.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.mementoGold)
                    
                    Text(psychologist.specialty)
                        .font(.system(size: 12))
                        .foregroundColor(Color.mementoSoftBlue)
                        .lineLimit(2)
                }
                Spacer()
            }
            
            // Mini Mapa de Ubicación
            VStack(alignment: .leading, spacing: 8) {
                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: psychologist.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )
                )) {
                    Marker(psychologist.name, coordinate: psychologist.coordinate)
                        .tint(Color.mementoGold)
                }
                .frame(height: 110)
                .allowsHitTesting(false)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.mementoSoftBlue.opacity(0.3), lineWidth: 1.0)
                )
                
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color.mementoGold)
                    Text(psychologist.address)
                        .font(.system(size: 11))
                        .foregroundColor(Color.mementoWhite.opacity(0.75))
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.mementoDarkPurple.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(Color.mementoSoftBlue.opacity(0.3), lineWidth: 1.2)
                )
        )
    }
    
    // MARK: - Sección de Contacto
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("CONTACTO DIRECTO", systemImage: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(Color.mementoGold)
            
            HStack(spacing: 12) {
                // Llamada Telefónica
                if let phoneUrl = URL(string: "tel://\(psychologist.phone)") {
                    Link(destination: phoneUrl) {
                        HStack(spacing: 8) {
                            Image(systemName: "phone.fill")
                            Text("Llamar")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color.mementoWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.mementoNavyBlue.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.mementoSoftBlue.opacity(0.4), lineWidth: 1.0)
                                )
                        )
                    }
                }
                
                // Mensaje por WhatsApp
                if let waUrl = URL(string: "https://wa.me/\(psychologist.whatsappNumber)") {
                    Link(destination: waUrl) {
                        HStack(spacing: 8) {
                            Image(systemName: "message.fill")
                            Text("WhatsApp")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color.mementoDarkPurple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.mementoGold)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.mementoWhite.opacity(0.5), lineWidth: 1.0)
                                )
                        )
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
                        .strokeBorder(Color.mementoSoftBlue.opacity(0.25), lineWidth: 1.0)
                )
        )
    }
    
    // MARK: - Calendario Interactivo
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("AGENDA TU CITA", systemImage: "calendar")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundColor(Color.mementoGold)
                
                Spacer()
                
                Text(monthName(for: currentMonthOffset))
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(Color.mementoWhite)
            }
            
            // Fila de días de la semana
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mementoSoftBlue)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Rejilla de días del mes
            let daysInMonth = generateDays(for: currentMonthOffset)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear.frame(height: 36)
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
    
    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isAvailable = isDateAvailable(date)
        let isPast = date < calendar.startOfDay(for: Date())
        
        return Button(action: {
            guard !isPast else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDate = date
            }
        }) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.mementoGold)
                        .frame(width: 34, height: 34)
                } else if isAvailable && !isPast {
                    Circle()
                        .strokeBorder(Color.mementoGold.opacity(0.7), lineWidth: 1.5)
                        .frame(width: 34, height: 34)
                }
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 13, weight: isSelected ? .bold : (isToday ? .bold : .regular)))
                    .foregroundColor(
                        isPast
                        ? Color.mementoWhite.opacity(0.2)
                        : (isSelected ? Color.mementoDarkPurple : Color.mementoWhite)
                    )
            }
            .frame(height: 36)
        }
        .disabled(isPast)
    }
    
    private func isDateAvailable(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        // Disponible de lunes a viernes (no fines de semana)
        return weekday != 1 && weekday != 7
    }
    
    private func generateDays(for offset: Int) -> [Date?] {
        guard let currentMonth = calendar.date(byAdding: .month, value: offset, to: Date()) else { return [] }
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        
        let firstDay = monthInterval.start
        let weekdayOfFirst = calendar.component(.weekday, from: firstDay) // 1 = Domingo
        
        var days: [Date?] = Array(repeating: nil, count: weekdayOfFirst - 1)
        
        let range = calendar.range(of: .day, in: .month, for: currentMonth) ?? 1..<31
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
    
    private func monthName(for offset: Int) -> String {
        guard let date = calendar.date(byAdding: .month, value: offset, to: Date()) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).capitalized
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
