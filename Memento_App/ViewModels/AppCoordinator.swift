//
//  AppCoordinator.swift
//  Memento_App
//
//  Created by Senior iOS Engineer on 15/10/2026.
//

import SwiftUI
import SwiftData

/// Orquestador central y máquina de estados de navegación para Memento.
/// Controla los ciclos de primer lanzamiento (onboarding), bloqueo por PIN/biometría y transición al cosmos diario.
@Observable
public final class AppCoordinator {
    
    // MARK: - Estados de Navegación
    public enum FirstLaunchStep: Equatable, Sendable {
        case welcome
        case auth
        case securitySetup
        case categorySelection
        case dailyCheckIn
        case dailyQuestions
    }
    
    public enum AuthenticatedDestination: Equatable, Sendable {
        case dailyCheckIn
        case dailyQuestions
        case galaxy
    }
    
    public enum AppFlowState: Equatable, Sendable {
        case firstLaunch(FirstLaunchStep)
        case locked
        case authenticated(AuthenticatedDestination)
    }
    
    // MARK: - Propiedades de Estado
    public var currentState: AppFlowState = .firstLaunch(.welcome)
    public var isPrivacySheetPresented: Bool = false
    public var selectedCategoryForSession: QuestionCategory = .autoconocimiento
    
    // Inyección de servicios
    private let securityService: SecurityServiceProtocol
    
    public init(securityService: SecurityServiceProtocol = SecurityService()) {
        self.securityService = securityService
    }
    
    // MARK: - Evaluación del Estado Inicial
    /// Siempre arranca en el flujo de primer lanzamiento (Onboarding), para que todas las pantallas
    /// introductorias se muestren en cada apertura de la app, sin importar el perfil almacenado.
    @MainActor
    public func evaluateInitialState(userProfile: UserProfile?) {
        currentState = .firstLaunch(.welcome)
    }
    
    // MARK: - Transiciones de Primer Lanzamiento
    public func advanceFromWelcome() {
        currentState = .firstLaunch(.auth)
    }
    
    public func completeAuthentication() {
        currentState = .firstLaunch(.securitySetup)
    }
    
    public func completeSecuritySetup(pin: String?, biometricsEnabled: Bool, userProfile: UserProfile) {
        userProfile.pinCode = pin
        userProfile.isBiometricsEnabled = biometricsEnabled
        currentState = .firstLaunch(.categorySelection)
    }
    
    public func selectCategoryAndProceed(category: QuestionCategory, userProfile: UserProfile) {
        selectedCategoryForSession = category
        userProfile.currentCategory = category
        
        if case .firstLaunch = currentState {
            currentState = .firstLaunch(.dailyCheckIn)
        } else {
            currentState = .authenticated(.dailyCheckIn)
        }
    }
    
    public func advanceFromCheckInToQuestions() {
        if case .firstLaunch = currentState {
            currentState = .firstLaunch(.dailyQuestions)
        } else {
            currentState = .authenticated(.dailyQuestions)
        }
    }
    
    public func completeDailyQuestions(userProfile: UserProfile) {
        userProfile.hasCompletedOnboarding = true
        userProfile.lastCheckInDate = Date()
        currentState = .authenticated(.galaxy)
    }
    
    // MARK: - Desbloqueo y Autenticación
    public func unlockWithSuccess(profile: UserProfile) {
        decidePostAuthenticationDestination(profile: profile)
    }
    
    private func decidePostAuthenticationDestination(profile: UserProfile) {
        // Si el usuario aún no completa el check-in el día de hoy, se presenta el flujo diario
        if !profile.hasCompletedDailyCheckInToday {
            // Verificar si el usuario debe volver a elegir categoría (cada 10 preguntas)
            if profile.totalQuestionsAnswered > 0 && profile.totalQuestionsAnswered % 10 == 0 {
                currentState = .firstLaunch(.categorySelection)
            } else {
                currentState = .authenticated(.dailyCheckIn)
            }
        } else {
            currentState = .authenticated(.galaxy)
        }
    }
    
    /// Bloquea manualmente la app (p. ej. al pasar a segundo plano)
    public func lockApp() {
        currentState = .locked
    }
}
