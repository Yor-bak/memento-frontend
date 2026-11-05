//
//  ClinicalModels.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 05/11/2026.
//

import Foundation
import CoreLocation

// MARK: - Modelos Clínicos y DTOs de Directorio de Salud Mental

/// Representa a un profesional de la salud mental en el directorio de Memento.
/// Totalmente serializable para sincronización con APIs REST en backend.
public struct Psychologist: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let title: String
    public let specialty: String
    public let phone: String
    public let whatsappNumber: String
    public let address: String
    public let distanceEstimate: String
    public let rating: Double
    public let latitude: Double
    public let longitude: Double
    
    public init(
        id: UUID = UUID(),
        name: String,
        title: String,
        specialty: String,
        phone: String,
        whatsappNumber: String,
        address: String,
        distanceEstimate: String,
        rating: Double = 4.9,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.specialty = specialty
        self.phone = phone
        self.whatsappNumber = whatsappNumber
        self.address = address
        self.distanceEstimate = distanceEstimate
        self.rating = rating
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Coordenada calculada para uso directo con MapKit.
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Slot de horario disponible en la agenda del psicólogo.
public struct TimeSlot: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let timeString: String
    public var isAvailable: Bool
    
    public init(id: UUID = UUID(), timeString: String, isAvailable: Bool = true) {
        self.id = id
        self.timeString = timeString
        self.isAvailable = isAvailable
    }
}

/// Tipo de modalidad de consulta psicológica.
public enum ConsultationModality: String, Codable, CaseIterable, Sendable {
    case inPerson = "Presencial"
    case online = "En Línea"
    
    /// Icono ilustrativo para botones de selección.
    public var iconName: String {
        switch self {
        case .inPerson: return "person.2.fill"
        case .online: return "network"
        }
    }
}

/// Matriz granular de consentimiento de datos compartidos con el especialista.
/// Diseñada bajo principios de Privacy-First y mínimo privilegio clínico.
public struct ClinicalDataSharingConsent: Codable, Sendable, Equatable {
    /// Permiso maestro: activa o desactiva la transferencia del universo emocional.
    public var shareGraph: Bool
    /// Permiso granular: comparte hábitos de sueño, ánimo y micro-reflexiones diarias.
    public var shareMiniStars: Bool
    /// Permiso granular: comparte patrones recurrentes de 10 preguntas.
    public var shareMediumStars: Bool
    /// Permiso granular: comparte hitos de consolidación y autoconsciencia.
    public var shareMoonNodes: Bool
    /// Permiso granular: comparte la síntesis y prediagnóstico emitido por el modelo LLM.
    public var shareAIPrediagnosis: Bool
    
    public init(
        shareGraph: Bool = false,
        shareMiniStars: Bool = false,
        shareMediumStars: Bool = false,
        shareMoonNodes: Bool = false,
        shareAIPrediagnosis: Bool = false
    ) {
        self.shareGraph = shareGraph
        self.shareMiniStars = shareMiniStars
        self.shareMediumStars = shareMediumStars
        self.shareMoonNodes = shareMoonNodes
        self.shareAIPrediagnosis = shareAIPrediagnosis
    }
    
    /// Configuración predeterminada segura (privacidad por diseño: todo apagado).
    public static var `default`: ClinicalDataSharingConsent {
        ClinicalDataSharingConsent(
            shareGraph: false,
            shareMiniStars: false,
            shareMediumStars: false,
            shareMoonNodes: false,
            shareAIPrediagnosis: false
        )
    }
    
    /// Permiso completo cuando el usuario confía plenamente en compartir todo su universo.
    public static var fullAccess: ClinicalDataSharingConsent {
        ClinicalDataSharingConsent(
            shareGraph: true,
            shareMiniStars: true,
            shareMediumStars: true,
            shareMoonNodes: true,
            shareAIPrediagnosis: true
        )
    }
}

/// Payload completo de la cita listo para serializar a JSON hacia el backend.
/// Endpoint objetivo: `POST /api/v1/appointments/book`
public struct AppointmentBookingPayload: Codable, Sendable {
    public let appointmentId: UUID
    public let psychologistId: UUID
    public let selectedDate: Date
    public let selectedSlot: String
    public let modality: ConsultationModality
    public let sharedDataPermissions: ClinicalDataSharingConsent
    public let createdAt: Date
    
    public init(
        appointmentId: UUID = UUID(),
        psychologistId: UUID,
        selectedDate: Date,
        selectedSlot: String,
        modality: ConsultationModality,
        sharedDataPermissions: ClinicalDataSharingConsent,
        createdAt: Date = Date()
    ) {
        self.appointmentId = appointmentId
        self.psychologistId = psychologistId
        self.selectedDate = selectedDate
        self.selectedSlot = selectedSlot
        self.modality = modality
        self.sharedDataPermissions = sharedDataPermissions
        self.createdAt = createdAt
    }
}
