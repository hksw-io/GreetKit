#if os(iOS) || os(macOS)
import Foundation
import SwiftUI

public struct GreetBackgroundContext {
    public let reduceMotion: Bool
    public let brandColor: Color?
    public let colorScheme: ColorScheme

    public init(
        reduceMotion: Bool,
        brandColor: Color? = nil,
        colorScheme: ColorScheme = .light)
    {
        self.reduceMotion = reduceMotion
        self.brandColor = brandColor
        self.colorScheme = colorScheme
    }
}

public struct GreetGradientPalette {
    public struct Tones {
        public var base: Color
        public var primary: Color
        public var secondary: Color
        public var accent: Color

        public init(base: Color, primary: Color, secondary: Color, accent: Color) {
            self.base = base
            self.primary = primary
            self.secondary = secondary
            self.accent = accent
        }
    }

    public var light: Tones
    public var dark: Tones

    public static var standard: Self {
        self.brand(.blue)
    }

    public init(light: Tones, dark: Tones? = nil) {
        self.light = light
        self.dark = dark ?? light
    }

    public static func brand(_ brand: Color) -> Self {
        Self(
            light: Tones(
                base: Tokens.background,
                primary: brand,
                secondary: .cyan,
                accent: .mint),
            dark: Tones(
                base: Tokens.background,
                primary: brand,
                secondary: .purple,
                accent: .cyan))
    }

    func tones(for colorScheme: ColorScheme) -> Tones {
        colorScheme == .dark ? self.dark : self.light
    }
}

public struct GreetGradientMotion: Equatable, Sendable {
    public var strength: Double

    public static let subtle = Self(strength: 0.7)
    public static let standard = Self(strength: 1.2)
    public static let expressive = Self(strength: 1.6)

    public init(strength: Double = 1.2) {
        self.strength = strength
    }

    var clampedStrength: Double {
        min(2, max(0, self.strength))
    }

    var speedScale: Double {
        max(0.35, 0.65 + (self.clampedStrength * 0.35))
    }

    var travelScale: Double {
        self.clampedStrength
    }

    var baseTintScale: Double {
        0.84 + (self.clampedStrength * 0.16)
    }

    var blobOpacityScale: Double {
        0.78 + (self.clampedStrength * 0.25)
    }

    var blobBlurScale: Double {
        max(0.90, 1.08 - (self.clampedStrength * 0.09))
    }
}

public struct GreetBackground {
    enum Storage {
        case system
        case softGradient(brand: Color?, palette: GreetGradientPalette?)
        case linearGradient(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint)
        case animatedGradient(brand: Color?, palette: GreetGradientPalette?, motion: GreetGradientMotion)
        case custom((GreetBackgroundContext) -> AnyView)
    }

    let storage: Storage

    public static var system: Self { Self(storage: .system) }
    public static var softGradient: Self { Self(storage: .softGradient(brand: nil, palette: nil)) }

    public static func softGradient(
        brand: Color? = nil,
        palette: GreetGradientPalette? = nil) -> Self
    {
        Self(storage: .softGradient(brand: brand, palette: palette))
    }

    public static func linearGradient(
        colors: [Color],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing) -> Self
    {
        Self(storage: .linearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint))
    }

    public static func animatedGradient(
        brand: Color? = nil,
        palette: GreetGradientPalette? = nil,
        motion: GreetGradientMotion = .standard) -> Self
    {
        Self(storage: .animatedGradient(brand: brand, palette: palette, motion: motion))
    }

    @available(*, deprecated, message: "Use animatedGradient(brand:palette:motion:) instead.")
    public static func animatedMesh(
        primary: Color = .blue,
        secondary: Color = .purple,
        accent: Color = .mint) -> Self
    {
        self.animatedGradient(
            palette: GreetGradientPalette(
                light: .init(
                    base: Tokens.background,
                    primary: primary,
                    secondary: secondary,
                    accent: accent)),
            motion: .standard)
    }

    public static func custom<Background: View>(
        @ViewBuilder _ background: @escaping (GreetBackgroundContext) -> Background) -> Self
    {
        Self(storage: .custom { context in
            AnyView(background(context))
        })
    }
}

