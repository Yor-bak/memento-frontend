//
//  CompanionInsightsService.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 06/11/2026.
//

import Foundation

// MARK: - Modelos de Insights del Gatito Espacial

/// Representa el porcentaje de incidencia de un estado de ánimo dentro del historial de
/// `DailyEntry` del usuario, listo para graficarse como barra de estadística.
public struct MoodStat: Identifiable, Sendable {
    public let option: DailyCheckInViewModel.MoodOption
    /// Proporción (0...1) de entradas diarias que reportaron este estado de ánimo.
    public let ratio: Double

    public var id: Int { option.id }

    public init(option: DailyCheckInViewModel.MoodOption, ratio: Double) {
        self.option = option
        self.ratio = ratio
    }
}

/// Patrón detectado (Constelación Focal o Luna de Consciencia) listo para listarse en el
/// resumen de prediagnóstico, análogo al Panel de Patrones del Prediagnóstico clínico.
public struct DetectedPattern: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let date: Date
    public let isMilestone: Bool

    public init(id: UUID = UUID(), title: String, date: Date, isMilestone: Bool) {
        self.id = id
        self.title = title
        self.date = date
        self.isMilestone = isMilestone
    }
}

/// Nivel de confianza heurístico de la hipótesis de prediagnóstico, derivado de cuántas
/// consolidaciones (estrellas medianas / lunas) respaldan el patrón dominante.
public enum PrediagnosisConfidence: String, Sendable {
    case baja = "Baja"
    case media = "Media"
    case alta = "Alta"
}

/// Hipótesis de prediagnóstico lista para presentarse al usuario, con su respaldo de patrones.
public struct PrediagnosisInsight: Sendable {
    public let hypothesis: String
    public let confidence: PrediagnosisConfidence
    public let generatedAt: Date
    public let detectedPatterns: [DetectedPattern]
}

/// Estado del prediagnóstico: o bien aún se está reuniendo suficiente información,
/// o bien ya hay una hipótesis lista para mostrarse.
public enum PrediagnosisState: Sendable {
    case gatheringData(progress: Double, currentCount: Int, requiredCount: Int, detectedPatterns: [DetectedPattern])
    case ready(PrediagnosisInsight)
}

// MARK: - Contrato del Servicio

/// Contrato para el cálculo de los insights que acompañan al Gatito Espacial: racha de
/// introspección diaria, estadísticas predominantes de ánimo y prediagnóstico clínico preliminar.
public protocol CompanionInsightsServiceProtocol: Sendable {
    func currentStreak(from entries: [DailyEntry]) -> Int
    func moodStats(from entries: [DailyEntry], limit: Int) -> [MoodStat]
    func prediagnosisState(from nodes: [StarNode]) -> PrediagnosisState
}

// MARK: - Implementación Local (Heurística)

/// Implementación local basada en los datos ya persistidos en SwiftData.
/// La hipótesis de prediagnóstico se deriva de la categoría dominante entre los patrones
/// consolidados (estrellas medianas y lunas), como un sustituto heurístico mientras no existe
/// un backend / LLM real conectado.
///
/// Para sustituir por una síntesis real generada por el modelo de lenguaje:
/// 1. Crear `RemoteCompanionInsightsService: CompanionInsightsServiceProtocol`.
/// 2. En `prediagnosisState(from:)`, enviar los nodos (o su resumen) a
///    `POST /api/v1/prediagnosis/generate` y mapear la respuesta a `PrediagnosisInsight`.
/// 3. Inyectar la nueva implementación donde se instancia `CompanionInsightsService()`.
public final class CompanionInsightsService: CompanionInsightsServiceProtocol {

    /// Cantidad mínima de Estrellas Diarias (mini) requerida antes de ofrecer una hipótesis,
    /// alineada con el umbral de consolidación de `GalaxyService` (10 minis → 1 Constelación Focal).
    public static let requiredMiniNodesForPrediagnosis = 10

    public init() {}

    // MARK: - Racha de Introspección
    /// Calcula los días consecutivos con al menos una `DailyEntry`, contando hacia atrás desde
    /// hoy (o desde ayer, si el usuario aún no ha completado su Sintonía Diaria hoy).
    public func currentStreak(from entries: [DailyEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        let calendar = Calendar.current
        let distinctDays = Set(entries.map { calendar.startOfDay(for: $0.timestamp) })

        var cursor = calendar.startOfDay(for: Date())
        if !distinctDays.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor),
                  distinctDays.contains(yesterday) else {
                return 0
            }
            cursor = yesterday
        }

