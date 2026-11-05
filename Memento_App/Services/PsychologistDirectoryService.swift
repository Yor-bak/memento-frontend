//
//  PsychologistDirectoryService.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import Foundation
import CoreLocation

// MARK: - Documentación para Conectar con el Backend / API de Salud Mental
/// Para sustituir este Mock por una llamada REST real:
/// 1. Crear una clase `RemotePsychologistDirectoryService: PsychologistDirectoryServiceProtocol`.
/// 2. Implementar `URLSession.shared.data(from: ...)` hacia los endpoints:
///    - `GET /api/v1/psychologists/nearby?lat={lat}&lng={lng}&radius=15km`
///    - `GET /api/v1/psychologists/{id}/available-slots?date={isoDate}`
///    - `POST /api/v1/appointments/book` enviando `AppointmentBookingPayload`.
/// 3. Inyectar la implementación en el contenedor de dependencias o en los ViewModels.

/// Protocolo que define las operaciones del directorio de salud mental y agenda de citas.
public protocol PsychologistDirectoryServiceProtocol: Sendable {
    /// Obtiene la lista de psicólogos cercanos al usuario.
    func fetchNearbyPsychologists() async throws -> [Psychologist]
    
    /// Obtiene los bloques de horarios disponibles para una fecha específica.
    func fetchAvailableSlots(for psychologistId: UUID, on date: Date) async throws -> [TimeSlot]
    
    /// Envía y confirma la reserva de cita junto con la matriz de consentimiento.
    func bookAppointment(_ payload: AppointmentBookingPayload) async throws -> Bool
}

/// Implementación Mock robusta para pruebas y prototipado inmediato.
public final class MockPsychologistDirectoryService: PsychologistDirectoryServiceProtocol {
    
    private let mockPsychologists: [Psychologist] = [
        Psychologist(
            name: "Dra. Sofía Mendoza Alarcón",
            title: "Dra. en Psicología Clínica",
            specialty: "Terapia Cognitivo-Conductual & Duelo",
            phone: "+525541234567",
            whatsappNumber: "525541234567",
            address: "Av. Paseo de la Reforma 222, Piso 8, CDMX",
            distanceEstimate: "A 1.2 km de ti",
            rating: 4.95,
            latitude: 19.4290,
            longitude: -99.1627
        ),
        Psychologist(
            name: "Lic. Juan Carlos Pérez",
            title: "Psicoterapeuta Integrativo",
            specialty: "Ansiedad, Depresión y Mindfulness Zen",
            phone: "+525598765432",
            whatsappNumber: "525598765432",
            address: "Colonia Roma Norte, Calle Jalapa 140, CDMX",
            distanceEstimate: "A 2.5 km de ti",
            rating: 4.88,
            latitude: 19.4180,
            longitude: -99.1600
        ),
        Psychologist(
            name: "Mtra. Valeria Rivas Garza",
            title: "Mtra. en Psicología Sistémica",
            specialty: "Relaciones de Pareja, Familia y Apego",
            phone: "+525533445566",
            whatsappNumber: "525533445566",
            address: "Polanco V Sección, Campos Elíseos 345, CDMX",
            distanceEstimate: "A 3.8 km de ti",
            rating: 4.92,
            latitude: 19.4326,
            longitude: -99.1912
        ),
        Psychologist(
            name: "Dr. Mateo Echeverría Solís",
            title: "Dr. en Neuropsicología y Psicoanálisis",
            specialty: "Trauma, Autoconocimiento y Burnout Laboral",
            phone: "+525577889900",
            whatsappNumber: "525577889900",
            address: "Colonia Condesa, Parque México 28, CDMX",
            distanceEstimate: "A 4.1 km de ti",
            rating: 4.85,
            latitude: 19.4124,
            longitude: -99.1704
        )
    ]
    
    public init() {}
    
    public func fetchNearbyPsychologists() async throws -> [Psychologist] {
        // Simular latencia de red de 60ms
        try await Task.sleep(nanoseconds: 60_000_000)
        return mockPsychologists
    }
    
    public func fetchAvailableSlots(for psychologistId: UUID, on date: Date) async throws -> [TimeSlot] {
        try await Task.sleep(nanoseconds: 40_000_000)
        return [
            TimeSlot(timeString: "10:00 AM", isAvailable: true),
            TimeSlot(timeString: "11:30 AM", isAvailable: false),
            TimeSlot(timeString: "01:00 PM", isAvailable: true),
            TimeSlot(timeString: "04:00 PM", isAvailable: true),
            TimeSlot(timeString: "05:30 PM", isAvailable: true),
            TimeSlot(timeString: "07:00 PM", isAvailable: false)
        ]
    }
    
    public func bookAppointment(_ payload: AppointmentBookingPayload) async throws -> Bool {
        try await Task.sleep(nanoseconds: 80_000_000)
        return true
    }
}