extension GreetBackground {
    @MainActor
    func makeView(context: GreetBackgroundContext) -> AnyView {
        switch self.storage {
        case .system:
            AnyView(Tokens.background)
        case let .softGradient(brand, palette):
            AnyView(GreetSoftGradientBackground(
                tones: GreetGradientPaletteResolver.tones(
                    brand: brand,
                    palette: palette,
                    context: context),
                colorScheme: context.colorScheme))
        case let .linearGradient(colors, startPoint, endPoint):
            AnyView(GreetLinearGradientBackground(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint))
        case let .animatedGradient(brand, palette, motion):
            AnyView(GreetAnimatedGradientBackground(
                tones: GreetGradientPaletteResolver.tones(
                    brand: brand,
                    palette: palette,
                    context: context),
                colorScheme: context.colorScheme,
                motion: motion,
                reduceMotion: context.reduceMotion))
        case let .custom(background):
            background(context)
        }
    }
}

private struct GreetSoftGradientBackground: View {
    let tones: GreetGradientPalette.Tones
    let colorScheme: ColorScheme

    var body: some View {
        let tuning = GreetGradientVisualTuning.soft(colorScheme: self.colorScheme)

        ZStack {
            self.tones.base

            LinearGradient(
                colors: [
                    self.tones.primary.opacity(tuning.baseTintOpacity),
                    self.tones.secondary.opacity(tuning.baseTintOpacity * 0.7),
                    self.tones.accent.opacity(tuning.baseTintOpacity * 0.6),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)

            LinearGradient(
                colors: [
                    self.tones.primary.opacity(tuning.primaryOpacity),
                    self.tones.secondary.opacity(tuning.secondaryOpacity),
                    self.tones.accent.opacity(tuning.accentOpacity),
                    self.tones.base.opacity(tuning.baseFadeOpacity),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)

            LinearGradient(
                colors: [
                    self.tones.base.opacity(tuning.topVeilOpacity),
                    self.tones.base.opacity(tuning.bottomVeilOpacity),
                ],
                startPoint: .top,
                endPoint: .bottom)
        }
    }
}

private struct GreetLinearGradientBackground: View {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint

    var body: some View {
        LinearGradient(
            colors: GradientColorNormalizer.colors(self.colors),
            startPoint: self.startPoint,
            endPoint: self.endPoint)
    }
}

private struct GreetAnimatedGradientBackground: View {
    let tones: GreetGradientPalette.Tones
    let colorScheme: ColorScheme
    let motion: GreetGradientMotion
    let reduceMotion: Bool

    private static let baseCycleDuration: TimeInterval = 10

    var body: some View {
        let isPaused = self.reduceMotion || self.motion.clampedStrength == 0

        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: isPaused)) { timeline in
            let phase = isPaused
                ? 0
                : timeline.date.timeIntervalSinceReferenceDate / (Self.baseCycleDuration / self.motion.speedScale)

            GeometryReader { geometry in
                let centers = GreetAnimatedGradientMotion.centers(
                    phase: phase,
                    reduceMotion: self.reduceMotion,
                    motion: self.motion)
                let tuning = GreetGradientVisualTuning
                    .animated(colorScheme: self.colorScheme)
                    .scaled(for: self.motion)

                Canvas(
                    opaque: true,
                    colorMode: .extendedLinear,
                    rendersAsynchronously: true)
                { context, size in
                    GreetAnimatedGradientRenderer.draw(
                        context: &context,
                        size: size,
                        tones: self.tones,
                        tuning: tuning,
                        centers: centers)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

private enum GreetAnimatedGradientRenderer {
    static func draw(
        context: inout GraphicsContext,
        size: CGSize,
        tones: GreetGradientPalette.Tones,
        tuning: GreetAnimatedGradientTuning,
        centers: [CGPoint])
    {
        let rect = CGRect(origin: .zero, size: size)
        let baseSize = max(size.width, size.height)

        context.fill(Path(rect), with: .color(tones.base))

        context.fill(
            Path(rect),
            with: .linearGradient(
                Gradient(colors: [
                    tones.primary.opacity(tuning.baseTintOpacity),
                    tones.secondary.opacity(tuning.baseTintOpacity * 0.76),
                    tones.accent.opacity(tuning.baseTintOpacity * 0.68),
                    tones.primary.opacity(tuning.baseTintOpacity * 0.58),
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: size.height)))

        var blobContext = context
        blobContext.addFilter(.blur(radius: baseSize * tuning.blobBlurRatio))
        blobContext.drawLayer { layer in
            self.drawBlob(
                context: &layer,
                canvasRect: rect,
                size: size,
                color: tones.primary,
                opacity: tuning.primaryBlobOpacity,
                center: centers[0],
                radius: baseSize * 0.92)
            self.drawBlob(
                context: &layer,
                canvasRect: rect,
                size: size,
                color: tones.secondary,
                opacity: tuning.secondaryBlobOpacity,
                center: centers[1],
                radius: baseSize * 1.00)
            self.drawBlob(
                context: &layer,
                canvasRect: rect,
                size: size,
                color: tones.accent,
                opacity: tuning.accentBlobOpacity,
                center: centers[2],
                radius: baseSize * 0.88)
            self.drawBlob(
                context: &layer,
                canvasRect: rect,
                size: size,
                color: tones.primary,
                opacity: tuning.trailingBlobOpacity,
                center: centers[3],
                radius: baseSize * 1.08)
        }

        context.fill(
            Path(rect),
            with: .linearGradient(
                Gradient(colors: [
                    tones.base.opacity(tuning.topVeilOpacity),
                    tones.base.opacity(tuning.bottomVeilOpacity),
                ]),
                startPoint: CGPoint(x: size.width * 0.5, y: 0),
                endPoint: CGPoint(x: size.width * 0.5, y: size.height)))
    }

    private static func drawBlob(
        context: inout GraphicsContext,
        canvasRect: CGRect,
        size: CGSize,
        color: Color,
        opacity: Double,
        center: CGPoint,
        radius: CGFloat)
    {
        let centerPoint = CGPoint(x: center.x * size.width, y: center.y * size.height)

        context.fill(
            Path(canvasRect),
            with: .radialGradient(
                Gradient(colors: [
                    color.opacity(opacity),
                    color.opacity(opacity * 0.42),
                    color.opacity(opacity * 0.12),
                    color.opacity(opacity * 0.08),
                ]),
                center: centerPoint,
                startRadius: 0,
                endRadius: radius))
    }
}

private enum GreetGradientPaletteResolver {
    static func tones(
        brand: Color?,
        palette: GreetGradientPalette?,
        context: GreetBackgroundContext) -> GreetGradientPalette.Tones
    {
        let resolvedPalette = palette ?? .brand(brand ?? context.brandColor ?? .blue)
        return resolvedPalette.tones(for: context.colorScheme)
    }
}

private struct GreetSoftGradientTuning {
    let baseTintOpacity: Double
    let primaryOpacity: Double
    let secondaryOpacity: Double
    let accentOpacity: Double
    let baseFadeOpacity: Double
    let topVeilOpacity: Double
    let bottomVeilOpacity: Double
}

private struct GreetAnimatedGradientTuning {
    let baseTintOpacity: Double
    let primaryBlobOpacity: Double
    let secondaryBlobOpacity: Double
    let accentBlobOpacity: Double
    let trailingBlobOpacity: Double
    let topVeilOpacity: Double
    let bottomVeilOpacity: Double
    let blobBlurRatio: CGFloat

    func scaled(for motion: GreetGradientMotion) -> Self {
        Self(
            baseTintOpacity: min(0.72, self.baseTintOpacity * motion.baseTintScale),
            primaryBlobOpacity: min(0.78, self.primaryBlobOpacity * motion.blobOpacityScale),
            secondaryBlobOpacity: min(0.76, self.secondaryBlobOpacity * motion.blobOpacityScale),
            accentBlobOpacity: min(0.76, self.accentBlobOpacity * motion.blobOpacityScale),
            trailingBlobOpacity: min(0.70, self.trailingBlobOpacity * motion.blobOpacityScale),
            topVeilOpacity: self.topVeilOpacity,
            bottomVeilOpacity: self.bottomVeilOpacity,
            blobBlurRatio: self.blobBlurRatio * motion.blobBlurScale)
    }
}

private enum GreetGradientVisualTuning {
    static func soft(colorScheme: ColorScheme) -> GreetSoftGradientTuning {
        if colorScheme == .dark {
            return GreetSoftGradientTuning(
                baseTintOpacity: 0.20,
                primaryOpacity: 0.24,
                secondaryOpacity: 0.18,
                accentOpacity: 0.16,
                baseFadeOpacity: 0.54,
                topVeilOpacity: 0.08,
                bottomVeilOpacity: 0.42)
        }

        return GreetSoftGradientTuning(
            baseTintOpacity: 0.12,
            primaryOpacity: 0.18,
            secondaryOpacity: 0.12,
            accentOpacity: 0.10,
            baseFadeOpacity: 0.62,
            topVeilOpacity: 0.04,
            bottomVeilOpacity: 0.78)
    }

    static func animated(colorScheme: ColorScheme) -> GreetAnimatedGradientTuning {
        if colorScheme == .dark {
            return GreetAnimatedGradientTuning(
                baseTintOpacity: 0.26,
                primaryBlobOpacity: 0.46,
                secondaryBlobOpacity: 0.40,
                accentBlobOpacity: 0.38,
                trailingBlobOpacity: 0.28,
                topVeilOpacity: 0.04,
                bottomVeilOpacity: 0.18,
                blobBlurRatio: 0.028)
        }

        return GreetAnimatedGradientTuning(
            baseTintOpacity: 0.38,
            primaryBlobOpacity: 0.46,
            secondaryBlobOpacity: 0.42,
            accentBlobOpacity: 0.42,
            trailingBlobOpacity: 0.32,
            topVeilOpacity: 0,
            bottomVeilOpacity: 0.04,
            blobBlurRatio: 0.028)
    }
}

enum GreetAnimatedGradientMotion {
    static func centers(
        phase: Double,
        reduceMotion: Bool,
        motion: GreetGradientMotion = .standard) -> [CGPoint]
    {
        let phase = reduceMotion ? 0 : phase
        let travelScale = reduceMotion ? 0 : motion.travelScale
        let baseAngle = phase * .pi * 2
        let slowAngle = (phase * 0.63 * .pi * 2) + 1.4
        let fastAngle = (phase * 1.21 * .pi * 2) + 2.1

        return [
            self.point(0.30 + (0.18 * travelScale * sin(baseAngle)), 0.22 + (0.14 * travelScale * cos(slowAngle))),
            self.point(0.70 + (0.18 * travelScale * cos(slowAngle)), 0.28 + (0.16 * travelScale * sin(fastAngle))),
            self.point(0.30 + (0.16 * travelScale * sin(fastAngle)), 0.72 + (0.18 * travelScale * cos(baseAngle))),
            self.point(0.70 + (0.18 * travelScale * cos(baseAngle)), 0.68 + (0.16 * travelScale * sin(slowAngle))),
        ]
    }

    private static func point(_ x: Double, _ y: Double) -> CGPoint {
        CGPoint(x: min(1, max(0, x)), y: min(1, max(0, y)))
    }
}

enum GradientColorNormalizer {
    static func colors(_ colors: [Color]) -> [Color] {
        switch colors.count {
        case 0:
            [Tokens.background, Tokens.background]
        case 1:
            [colors[0], colors[0]]
        default:
            colors
        }
    }
}
#endif
