//
//  GalaxyCanvasView.swift
//  Memento_App
//
//  Created by Senior iOS UI/UX Engineer on 15/10/2026.
//

import SwiftUI

/// Lienzo espacial interactivo de alto rendimiento para la visualización del universo interno del usuario.
/// Construido estrictamente con el Design System oficial (Color+Memento).
/// Soporta gestos combinados de Pan y Zoom, curvas de Bézier entre nodos,
/// y alberga al Gatito Espacial flotando de manera inmersiva dentro del grafo cósmico.
public struct GalaxyCanvasView: View {
    public let nodes: [StarNode]
    public let links: [ConstellationLink]
    public let onSelectNode: (StarNode) -> Void
    public var onSelectPlanet: (() -> Void)? = nil
    public var onSelectCat: (() -> Void)? = nil

    // Estados de gestos y navegación por el cosmos
    @State private var currentScale: CGFloat = 1.0
    @State private var gestureScale: CGFloat = 1.0
    @State private var currentPanOffset: CGSize = .zero
    @State private var gesturePanOffset: CGSize = .zero

    // Animación de centelleo de estrellas de fondo
    @State private var twinklePhase: Double = 0.0

    public init(
        nodes: [StarNode],
        links: [ConstellationLink],
        onSelectNode: @escaping (StarNode) -> Void,
        onSelectPlanet: (() -> Void)? = nil,
        onSelectCat: (() -> Void)? = nil
    ) {
        self.nodes = nodes
        self.links = links
        self.onSelectNode = onSelectNode
        self.onSelectPlanet = onSelectPlanet
        self.onSelectCat = onSelectCat
    }
    
    private var totalScale: CGFloat {
        max(0.5, min(3.0, currentScale * gestureScale))
    }
    
    private var totalOffset: CGSize {
        CGSize(
            width: currentPanOffset.width + gesturePanOffset.width,
            height: currentPanOffset.height + gesturePanOffset.height
        )
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            
            ZStack {
                // Fondo cósmico en acuarela estricto con paleta oficial
                GalaxyWatercolorBackground(twinklePhase: twinklePhase)
                
                // Capa del Universo Estelar (escalada y desplazada por gestos)
                ZStack {
                    // 1. Líneas de constelación (Bézier orgánicas)
                    Canvas { context, _ in
                        for link in links {
                            var path = Path()
                            path.move(to: link.startPoint)
                            
                            let midX = (link.startPoint.x + link.endPoint.x) / 2.0
                            let midY = (link.startPoint.y + link.endPoint.y) / 2.0
                            let dx = link.endPoint.x - link.startPoint.x
                            let dy = link.endPoint.y - link.startPoint.y
                            let normalOffset: CGFloat = link.linkType == .moon ? 18 : 8
                            let controlPoint = CGPoint(x: midX - (dy * 0.08) + normalOffset, y: midY + (dx * 0.08))
                            
                            path.addQuadCurve(to: link.endPoint, control: controlPoint)
                            
                            // Halo exterior tenue en mementoSoftBlue / mementoGold
                            let glowColor = (link.linkType == .moon ? Color.mementoGold : Color.mementoSoftBlue).opacity(0.35)
                            let glowStroke = StrokeStyle(
                                lineWidth: link.linkType == .moon ? 3.5 : 1.8,
                                lineCap: .round
                            )
                            context.stroke(path, with: .color(glowColor), style: glowStroke)
                            
                            // Línea de luz interior en mementoWhite
                            let innerStroke = StrokeStyle(
                                lineWidth: link.linkType == .moon ? 1.5 : 0.9,
                                lineCap: .round,
                                dash: link.linkType == .mini ? [4, 4] : []
                            )
                            context.stroke(
                                path,
                                with: .color(Color.mementoWhite.opacity(0.85)),
                                style: innerStroke
                            )
                        }
                    }
                    
                    // 2. Nodos celestes interactivos
                    ForEach(nodes) { node in
                        StarNodeView(node: node) {
                            onSelectNode(node)
                        }
                        .position(node.point)
                    }
                    
                    // 3. Nodo Celestial Permanente: Planeta de Ayuda y Salud Mental
                    PlanetNodeView(size: 64) {
                        onSelectPlanet?()
                    }
                    .position(x: -150, y: -165)

                    // 4. Nodo Celestial Permanente: Gatito Espacial, compañero y acceso a tus insights
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onSelectCat?()
                    }) {
                        SpaceCatView(size: 60)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .position(x: 150, y: -165)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .offset(x: center.x + totalOffset.width, y: center.y + totalOffset.height)
                .scaleEffect(totalScale)
            }
            .contentShape(Rectangle())
            .gesture(panGesture)
            .simultaneousGesture(magnificationGesture)
            .onAppear {
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    twinklePhase = 1.0
                }
            }
        }
    }
    
    // MARK: - Gestos de Navegación
    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                gesturePanOffset = value.translation
            }
            .onEnded { value in
                currentPanOffset.width += value.translation.width
                currentPanOffset.height += value.translation.height
                gesturePanOffset = .zero
            }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                gestureScale = value
            }
            .onEnded { value in
                currentScale = max(0.5, min(3.0, currentScale * value))
                gestureScale = 1.0
            }
    }
}

