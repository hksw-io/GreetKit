#if os(iOS) || os(macOS)
import SwiftUI
import Testing
@testable import GreetKit

@Suite("Greet view construction")
@MainActor
struct GreetViewTests {
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
    func convenienceFeatureInitializerStoresStableID() {
        let feature = GreetFeatureItem(
            id: "localized-feature",
            systemImage: "sparkles",
            label: "Label",
            description: "Description.")

        #expect(feature.id == "localized-feature")
        #expect(feature.image != nil)
        #expect(feature.label != nil)
    }

    @Test
    func featureOmitsOptionalIconAndLabel() {
        let feature = GreetFeatureItem(id: "bare", description: Text("Description only."))

        #expect(feature.image == nil)
        #expect(feature.label == nil)
    }

    @Test
    func primaryRouteStoresStableID() {
        let route = GreetPrimaryRoute(id: "sample-data")

        #expect(route.id == "sample-data")
    }

    @Test
    func contentProtocolSuppliesDefaultsForOptionalMembers() {
        struct DefaultsContent: GreetContent {
            var title: Text { Text("Defaults") }
            var features: [GreetFeatureItem] { [] }
            var primaryButtonText: Text { Text("Go") }
            var errorAlertTitle: Text { Text("Error") }
            var errorOKText: Text { Text("OK") }
        }

        let content = DefaultsContent()

        #expect(content.appIcon == nil)
        #expect(content.subtitle == nil)
        #expect(content.skipButtonText == nil)
        #expect(content.primaryRoutes.isEmpty)
    }

    @Test
    func loadingAccessibilityValueCanBeOverriddenByTheConsumer() {
        struct LocalizedLoadingContent: GreetContent {
            var title: Text { Text("Localized") }
            var features: [GreetFeatureItem] {
                [GreetFeatureItem(id: "one", description: Text("One."))]
            }
            var primaryButtonText: Text { Text("Go") }
            var primaryButtonLoadingAccessibilityValue: Text { Text("Laddar") }
            var errorAlertTitle: Text { Text("Error") }
            var errorOKText: Text { Text("OK") }
        }

        _ = GreetView(
            content: LocalizedLoadingContent(),
            isLoading: .constant(true),
            errorMessage: .constant(nil),
            onPrimary: {},
            onSkip: {})
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

        let content = ComputedContent()

        #expect(content.features.map(\.id) == content.features.map(\.id))

        _ = GreetView(
            content: content,
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
