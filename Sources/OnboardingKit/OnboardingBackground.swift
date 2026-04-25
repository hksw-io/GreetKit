#if os(iOS) || os(macOS)
import Foundation
import SwiftUI

public struct OnboardingBackgroundContext {
    public let reduceMotion: Bool

    public init(reduceMotion: Bool) {
        self.reduceMotion = reduceMotion
    }
}

public struct OnboardingBackground {
    enum Storage {
        case system
        case softGradient
        case linearGradient(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint)
        case animatedMesh(primary: Color, secondary: Color, accent: Color)
        case custom((OnboardingBackgroundContext) -> AnyView)
    }

    let storage: Storage

    public static var system: Self { Self(storage: .system) }
    public static var softGradient: Self { Self(storage: .softGradient) }

    public static func linearGradient(
        colors: [Color],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing) -> Self
    {
        Self(storage: .linearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint))
    }

    public static func animatedMesh(
        primary: Color = .blue,
        secondary: Color = .purple,
        accent: Color = .mint) -> Self
    {
        Self(storage: .animatedMesh(primary: primary, secondary: secondary, accent: accent))
    }

    public static func custom<Background: View>(
        @ViewBuilder _ background: @escaping (OnboardingBackgroundContext) -> Background) -> Self
    {
        Self(storage: .custom { context in
            AnyView(background(context))
        })
    }
}

extension OnboardingBackground {
    func makeView(context: OnboardingBackgroundContext) -> AnyView {
        switch self.storage {
        case .system:
            AnyView(Tokens.background)
        case .softGradient:
            AnyView(OnboardingSoftGradientBackground())
        case let .linearGradient(colors, startPoint, endPoint):
            AnyView(OnboardingLinearGradientBackground(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint))
        case let .animatedMesh(primary, secondary, accent):
            AnyView(OnboardingAnimatedMeshBackground(
                primary: primary,
                secondary: secondary,
                accent: accent,
                reduceMotion: context.reduceMotion))
        case let .custom(background):
            background(context)
        }
    }
}

private struct OnboardingSoftGradientBackground: View {
    var body: some View {
        ZStack {
            Tokens.background

            LinearGradient(
                colors: [
                    Color.blue.opacity(0.16),
                    Color.mint.opacity(0.10),
                    Tokens.background.opacity(0.72),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)

            LinearGradient(
                colors: [
                    Tokens.background.opacity(0.05),
                    Tokens.background.opacity(0.86),
                ],
                startPoint: .top,
                endPoint: .bottom)
        }
    }
}

private struct OnboardingLinearGradientBackground: View {
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

private struct OnboardingAnimatedMeshBackground: View {
    let primary: Color
    let secondary: Color
    let accent: Color
    let reduceMotion: Bool

    private static let cycleDuration: TimeInterval = 14

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: self.reduceMotion)) { timeline in
            let phase = self.reduceMotion
                ? 0
                : timeline.date.timeIntervalSinceReferenceDate / Self.cycleDuration

            ZStack {
                Tokens.background

                LinearGradient(
                    colors: [
                        self.primary.opacity(0.18),
                        self.secondary.opacity(0.16),
                        self.accent.opacity(0.14),
                        self.primary.opacity(0.12),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)

                MeshGradient(
                    width: 3,
                    height: 3,
                    points: OnboardingAnimatedMeshGeometry.points(
                        phase: phase,
                        reduceMotion: self.reduceMotion),
                    colors: self.colors)
                    .opacity(0.86)

                LinearGradient(
                    colors: [
                        Tokens.background.opacity(0.10),
                        Tokens.background.opacity(0.24),
                    ],
                    startPoint: .top,
                    endPoint: .bottom)
            }
        }
    }

    private var colors: [Color] {
        [
            self.primary.opacity(0.34),
            self.secondary.opacity(0.28),
            self.accent.opacity(0.30),
            self.secondary.opacity(0.32),
            self.primary.opacity(0.26),
            self.accent.opacity(0.34),
            self.accent.opacity(0.28),
            self.secondary.opacity(0.30),
            self.primary.opacity(0.32),
        ]
    }
}

enum OnboardingAnimatedMeshGeometry {
    static func points(phase: Double, reduceMotion: Bool) -> [SIMD2<Float>] {
        let phase = reduceMotion ? 0 : phase
        let baseAngle = phase * .pi * 2
        let slowAngle = (phase * 0.63 * .pi * 2) + 1.4
        let fastAngle = (phase * 1.21 * .pi * 2) + 2.1

        return [
            self.point(0, 0),
            self.point(0.47 + (0.08 * sin(baseAngle)), 0.03 + (0.03 * cos(slowAngle))),
            self.point(1, 0),
            self.point(0.04 + (0.05 * cos(slowAngle)), 0.46 + (0.10 * sin(fastAngle))),
            self.point(0.50 + (0.11 * sin(slowAngle)), 0.50 + (0.10 * cos(baseAngle))),
            self.point(0.96 + (0.03 * sin(fastAngle)), 0.54 + (0.10 * cos(slowAngle))),
            self.point(0, 1),
            self.point(0.52 + (0.10 * cos(fastAngle)), 0.96 + (0.03 * sin(baseAngle))),
            self.point(1, 1),
        ]
    }

    private static func point(_ x: Double, _ y: Double) -> SIMD2<Float> {
        SIMD2(Float(min(1, max(0, x))), Float(min(1, max(0, y))))
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
