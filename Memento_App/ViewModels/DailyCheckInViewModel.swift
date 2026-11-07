//
//  DailyCheckInViewModel.swift
//  Memento_App
//
//  Created by Senior iOS Engineer on 15/10/2026.
//

import SwiftUI
import SwiftData

/// ViewModel para la gestión del Quizz Interactivo de Bienestar Diario (`DailyCheckInView`).
/// Controla los valores táctiles de sueño, estado de ánimo y nutrición, empaquetando el DTO final.
@Observable
public final class DailyCheckInViewModel {
    
    // Nivel de sueño (1 a 5)
    public var sleepHoursQuality: Double = 3.0
    
    // Estado de ánimo seleccionado (1 a 5)
    public var selectedMoodIndex: Int = 3
    
    // Alimentación / Bienestar físico (1 a 5)
    public var nutritionScore: Int = 3
    
    // Opciones del selector horizontal de estado de ánimo
    public struct MoodOption: Identifiable, Sendable {
        public let id: Int
        public let emoji: String
        public let label: String
        public let color: Color

        /// Catálogo oficial de estados de ánimo, expuesto como fuente única de verdad para que
        /// otras pantallas (p. ej. las estadísticas del Gatito Espacial) puedan reutilizarlo
        /// sin necesidad de instanciar este ViewModel.
        public static let catalog: [MoodOption] = [
            MoodOption(id: 1, emoji: "🌧️", label: "Agobiado", color: Color(red: 0.55, green: 0.60, blue: 0.75)),
            MoodOption(id: 2, emoji: "☁️", label: "Melancólico", color: Color(red: 0.65, green: 0.70, blue: 0.85)),
            MoodOption(id: 3, emoji: "🌱", label: "Sereno", color: Color(red: 0.60, green: 0.85, blue: 0.70)),
            MoodOption(id: 4, emoji: "☀️", label: "Esperanzado", color: Color(red: 0.95, green: 0.80, blue: 0.50)),
            MoodOption(id: 5, emoji: "✨", label: "En Plenitud", color: Color(red: 0.85, green: 0.75, blue: 0.95))
        ]
    }

    public let moodOptions: [MoodOption] = MoodOption.catalog
    
    public init() {}
    
    /// Texto y trazo dinámico para la calidad del sueño.
    public var sleepDescription: (label: String, zCount: String) {
        let rounded = Int(sleepHoursQuality.rounded())
        switch rounded {
        case 1: return ("Sueño inquieto / Insomnio", "z")
        case 2: return ("Sueño ligero o interrumpido", "zz")
        case 3: return ("Descanso equilibrado", "zzZ")
        case 4: return ("Sueño profundo y reparador", "zzzZZ")
        default: return ("Revitalización absoluta", "zzzzZZZ✨")
        }
    }
    
    /// Empaqueta la respuesta actual en el DTO estructurado para enviar al backend/LLM.
    public func createSubmission() -> DailyCheckInSubmission {
        let mood = moodOptions.first { $0.id == selectedMoodIndex }
        return DailyCheckInSubmission(
            sleepQuality: Int(sleepHoursQuality.rounded()),
            moodScore: selectedMoodIndex,
            nutritionScore: nutritionScore,
            moodLabel: mood?.label ?? "Sereno"
        )
    }
    
    /// Actualiza el estado de ánimo disparando feedback háptico.
    public func selectMood(id: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            selectedMoodIndex = id
        }
    }
    
    /// Actualiza la escala de nutrición y bienestar físico con feedback táctil.
    public func setNutritionScore(_ score: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            nutritionScore = score
        }
    }
}