// MARK: - Subvista de Nodo Estelar
private struct StarNodeView: View {
    let node: StarNode
    let onTap: () -> Void
    
    @State private var isPulsing = false
    
    private var nodePrimaryColor: Color {
        node.starType == .moon ? Color.mementoGold : node.accentColor
    }
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onTap()
        }) {
            ZStack {
                // Halo de irradiación cósmica
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                nodePrimaryColor.opacity(node.starType == .moon ? 0.65 : 0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: node.starType.glowRadius
                        )
                    )
                    .frame(width: node.starType.glowRadius * 2, height: node.starType.glowRadius * 2)
                    .scaleEffect(isPulsing ? 1.15 : 0.92)
                
                // Si es Luna, incorpora aro estelar exterior punteado en mementoGold
                if node.starType == .moon {
                    Circle()
                        .strokeBorder(
                            Color.mementoGold.opacity(0.5),
                            style: StrokeStyle(lineWidth: 1.2, dash: [4, 4])
                        )
                        .frame(width: node.starType.visualRadius * 2.3, height: node.starType.visualRadius * 2.3)
                        .rotationEffect(.degrees(isPulsing ? 360 : 0))
                }
                
                // Cuerpo de la estrella
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.mementoWhite,
                                nodePrimaryColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: node.starType.visualRadius, height: node.starType.visualRadius)
                    .shadow(color: nodePrimaryColor, radius: 8)
                
                // Destello central en blanco puro
                Circle()
                    .fill(Color.mementoWhite)
                    .frame(width: node.starType.visualRadius * 0.4, height: node.starType.visualRadius * 0.4)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            let duration: Double = node.starType == .moon ? 3.0 : (node.starType == .medium ? 2.2 : 1.5)
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Fondo Cósmico en Acuarela
/// Fondo de acuarela cósmica construido exclusivamente con la paleta estricta oficial:
/// `mementoDarkPurple`, `mementoDeepViolet`, `mementoNavyBlue`, `mementoSkyBlue`, `mementoSoftBlue`, `mementoWhite`.
public struct GalaxyWatercolorBackground: View {
    public var twinklePhase: Double
    
    public init(twinklePhase: Double = 0.0) {
        self.twinklePhase = twinklePhase
    }
    
    public var body: some View {
        ZStack {
            // Capa 1: Base oscura nocturna
            Color.mementoDarkPurple
            
            // Capa 2: Mancha acuarela violeta superior
            RadialGradient(
                colors: [
                    Color.mementoDeepViolet.opacity(0.85),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 40,
                endRadius: 520
            )
            
            // Capa 3: Mancha acuarela azul marino inferior
            RadialGradient(
                colors: [
                    Color.mementoNavyBlue.opacity(0.80),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 60,
                endRadius: 580
            )
            
            // Capa 4: Nebulosa central azul cielo diáfano
            RadialGradient(
                colors: [
                    Color.mementoSkyBlue.opacity(0.40),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 360
            )
            
            // Capa 5: Polvo estelar de fondo en mementoWhite y mementoSoftBlue
            Canvas { context, size in
                for i in 0..<75 {
                    let seedX = Double((i * 137) % Int(size.width > 0 ? size.width : 400))
                    let seedY = Double((i * 269) % Int(size.height > 0 ? size.height : 800))
                    let opacity = 0.2 + (0.6 * ((Double(i % 10) / 10.0) * (0.8 + 0.4 * twinklePhase)))
                    let starRect = CGRect(x: seedX, y: seedY, width: (i % 5 == 0) ? 2.2 : 1.2, height: (i % 5 == 0) ? 2.2 : 1.2)
                    let starColor = (i % 3 == 0) ? Color.mementoSoftBlue : Color.mementoWhite
                    context.fill(Path(ellipseIn: starRect), with: .color(starColor.opacity(opacity)))
                }
            }
        }
    }
}
