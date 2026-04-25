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

            GeometryReader { geometry in
                let baseSize = max(geometry.size.width, geometry.size.height)
                let centers = OnboardingAnimatedGradientMotion.centers(
                    phase: phase,
                    reduceMotion: self.reduceMotion)

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

                    OnboardingAnimatedGradientBlob(
                        color: self.primary,
                        opacity: 0.34,
                        center: centers[0],
                        diameter: baseSize * 1.25,
                        aspectRatio: 0.86,
                        containerSize: geometry.size)

                    OnboardingAnimatedGradientBlob(
                        color: self.secondary,
                        opacity: 0.30,
                        center: centers[1],
                        diameter: baseSize * 1.35,
                        aspectRatio: 0.78,
                        containerSize: geometry.size)

                    OnboardingAnimatedGradientBlob(
                        color: self.accent,
                        opacity: 0.32,
                        center: centers[2],
                        diameter: baseSize * 1.20,
                        aspectRatio: 0.90,
                        containerSize: geometry.size)

                    OnboardingAnimatedGradientBlob(
                        color: self.primary,
                        opacity: 0.20,
                        center: centers[3],
                        diameter: baseSize * 1.45,
                        aspectRatio: 0.72,
                        containerSize: geometry.size)

                    LinearGradient(
                        colors: [
                            Tokens.background.opacity(0.08),
                            Tokens.background.opacity(0.22),
                        ],
                        startPoint: .top,
                        endPoint: .bottom)
                }
            }
        }
    }
}

private struct OnboardingAnimatedGradientBlob: View {
    let color: Color
    let opacity: Double
    let center: CGPoint
    let diameter: CGFloat
    let aspectRatio: CGFloat
    let containerSize: CGSize

    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        self.color.opacity(self.opacity),
                        self.color.opacity(self.opacity * 0.36),
                        self.color.opacity(0),
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: self.diameter * 0.56))
            .frame(width: self.diameter, height: self.diameter * self.aspectRatio)
            .position(
                x: self.center.x * self.containerSize.width,
                y: self.center.y * self.containerSize.height)
            .blur(radius: self.diameter * 0.08)
            .allowsHitTesting(false)
    }
}

enum OnboardingAnimatedGradientMotion {
    static func centers(phase: Double, reduceMotion: Bool) -> [CGPoint] {
        let phase = reduceMotion ? 0 : phase
        let baseAngle = phase * .pi * 2
        let slowAngle = (phase * 0.63 * .pi * 2) + 1.4
        let fastAngle = (phase * 1.21 * .pi * 2) + 2.1

        return [
            self.point(0.22 + (0.14 * sin(baseAngle)), 0.16 + (0.10 * cos(slowAngle))),
            self.point(0.78 + (0.12 * cos(slowAngle)), 0.24 + (0.12 * sin(fastAngle))),
            self.point(0.28 + (0.10 * sin(fastAngle)), 0.76 + (0.12 * cos(baseAngle))),
            self.point(0.76 + (0.12 * cos(baseAngle)), 0.72 + (0.12 * sin(slowAngle))),
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
