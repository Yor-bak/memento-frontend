# MEMENTO APP — ADN DE ARQUITECTURA Y SINCRONIZACIÓN TÉCNICA

> **Documento de Control de Versiones Vivo**  
> Proyecto: Memento (Diario de Introspección con Visualización de Galaxia en Grafo y Directorio Clínico)  
> Plataforma: iOS 17.0+ | Swift 5.10 / Swift 6 | SwiftUI + SwiftData + MapKit + LocalAuthentication  
> Fecha de actualización: Noviembre 2026

---

## 1. ADN del Repositorio y Arquitectura

### Stack Tecnológico
* **Lenguaje**: Swift 5.10 / Swift 6 (Strict Concurrency ready).
* **Framework UI**: SwiftUI con `@Observable` (Observation Framework moderno).
* **Persistencia**: SwiftData (`ModelContainer`, `ModelContext`, `@Model`) + `@AppStorage`.
* **Mapas y Geolocalización**: MapKit nativo de iOS 17 (`Map`, `Marker`).
* **Seguridad y Biometría**: LocalAuthentication (`LAContext`) + PIN en SwiftData (`UserProfile.pinCode`).
* **Feedback Háptico**: `UIImpactFeedbackGenerator` / `UINotificationFeedbackGenerator`.
* **Motion & Custom Layouts**: Lienzo 2D interactivo con soporte de Pan (`DragGesture`) y Zoom (`MagnificationGesture`) enmarcado en Custom Layout tipo Passepartout / Lámina de Acuarela.

### Design System Oficial: Paleta Estricta (Color+Memento)
Regla: Cero colores arbitrarios fuera de los 8 tokens oficiales del sistema:
- `mementoDarkPurple` (`#432E54`): Base atmosférica nocturna, sombras de oclusión y fondo exterior de galería.
- `mementoDeepViolet` (`#4B4376`): Nebulosas intermedias, relleno de tarjetas sketch y fondos de modales.
- `mementoNavyBlue` (`#215597`): Núcleo de profundidad acuarela en el cosmos y sombreado planetario.
- `mementoSkyBlue` (`#3B80C6`): Capas de luz de acuarela, enlaces activos y acento de dimensiones emocionales.
- `mementoSoftBlue` (`#99BCEC`): Trazos de biseles sketch, estrellas menores, tipografía secundaria y halos tenues.
- `mementoGold` (`#F4C542`): Nodos supremos (Lunas), estrellas medianas, anillos del Planeta, fechas destacadas y botones primarios.
- `mementoWhite` (`#FFFFFF`): Núcleos de estrellas, texto titular y destellos de polvo estelar.
- `mementoBlack` (`#000000`): Fondo exterior del muro, sombras de elevación y oclusión ambiental.

### Patrón Arquitectónico: MVVM + Coordinator + Service/Repository
* **AppCoordinator**: Orquestador central de flujo y máquina de estados (`firstLaunch`, `locked`, `authenticated`).
* **Services / Repositories**: Capa de abstracción basada en protocolos:
  - `SecurityServiceProtocol`: Biometría y validación de PIN.
  - `GalaxyServiceProtocol`: Distribución áurea de constelaciones y reglas de agrupación.
  - `QuestionRepositoryProtocol`: Catálogo reflexivo y preguntas diarias.
  - `PsychologistDirectoryServiceProtocol`: Catálogo de terapeutas con geolocalización y reserva de slots.
* **ViewModels**: Modelos de vista anotados con `@Observable` para actualizar el estado atómicamente.

---

## 2. Mapa de Navegación y Flujo Clínico (Fases 1 y 2)

```
[Arranque de App]
       │
       ▼
[AppCoordinator / RootView]
       │
       ├─► Onboarding / Flujo Inicial
       │      └─► WelcomeView -> AuthView -> SetupSecurityView -> CategorySelectionView -> DailyCheckInView -> DailyQuestionsView
       │
       ├─► GalaxyHomeView (Lienzo Passepartout)
       │      ├─► Primer ingreso: Presenta GraphOnboardingView (Carrusel didáctico de 3 pasos)
       │      ├─► Tap en Estrellas/Lunas: NodeDetailSheet
       │      ├─► Tap en Icono Superior: SettingsView (Control de Privacidad y Datos Compartidos)
       │      └─► Tap en Nodo Permanente "Planeta":
       │             └─► HelpPlanetSheetView (Mascota Espacial + "Ir")
       │                   └─► PsychologistsDirectoryView (MapKit inline + Filtros)
       │                         └─► PsychologistDetailView (Mini mapa + tel:// + wa.me/ + Calendario Gold)
       │                               └─► BookingTimeView (Grid TimeSlots + Modalidad Presencial/Online)
       │                                     └─► BookingSuccessConsentModal (Pop/Spring + Acordeón reactivo)
```

---

## 3. Modelo de Datos y DTOs

1. **`UserProfile` (SwiftData)**:
   - `id`, `isBiometricsEnabled`, `pinCode`, `hasCompletedOnboarding`, `totalQuestionsAnswered`, `lastCheckInDate`, `currentCategoryRaw`.
2. **`DailyEntry` (SwiftData)**:
   - `id`, `timestamp`, `sleepQuality`, `moodScore`, `nutritionScore`, `answers: [String]`, `category`, `associatedStarNodeId`.
3. **`StarNode` (SwiftData)**:
   - `id`, `date`, `category`, `typeRaw` (`mini`, `medium`, `moon`), `positionX`, `positionY`, `contentSummary`, `parentNodeId`.
4. **`Psychologist` (DTO)**:
   - `id`, `name`, `title`, `specialty`, `phone`, `whatsappNumber`, `address`, `distanceEstimate`, `rating`, `latitude`, `longitude`, `coordinate`.
