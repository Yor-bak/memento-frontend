//
//  CatCompanionSheetView.swift
//  Memento_App
//
//  Created by Senior iOS Software Engineer on 06/11/2026.
//

import SwiftUI

/// Hoja modal presentada al pulsar el nodo permanente "Gatito Espacial" en la galaxia.
/// Más alta que `HelpPlanetSheetView` porque concentra tres bloques de información:
/// 1. El Gatito Espacial junto a la racha de introspección diaria.
/// 2. Las estadísticas predominantes de estado de ánimo, en forma de barras de porcentaje.
/// 3. El prediagnóstico clínico preliminar generado a partir del grafo cósmico del usuario.
public struct CatCompanionSheetView: View {
    @Environment(\.dismiss) private var dismiss

    public let dailyEntries: [DailyEntry]
    public let starNodes: [StarNode]

    private let insightsService: CompanionInsightsServiceProtocol

    public init(
        dailyEntries: [DailyEntry],
        starNodes: [StarNode],
        insightsService: CompanionInsightsServiceProtocol = CompanionInsightsService()
    ) {
        self.dailyEntries = dailyEntries
        self.starNodes = starNodes
        self.insightsService = insightsService
    }

    private var streak: Int {
        insightsService.currentStreak(from: dailyEntries)
    }

    private var moodStats: [MoodStat] {
        insightsService.moodStats(from: dailyEntries, limit: 4)
    }

    private var prediagnosis: PrediagnosisState {
        insightsService.prediagnosisState(from: starNodes)
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

            ScrollView {
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
                    .padding(.top, 18)

                    companionHeader
                    moodStatsSection
                    prediagnosisSection
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 36)
            }
        }
    }

    // MARK: - Encabezado: Gatito Espacial + Racha
    private var companionHeader: some View {
        VStack(spacing: 14) {
            HStack(spacing: 18) {
                SpaceCatView(size: 78)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.mementoGold)
                        Text("\(streak)")
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(Color.mementoWhite)
                    }
                    Text(streak == 1 ? "día de racha" : "días de racha")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.mementoSoftBlue.opacity(0.8))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.mementoDeepViolet.opacity(0.35))
                        .overlay(
                            Capsule().strokeBorder(Color.mementoGold.opacity(0.4), lineWidth: 1.0)
                        )
                )
            }

            Text("Tu Compañero Cósmico")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundColor(Color.mementoWhite)

            Text("Cada reflexión que compartes alimenta a tu Gatito Espacial y construye tu universo interior.")
                .font(.system(size: 13))
                .foregroundColor(Color.mementoWhite.opacity(0.72))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 20)
        }
        .padding(.top, 2)
    }

    // MARK: - Estadísticas Predominantes de Ánimo
    private var moodStatsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Estadísticas Predominantes", systemImage: "chart.bar.fill")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(Color.mementoWhite)

            if moodStats.isEmpty {
                Text("Completa tu Sintonía Diaria para comenzar a ver tus patrones de ánimo aquí.")
                    .font(.system(size: 13))
                    .foregroundColor(Color.mementoWhite.opacity(0.6))
            } else {
                VStack(spacing: 14) {
                    ForEach(moodStats) { stat in
                        MoodStatBarRow(stat: stat)
                    }
                }
            }
        }
        .sketchCard(accentColor: Color.mementoSoftBlue)
    }

    // MARK: - Prediagnóstico Clínico Preliminar
    private var prediagnosisSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Prediagnóstico", systemImage: "sparkles")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(Color.mementoWhite)

            switch prediagnosis {
            case .gatheringData(let progress, let currentCount, let requiredCount, let patterns):
                VStack(alignment: .leading, spacing: 10) {
                    Text("Aún no hay suficiente información para generar un prediagnóstico (\(currentCount) de \(requiredCount) reflexiones necesarias).")
                        .font(.system(size: 13))
                        .foregroundColor(Color.mementoWhite.opacity(0.75))

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.mementoWhite.opacity(0.12))
                            Capsule()
                                .fill(Color.mementoGold)
                                .frame(width: max(6, geo.size.width * progress))
                        }
                    }
                    .frame(height: 8)

                    if !patterns.isEmpty {
                        detectedPatternsList(patterns)
                    }
                }

            case .ready(let insight):
                VStack(alignment: .leading, spacing: 10) {
                    Text(insight.hypothesis)
                        .font(.system(size: 14))
                        .foregroundColor(Color.mementoWhite.opacity(0.9))
                        .lineSpacing(4)

                    HStack(spacing: 14) {
                        Label("Confianza: \(insight.confidence.rawValue)", systemImage: "gauge.medium")
                        Label(insight.generatedAt.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    }
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.mementoSoftBlue.opacity(0.75))

                    if !insight.detectedPatterns.isEmpty {
                        detectedPatternsList(insight.detectedPatterns)
                    }
                }
            }

            Text("Hipótesis generada por IA a partir de tus patrones. No es un diagnóstico y no sustituye el criterio de un profesional de salud mental.")
                .font(.system(size: 11))
                .foregroundColor(Color.mementoWhite.opacity(0.5))
                .padding(.top, 2)
        }
        .sketchCard(accentColor: Color.mementoGold)
    }

    private func detectedPatternsList(_ patterns: [DetectedPattern]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Patrones detectados")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.mementoSoftBlue.opacity(0.8))
                .padding(.top, 4)

            ForEach(patterns) { pattern in
                HStack(spacing: 8) {
                    Text(pattern.isMilestone ? "◐" : "✦")
                        .foregroundColor(pattern.isMilestone ? Color.mementoGold : Color.mementoSoftBlue)
                    Text(pattern.title)
                        .font(.system(size: 12))
                        .foregroundColor(Color.mementoWhite.opacity(0.85))
                        .lineLimit(1)
                    Spacer()
                    Text(pattern.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.mementoWhite.opacity(0.4))
                }
            }
        }
    }
}

// MARK: - Barra de Estadística de Ánimo
private struct MoodStatBarRow: View {
    let stat: MoodStat

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(stat.option.color.opacity(0.25))
                    .frame(width: 38, height: 38)
                Text(stat.option.emoji)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(stat.option.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.mementoWhite)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.mementoWhite.opacity(0.1))
                        Capsule()
                            .fill(stat.option.color)
                            .frame(width: max(6, geo.size.width * stat.ratio))
                    }
                }
                .frame(height: 8)
            }

            Text("\(Int((stat.ratio * 100).rounded()))%")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.mementoWhite.opacity(0.8))
                .frame(width: 40, alignment: .trailing)
        }
    }
}