        var streak = 0
        while distinctDays.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    // MARK: - Estadísticas Predominantes de Ánimo
    /// Devuelve los estados de ánimo con incidencia real, ordenados de forma descendente por
    /// proporción, listos para graficarse como barras de porcentaje.
    public func moodStats(from entries: [DailyEntry], limit: Int = 4) -> [MoodStat] {
        guard !entries.isEmpty else { return [] }
        let total = Double(entries.count)
        var counts: [Int: Int] = [:]
        for entry in entries {
            counts[entry.moodScore, default: 0] += 1
        }

        return DailyCheckInViewModel.MoodOption.catalog
            .map { option in MoodStat(option: option, ratio: Double(counts[option.id] ?? 0) / total) }
            .filter { $0.ratio > 0 }
            .sorted { $0.ratio > $1.ratio }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Prediagnóstico Clínico Preliminar
    /// Evalúa si existen suficientes Estrellas Diarias para ofrecer una hipótesis, y de ser así
    /// construye una síntesis a partir de la categoría temática dominante y las consolidaciones
    /// (Constelaciones Focales y Lunas) ya detectadas en el grafo cósmico del usuario.
    public func prediagnosisState(from nodes: [StarNode]) -> PrediagnosisState {
        let minis = nodes.filter { $0.starType == .mini }
        let mediums = nodes.filter { $0.starType == .medium }
        let moons = nodes.filter { $0.starType == .moon }

        let patterns = (mediums + moons)
            .sorted { $0.date < $1.date }
            .map { DetectedPattern(title: $0.contentSummary, date: $0.date, isMilestone: $0.starType == .moon) }

        guard minis.count >= Self.requiredMiniNodesForPrediagnosis else {
            let progress = min(1.0, Double(minis.count) / Double(Self.requiredMiniNodesForPrediagnosis))
            return .gatheringData(
                progress: progress,
                currentCount: minis.count,
                requiredCount: Self.requiredMiniNodesForPrediagnosis,
                detectedPatterns: patterns
            )
        }

        let category = dominantCategory(in: nodes)
        let confidence: PrediagnosisConfidence = !moons.isEmpty ? .alta : (!mediums.isEmpty ? .media : .baja)
        let generatedAt = nodes.map(\.date).max() ?? Date()

        return .ready(
            PrediagnosisInsight(
                hypothesis: hypothesisText(for: category, patternCount: patterns.count),
                confidence: confidence,
                generatedAt: generatedAt,
                detectedPatterns: patterns
            )
        )
    }

    // MARK: - Heurísticas Privadas
    private func dominantCategory(in nodes: [StarNode]) -> QuestionCategory {
        let counts = Dictionary(grouping: nodes, by: { $0.category }).mapValues { $0.count }
        let dominantRaw = counts.max { $0.value < $1.value }?.key
        return QuestionCategory(rawValue: dominantRaw ?? "") ?? .autoconocimiento
    }

    private func hypothesisText(for category: QuestionCategory, patternCount: Int) -> String {
        let base: String
        switch category {
        case .familia:
            base = "Tus reflexiones recientes giran con fuerza en torno a vínculos familiares y herencias emocionales del hogar."
        case .amigos:
            base = "Se detecta un patrón sostenido de introspección sobre pertenencia y reciprocidad en tus amistades."
        case .amor:
            base = "Predomina un hilo conductor de vulnerabilidad y apego en tus respuestas sobre el amor."
        case .trabajo:
            base = "Tus reflexiones apuntan a una tensión entre vocación personal y expectativas externas en el trabajo."
        case .proposito:
            base = "Aparece de forma recurrente la búsqueda de sentido y dirección vital en tu propósito."
        case .autoconocimiento:
            base = "Se observa un proceso activo de diálogo interno y aceptación de verdades sobre ti mismo."
        }
        let suffix = patternCount > 1
            ? " Esta constelación se ha consolidado a través de múltiples patrones detectados en tu universo."
            : " Este es un primer patrón consolidado dentro de tu universo interior."
        return base + suffix
    }
}
