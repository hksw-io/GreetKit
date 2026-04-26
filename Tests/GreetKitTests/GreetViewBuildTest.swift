#if os(iOS) || os(macOS)
import SwiftUI
import Testing
@testable import GreetKit

@MainActor
struct GreetViewBuildTest {
    @Test
    func viewConstructsWithMinimalContent() {
        struct MinimalContent: GreetContent {
            var title: Text { Text("Welcome") }
            var features: [GreetFeatureItem] {
                [GreetFeatureItem(id: "one", description: Text("One."))]
            }
            var primaryButtonText: Text { Text("Go") }
            var errorAlertTitle: Text { Text("Error") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: MinimalContent(),
            isLoading: .constant(false),
            errorMessage: .constant(nil),
            onPrimary: {},
            onSkip: {})
    }

    @Test
    func viewConstructsWithAllOptionalFields() {
        struct RichContent: GreetContent {
            var appIcon: Image? { Image(systemName: "app.gift.fill") }
            var title: Text { Text("Welcome") }
            var subtitle: Text? { Text("Subtitle line.") }
            var features: [GreetFeatureItem] {
                [
                    GreetFeatureItem(
                        id: "label",
                        image: Image(systemName: "star"),
                        label: Text("Label"),
                        description: Text("Description.")),
                ]
            }
            var primaryButtonText: Text { Text("Get started") }
            var skipButtonText: Text? { Text("Skip") }
            var errorAlertTitle: Text { Text("Something went wrong") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: RichContent(),
            isLoading: .constant(true),
            errorMessage: .constant("Network offline"),
            onPrimary: {},
            onSkip: {})
    }

    @Test
    func viewConstructsWithConvenienceFeatureInitializer() {
        struct ConvenienceContent: GreetContent {
            var title: Text { Text("Convenience") }
            var features: [GreetFeatureItem] {
                [
                    GreetFeatureItem(
                        id: "localized-label",
                        systemImage: "sparkles",
                        label: "Localized label",
                        description: "Localized description."),
                ]
            }
            var primaryButtonText: Text { Text("Go") }
            var errorAlertTitle: Text { Text("Error") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: ConvenienceContent(),
            isLoading: .constant(false),
            errorMessage: .constant(nil),
            onPrimary: {},
            onSkip: {})
    }

    @Test
    func featureInitializerStoresStableID() {
        let feature = GreetFeatureItem(
            id: "stable-feature",
            label: Text("Stable feature"),
            description: Text("A feature with stable identity."))

        #expect(feature.id == "stable-feature")
    }

    @Test
    func revealDelayStartsWithBaseDelay() {
        #expect(Tokens.Motion.revealDelay(for: 0) == Tokens.Motion.featureBaseDelay)
    }

    @Test
    func revealDelayCapsLongLists() {
        let expectedDelay = Tokens.Motion.featureBaseDelay + Tokens.Motion.maxFeatureStaggerDelay
        let actualDelay = Tokens.Motion.revealDelay(for: 100)

        #expect(abs(actualDelay - expectedDelay) < 0.0001)
    }

    @Test
    func viewConstructsWithSystemBackgroundModifier() {
        _ = self.backgroundView(.system)
    }

    @Test
    func viewConstructsWithSoftGradientBackground() {
        _ = self.backgroundView(.softGradient)
    }

    @Test
    func viewConstructsWithBrandSoftGradientBackground() {
        _ = self.backgroundView(.softGradient(brand: .orange))
    }

    @Test
    func viewConstructsWithLinearGradientBackground() {
        _ = self.backgroundView(.linearGradient(
            colors: [.blue.opacity(0.18), .mint.opacity(0.12), .clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing))
    }

    @Test
    func viewConstructsWithAnimatedGradientBackground() {
        _ = self.backgroundView(.animatedGradient())
    }

    @Test
    func viewConstructsWithExpressiveAnimatedGradientBackground() {
        _ = self.backgroundView(.animatedGradient(motion: .expressive))
    }

    @Test
    func viewConstructsWithGradientPaletteOverride() {
        let palette = GreetGradientPalette(
            light: .init(
                base: .white,
                primary: .pink,
                secondary: .orange,
                accent: .yellow),
            dark: .init(
                base: .black,
                primary: .purple,
                secondary: .blue,
                accent: .mint))

        _ = self.backgroundView(.animatedGradient(palette: palette))
    }

    @Test
    func viewConstructsWithCustomBackground() {
        _ = self.backgroundView(.custom { context in
            LinearGradient(
                colors: [
                    Color.blue.opacity(context.reduceMotion ? 0.10 : 0.18),
                    context.colorScheme == .dark ? .purple.opacity(0.24) : .purple.opacity(0.12),
                ],
                startPoint: .top,
                endPoint: .bottom)
        })
    }

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
    func footerMaskHeightQuantizesToWholePoints() {
        #expect(FooterMaskMetrics.quantizedHeight(123.4) == 123)
        #expect(FooterMaskMetrics.quantizedHeight(123.5) == 124)
    }

    @Test
    func footerMaskFrameQuantizesPositionAndHeight() {
        let frame = FooterMaskMetrics.quantizedFrame(CGRect(x: 0, y: 612.4, width: 390, height: 127.5))

        #expect(frame.minY == 612)
        #expect(frame.height == 128)
    }

    @Test
    func footerMaskFadeHeightCapsToAvoidEarlyMasking() {
        #expect(FooterMaskMetrics.resolvedFadeHeight(80) == FooterMaskMetrics.maximumFadeHeight)
    }

    @Test
    func footerMaskFadeHeightKeepsShorterValues() {
        #expect(FooterMaskMetrics.resolvedFadeHeight(18) == 18)
        #expect(FooterMaskMetrics.resolvedFadeHeight(0) == 0)
    }

    @Test
    func footerMaskFadeBottomIsHiddenWhenScrollableContentContinues() {
        #expect(FooterMaskMetrics.fadeBottomOpacity(scrollEdgeFadeOpacity: 1) == 0)
    }

    @Test
    func footerMaskFadeBottomIsVisibleAtScrollEnd() {
        #expect(FooterMaskMetrics.fadeBottomOpacity(scrollEdgeFadeOpacity: 0) == 1)
    }

    @Test
    func footerMaskLayoutUsesMeasuredFooterTop() {
        let layout = FooterMaskMetrics.layout(
            containerHeight: 740,
            footerFrame: FooterMaskFrame(minY: 612, height: 128),
            fadeHeight: FooterMaskMetrics.resolvedFadeHeight(80),
            scrollEdgeFadeOpacity: 1)

        #expect(layout.opaqueHeight == 584)
        #expect(layout.fadeHeight == 28)
        #expect(layout.clearHeight == 128)
        #expect(layout.fadeBottomOpacity == 0)
    }

    @Test
    func footerMaskLayoutStaysOpaqueBeforeFooterMeasurement() {
        let layout = FooterMaskMetrics.layout(
            containerHeight: 740,
            footerFrame: .zero,
            fadeHeight: FooterMaskMetrics.resolvedFadeHeight(80),
            scrollEdgeFadeOpacity: 1)

        #expect(layout.opaqueHeight == 740)
        #expect(layout.fadeHeight == 0)
        #expect(layout.clearHeight == 0)
        #expect(layout.fadeBottomOpacity == 1)
    }

    @Test
    func footerMaskContentBottomInsetMatchesMeasuredFooterArea() {
        let inset = FooterMaskMetrics.contentBottomInset(
            containerHeight: 740,
            footerFrame: FooterMaskFrame(minY: 612, height: 128))

        #expect(inset == 128)
    }

    @Test
    func footerMaskContentBottomInsetIsZeroBeforeFooterMeasurement() {
        let inset = FooterMaskMetrics.contentBottomInset(
            containerHeight: 740,
            footerFrame: .zero)

        #expect(inset == 0)
    }

    @Test
    func primaryButtonRadiusUsesRounderControlShape() {
        #expect(Tokens.Radius.button > Tokens.Radius.large)
    }

    @Test
    func footerControlsUseCompactVisualSpacingWithAccessibleSkipHeight() {
        #expect(Tokens.Layout.footerControlSpacing == Tokens.Spacing.medium)
        #expect(Tokens.Layout.minimumControlHeight == 44)
    }

    @Test
    func footerUsesAsymmetricPaddingToSitCloserToBottomEdge() {
        #expect(Tokens.Layout.footerBottomPadding == 0)
        #expect(Tokens.Layout.footerBottomPadding < Tokens.Layout.footerTopPadding)
    }

    @Test
    func viewConstructsWithBackgroundAndPrimaryRouteChain() {
        _ = GreetView(
            content: BackgroundRouteContent(),
            isLoading: .constant(false),
            errorMessage: .constant(nil),
            onPrimary: {},
            onSkip: {},
            onPrimaryRoutesComplete: {},
            primaryRouteDestination: { route in
                Text(route.id)
            })
            .greetBackground(.animatedGradient())
    }

    @Test
    func viewConstructsWithStandardStyleModifier() {
        _ = self.styledView()
            .greetStyle(.standard)
    }

    @Test
    func viewConstructsWithCustomStyleColors() {
        let style = GreetStyle(
            tint: .indigo,
            titleColor: .primary,
            subtitleColor: .secondary,
            featureIconColor: .mint,
            featureTitleColor: .primary,
            featureDescriptionColor: .secondary,
            primaryButtonForegroundColor: .white,
            primaryButtonProgressTint: .white,
            secondaryButtonColor: .secondary)

        _ = self.styledView()
            .greetBackground(.softGradient)
            .greetStyle(style)
    }

    @Test
    func styleProvidesCustomPrimaryButtonSurface() {
        let style = GreetStyle(tint: .indigo, primaryButtonForegroundColor: .white)

        _ = style.primaryButtonBackgroundStyle
        _ = style.primaryButtonForegroundStyle
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

    @Test
    func scrollEdgeFadeQuantizesOpacity() {
        let opacity = ScrollEdgeFade.opacity(
            contentHeight: 1_000,
            visibleMaxY: 955,
            fadeHeight: 100)

        #expect(opacity == 0.45)
    }

    @Test
    func scrollEdgeFadeIsOpaqueAtScrollEnd() {
        let opacity = ScrollEdgeFade.opacity(
            contentHeight: 1_000,
            visibleMaxY: 1_000,
            fadeHeight: 100)

        #expect(opacity == 0)
    }

    @Test
    func scrollEdgeFadeIsOpaqueWhenVisibleRectExtendsPastContentEnd() {
        let opacity = ScrollEdgeFade.opacity(
            contentHeight: 1_000,
            visibleMaxY: 1_128,
            fadeHeight: 100)

        #expect(opacity == 0)
    }

    @Test
    func layoutUsesCompactPaddingAtBreakpoint() {
        let padding = LayoutMetrics.horizontalPadding(
            for: 390,
            compact: 16,
            regular: 24,
            breakpoint: 390)

        #expect(padding == 16)
    }

    @Test
    func layoutUsesRegularPaddingAboveBreakpoint() {
        let padding = LayoutMetrics.horizontalPadding(
            for: 391,
            compact: 16,
            regular: 24,
            breakpoint: 390)

        #expect(padding == 24)
    }

    @Test
    func viewConstructsWithPrimaryDestination() {
        struct PrimaryRouteContent: GreetContent {
            var title: Text { Text("Primary") }
            var features: [GreetFeatureItem] {
                [GreetFeatureItem(id: "one-feature", description: Text("One feature."))]
            }
            var primaryButtonText: Text { Text("Continue") }
            var errorAlertTitle: Text { Text("Error") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: PrimaryRouteContent(),
            isLoading: .constant(false),
            errorMessage: .constant(nil),
            onPrimary: {},
            onSkip: {},
            primaryDestination: {
                Text("Primary route")
            })
    }

    @Test
    func viewConstructsWithPrimaryRouteChain() {
        struct PrimaryRouteChainContent: GreetContent {
            var title: Text { Text("Primary") }
            var features: [GreetFeatureItem] {
                [GreetFeatureItem(id: "one-feature", description: Text("One feature."))]
            }
            var primaryRoutes: [GreetPrimaryRoute] {
                [
                    GreetPrimaryRoute(id: "permissions"),
                    GreetPrimaryRoute(id: "sample-data"),
                    GreetPrimaryRoute(id: "notifications"),
                ]
            }
            var primaryButtonText: Text { Text("Continue") }
            var primaryRouteNextButtonText: Text { Text("Next step") }
            var primaryRouteDoneButtonText: Text { Text("Finish") }
            var errorAlertTitle: Text { Text("Error") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: PrimaryRouteChainContent(),
            isLoading: .constant(false),
            errorMessage: .constant(nil),
            onPrimary: {},
            onSkip: {},
            onPrimaryRoutesComplete: {},
            primaryRouteDestination: { route in
                Text(route.id)
            })
    }

    @Test
    func viewConstructsWithPrimaryRouteChainAndErrorMessage() {
        struct PrimaryRouteErrorContent: GreetContent {
            var title: Text { Text("Primary") }
            var features: [GreetFeatureItem] {
                [GreetFeatureItem(id: "one-feature", description: Text("One feature."))]
            }
            var primaryRoutes: [GreetPrimaryRoute] {
                [GreetPrimaryRoute(id: "permissions")]
            }
            var primaryButtonText: Text { Text("Continue") }
            var errorAlertTitle: Text { Text("Error") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: PrimaryRouteErrorContent(),
            isLoading: .constant(false),
            errorMessage: .constant("Route failed"),
            onPrimary: {},
            onSkip: {},
            primaryRouteDestination: { route in
                Text(route.id)
            })
    }

    @Test
    func viewConstructsWithBlockingDismissalPolicy() {
        struct BlockingContent: GreetContent {
            var title: Text { Text("Blocking") }
            var features: [GreetFeatureItem] {
                [GreetFeatureItem(id: "one-feature", description: Text("One feature."))]
            }
            var primaryButtonText: Text { Text("Continue") }
            var errorAlertTitle: Text { Text("Error") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: BlockingContent(),
            isLoading: .constant(false),
            errorMessage: .constant(nil),
            allowsInteractiveDismissal: false,
            onPrimary: {},
            onSkip: {})
    }

    @Test
    func primaryRouteStoresStableID() {
        let route = GreetPrimaryRoute(id: "sample-data")

        #expect(route.id == "sample-data")
    }

    @Test
    func viewConstructsWithLongLocalizedContentAndManyFeatures() {
        struct LongContent: GreetContent {
            var appIcon: Image? { Image(systemName: "app.badge.fill") }
            var title: Text {
                Text("A much longer greet title that must wrap cleanly on compact devices")
            }
            var subtitle: Text? {
                Text("This subtitle is intentionally longer so narrow presentations and larger Dynamic Type sizes still have room to breathe.")
            }
            var features: [GreetFeatureItem] {
                (1...12).map { index in
                    GreetFeatureItem(
                        id: "feature-\(index)",
                        image: Image(systemName: "checkmark.circle.fill"),
                        label: Text("Greet feature \(index) with a longer localized label"),
                        description: Text(
                            "This greet description is long enough to wrap over multiple lines while keeping the icon, text, and action area stable."))
                }
            }
            var primaryButtonText: Text {
                Text("Get started with all sample data and preferences")
            }
            var skipButtonText: Text? {
                Text("Skip this longer greet flow for now")
            }
            var errorAlertTitle: Text { Text("Something went wrong") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: LongContent(),
            isLoading: .constant(false),
            errorMessage: .constant(nil),
            onPrimary: {},
            onSkip: {})
    }

    @Test
    func viewConstructsWhenComputedFeaturesRecreateValues() {
        struct ComputedContent: GreetContent {
            var title: Text { Text("Computed") }
            var features: [GreetFeatureItem] {
                [
                    GreetFeatureItem(id: "first", description: Text("First computed feature.")),
                    GreetFeatureItem(id: "second", description: Text("Second computed feature.")),
                    GreetFeatureItem(id: "third", description: Text("Third computed feature.")),
                ]
            }
            var primaryButtonText: Text { Text("Go") }
            var errorAlertTitle: Text { Text("Error") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: ComputedContent(),
            isLoading: .constant(false),
            errorMessage: .constant(nil),
            onPrimary: {},
            onSkip: {})
    }

    @Test
    func viewConstructsAcrossLoadingAndErrorStates() {
        struct StateContent: GreetContent {
            var title: Text { Text("State") }
            var features: [GreetFeatureItem] {
                [GreetFeatureItem(id: "state", description: Text("State feature."))]
            }
            var primaryButtonText: Text { Text("Start") }
            var skipButtonText: Text? { Text("Skip") }
            var errorAlertTitle: Text { Text("Error") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: StateContent(),
            isLoading: .constant(true),
            errorMessage: .constant("Network offline"),
            onPrimary: {},
            onSkip: {})

        _ = GreetView(
            content: StateContent(),
            isLoading: .constant(false),
            errorMessage: .constant("Retry failed"),
            onPrimary: {},
            onSkip: {})
    }

    private func backgroundView(_ background: GreetBackground) -> some View {
        self.styledView()
            .greetBackground(background)
    }

    private func styledView() -> GreetView<BackgroundContent> {
        GreetView(
            content: BackgroundContent(),
            isLoading: .constant(false),
            errorMessage: .constant(nil),
            onPrimary: {},
            onSkip: {})
    }

    private func totalTravel(from first: [CGPoint], to second: [CGPoint]) -> Double {
        zip(first, second).reduce(0) { total, pair in
            let xDistance = Double(pair.0.x - pair.1.x)
            let yDistance = Double(pair.0.y - pair.1.y)
            return total + ((xDistance * xDistance) + (yDistance * yDistance)).squareRoot()
        }
    }
}

private struct BackgroundContent: GreetContent {
    var title: Text { Text("Background") }
    var features: [GreetFeatureItem] {
        [GreetFeatureItem(id: "background-feature", description: Text("Background feature."))]
    }
    var primaryButtonText: Text { Text("Continue") }
    var errorAlertTitle: Text { Text("Error") }
    var errorOKText: Text { Text("OK") }
}

private struct BackgroundRouteContent: GreetContent {
    var title: Text { Text("Background route") }
    var features: [GreetFeatureItem] {
        [GreetFeatureItem(id: "background-route-feature", description: Text("Background route feature."))]
    }
    var primaryRoutes: [GreetPrimaryRoute] {
        [
            GreetPrimaryRoute(id: "first-route"),
            GreetPrimaryRoute(id: "second-route"),
        ]
    }
    var primaryButtonText: Text { Text("Continue") }
    var errorAlertTitle: Text { Text("Error") }
    var errorOKText: Text { Text("OK") }
}
#endif
