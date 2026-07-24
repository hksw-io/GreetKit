#if os(iOS) || os(macOS)
import SwiftUI
import Testing
@testable import GreetKit

@Suite("Gradient backgrounds")
struct GradientTests {
    @Test
    func backgroundContextStoresColorScheme() {
        let defaultContext = GreetBackgroundContext(reduceMotion: true)
        let darkContext = GreetBackgroundContext(
            reduceMotion: false,
            brandColor: .pink,
            colorScheme: .dark)

        #expect(defaultContext.reduceMotion)
        #expect(defaultContext.colorScheme == .light)
        #expect(!darkContext.reduceMotion)
        #expect(darkContext.colorScheme == .dark)
    }

    @Test
    func paletteReusesLightTonesWhenDarkIsOmitted() {
        let palette = GreetGradientPalette(
            light: .init(base: .white, primary: .pink, secondary: .orange, accent: .yellow))

        #expect(palette.tones(for: .light).primary == .pink)
        #expect(palette.tones(for: .dark).primary == .pink)
        #expect(palette.tones(for: .dark).base == .white)
    }

    @Test
    func paletteSelectsTonesPerColorScheme() {
        let palette = GreetGradientPalette(
            light: .init(base: .white, primary: .pink, secondary: .orange, accent: .yellow),
            dark: .init(base: .black, primary: .purple, secondary: .blue, accent: .mint))

        #expect(palette.tones(for: .light).primary == .pink)
        #expect(palette.tones(for: .light).base == .white)
        #expect(palette.tones(for: .dark).primary == .purple)
        #expect(palette.tones(for: .dark).base == .black)
    }

    @Test
    func brandPaletteCarriesTheBrandColorIntoBothSchemes() {
        let palette = GreetGradientPalette.brand(.indigo)

        #expect(palette.tones(for: .light).primary == .indigo)
        #expect(palette.tones(for: .dark).primary == .indigo)
    }

    @Test
    func standardPaletteUsesTheDefaultBrandColor() {
        #expect(GreetGradientPalette.standard.tones(for: .light).primary == .blue)
    }

    @Test
    func gradientColorNormalizerPadsEmptyInput() {
        let colors = GradientColorNormalizer.colors([])

        #expect(colors.count == 2)
        #expect(colors[0] == Tokens.background)
        #expect(colors[1] == Tokens.background)
    }

    @Test
    func gradientColorNormalizerDuplicatesASingleColor() {
        let colors = GradientColorNormalizer.colors([.teal])

        #expect(colors == [.teal, .teal])
    }

    @Test
    func gradientColorNormalizerPassesThroughTwoOrMoreColors() {
        let input: [Color] = [.red, .green, .blue]

        #expect(GradientColorNormalizer.colors(input) == input)
    }

    @Test
    func motionStrengthClampsToTheSupportedRange() {
        #expect(GreetGradientMotion(strength: -1).clampedStrength == 0)
        #expect(GreetGradientMotion(strength: 5).clampedStrength == 2)
        #expect(GreetGradientMotion(strength: 1.2).clampedStrength == 1.2)
    }

    @Test
    func motionPresetsAreOrderedFromSubtleToExpressive() {
        #expect(GreetGradientMotion.subtle.strength < GreetGradientMotion.standard.strength)
        #expect(GreetGradientMotion.standard.strength < GreetGradientMotion.expressive.strength)
    }

    @Test
    func animatedGradientCentersAreStableWithReduceMotion() {
        let first = GreetAnimatedGradientMotion.centers(
            phase: 0,
            reduceMotion: true,
            motion: .expressive)
        let second = GreetAnimatedGradientMotion.centers(
            phase: 0.5,
            reduceMotion: true,
            motion: .expressive)

        #expect(first[0].x == second[0].x)
        #expect(first[0].y == second[0].y)
    }

    @Test
    func animatedGradientCentersChangeAcrossPhases() {
        let first = GreetAnimatedGradientMotion.centers(phase: 0, reduceMotion: false)
        let second = GreetAnimatedGradientMotion.centers(phase: 0.25, reduceMotion: false)

        #expect(abs(first[0].x - second[0].x) > 0.0001)
    }

    @Test
    func animatedGradientCentersStayInsideTheCanvas() {
        for phase in stride(from: 0.0, through: 1.0, by: 0.1) {
            let centers = GreetAnimatedGradientMotion.centers(
                phase: phase,
                reduceMotion: false,
                motion: GreetGradientMotion(strength: 2))

            #expect(centers.count == 4)
            #expect(centers.allSatisfy { $0.x >= 0 && $0.x <= 1 && $0.y >= 0 && $0.y <= 1 })
        }
    }

    @Test
    func expressiveAnimatedGradientMotionTravelsFartherThanSubtleMotion() {
        let subtleStart = GreetAnimatedGradientMotion.centers(
            phase: 0,
            reduceMotion: false,
            motion: .subtle)
        let subtleEnd = GreetAnimatedGradientMotion.centers(
            phase: 0.25,
            reduceMotion: false,
            motion: .subtle)
        let expressiveStart = GreetAnimatedGradientMotion.centers(
            phase: 0,
            reduceMotion: false,
            motion: .expressive)
        let expressiveEnd = GreetAnimatedGradientMotion.centers(
            phase: 0.25,
            reduceMotion: false,
            motion: .expressive)

        #expect(self.totalTravel(from: expressiveStart, to: expressiveEnd) > self.totalTravel(from: subtleStart, to: subtleEnd))
    }

    @Test
    func expressiveAnimatedGradientMotionHasHigherVisualContrastThanSubtleMotion() {
        #expect(GreetGradientMotion.expressive.baseTintScale > GreetGradientMotion.subtle.baseTintScale)
        #expect(GreetGradientMotion.expressive.blobOpacityScale > GreetGradientMotion.subtle.blobOpacityScale)
        #expect(GreetGradientMotion.expressive.blobBlurScale < GreetGradientMotion.subtle.blobBlurScale)
    }

    private func totalTravel(from first: [CGPoint], to second: [CGPoint]) -> Double {
        zip(first, second).reduce(0) { total, pair in
            let xDistance = Double(pair.0.x - pair.1.x)
            let yDistance = Double(pair.0.y - pair.1.y)
            return total + ((xDistance * xDistance) + (yDistance * yDistance)).squareRoot()
        }
    }
}
#endif