5. **`TimeSlot` (DTO)**:
   - `id`, `timeString`, `isAvailable`.
6. **`ConsultationModality` (Enum)**:
   - `.inPerson` ("Presencial"), `.online` ("En Línea").
7. **`ClinicalDataSharingConsent` (DTO Privacy-First)**:
   - `shareGraph` (Toggle maestro), `shareMiniStars`, `shareMediumStars`, `shareMoonNodes`, `shareAIPrediagnosis`.
8. **`AppointmentBookingPayload` (DTO Backend)**:
   - `appointmentId`, `psychologistId`, `selectedDate`, `selectedSlot`, `modality`, `sharedDataPermissions`, `createdAt`.

---

## 4. Índice de Archivos del Proyecto

```
Memento_App/
├── .gitignore
├── MEMENTO_DNA.md
├── Memento_AppApp.swift
│
├── Models/
│   ├── ClinicalModels.swift           <- Psychologist, TimeSlot, Modality, Consent, BookingPayload
│   ├── DTOs.swift                     <- DailyCheckInSubmission, ReflectionSubmission, etc.
│   ├── DailyEntry.swift               <- @Model SwiftData
│   ├── QuestionCategory.swift         <- Categorías temáticas de introspección
│   ├── StarNode.swift                 <- @Model SwiftData
│   └── UserProfile.swift              <- @Model SwiftData
│
├── Services/
│   ├── GalaxyService.swift            <- Matemáticas espaciales y reglas de consolidación
│   ├── PsychologistDirectoryService.swift <- Catálogo y reserva de especialistas
│   ├── QuestionRepository.swift       <- Repositorio reflexivo
│   └── SecurityService.swift          <- LocalAuthentication y PIN
│
├── UI/
│   ├── DesignSystem/
│   │   └── Color+Memento.swift        <- 8 tokens oficiales estrictos
│   └── Components/
│       ├── GalaxyCanvasView.swift     <- Lienzo estelar con pan, zoom, gatito y nodo Planeta
│       ├── HandmadeKeypadView.swift   <- Teclado numérico artesanal
│       ├── PlanetNodeView.swift       <- Ilustración vectorial del planeta con anillos
│       ├── PsychologistCardView.swift <- Tarjeta con MapKit embebido y badges
│       ├── SketchStyles.swift         <- Botones y tarjetas estilo sketch
│       ├── SpaceCatView.swift         <- Mascota espacial procedural flotante
│       └── ZenListeningRingView.swift <- Anillos de respiración reactivos al foco
│
├── ViewModels/
│   ├── AppCoordinator.swift           <- Máquina de estados
│   ├── DailyCheckInViewModel.swift
│   ├── DailyQuestionsViewModel.swift
│   └── GalaxyViewModel.swift
│
└── Views/
    ├── AuthView.swift
    ├── BookingSuccessConsentModal.swift <- Modal pop/spring con acordeón reactivo de permisos
    ├── BookingTimeView.swift          <- Selector de hora y modalidad
    ├── CategorySelectionView.swift
    ├── CustomPinLockView.swift
    ├── DailyCheckInView.swift
    ├── DailyQuestionsView.swift
    ├── GalaxyHomeView.swift           <- Passepartout, nodo planeta, onboarding y ajustes
    ├── GraphOnboardingView.swift      <- Carrusel didáctico de constelaciones
    ├── HelpPlanetSheetView.swift      <- Sheet compasivo del planeta
    ├── NodeDetailSheet.swift
    ├── PrivacyNoticeView.swift
    ├── PsychologistDetailView.swift   <- Perfil, mini mapa, tel://, wa.me/ y calendario gold
    ├── PsychologistsDirectoryView.swift <- Listado con MapKit y filtros rápidos
    ├── RootView.swift
    ├── SettingsView.swift             <- Gestión permanente de Privacidad y Datos Compartidos
    ├── SetupSecurityView.swift
    └── WelcomeView.swift
```

---

## 5. Lecciones Aprendidas y Decisiones de UI/UX (Fase 2)

1. **MapKit Inline Eficiente**: Al embeber `Map` dentro de `PsychologistCardView`, se deshabilitó el *hit testing* del mapa (`allowsHitTesting(false)`) para que el `ScrollView` principal conserve un deslizamiento a 120 fps sin colisión de gestos de arrastre del mapa.
2. **Matriz de Privacidad Reactiva (Acordeón)**: El consentimiento de datos clínicos se estructuró con un toggle maestro ("Compartir Grafo del Universo"). Solo cuando el usuario lo activa conscientemente, se despliegan suavemente (`withAnimation(.easeInOut)`) los niveles granulares (hábitos, patrones, lunas y prediagnóstico LLM).
3. **Acceso Dual a la Configuración de Privacidad**: Los permisos otorgados al agendar una cita quedan reflejados en `SettingsView`, permitiendo al usuario revocar o modificar sus datos compartidos en cualquier instante sin necesidad de agendar una nueva consulta.
4. **Integración Nativa de Contacto**: Se emplearon los esquemas URL nativos de iOS `tel://` y `https://wa.me/` para permitir que el usuario llame o inicie un chat directo con el especialista desde su perfil.
5. **Nodo Permanente en el Cosmos**: El nodo "Planeta" habita como un cuerpo celeste fijo en la capa cósmica de `GalaxyCanvasView`, integrándose orgánicamente en la navegación espacial.
6. **Conformidad `Hashable` para NavigationDestination**: En SwiftUI para iOS 16/17+, el modificador `.navigationDestination(item:destination:)` exige que el modelo de datos conforme `Hashable` además de `Identifiable` para indexar de forma única la ruta en el `NavigationStack`. `Psychologist` y `TimeSlot` conforman `Hashable` de manera nativa sin sobrecarga.
