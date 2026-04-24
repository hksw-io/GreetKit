#if os(iOS) || os(macOS)
import SwiftUI

public struct OnboardingView<Content: OnboardingContent>: View {
    let content: Content
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    let onPrimary: () -> Void
    let onSkip: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var featuresVisible = false
    @State private var scrollEdgeFadeOpacity: Double = 1

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = Tokens.Platform.iconSize
    @ScaledMetric(relativeTo: .body) private var featureIconSize: CGFloat = Tokens.Platform.featureIconSize
    @ScaledMetric(relativeTo: .body) private var contentSpacing: CGFloat = Tokens.Platform.contentSpacing
    @ScaledMetric(relativeTo: .body) private var featureSpacing: CGFloat = Tokens.Platform.featureSpacing
    @ScaledMetric(relativeTo: .body) private var topPadding: CGFloat = Tokens.Platform.topPadding
    @ScaledMetric(relativeTo: .body) private var bottomPadding: CGFloat = Tokens.Platform.bottomPadding
    @ScaledMetric(relativeTo: .body) private var scrollEdgeFadeHeight: CGFloat = Tokens.Platform.scrollEdgeFadeHeight
    @ScaledMetric(relativeTo: .body) private var compactHorizontalPadding: CGFloat = Tokens.Layout.compactHorizontalPadding
    @ScaledMetric(relativeTo: .body) private var regularHorizontalPadding: CGFloat = Tokens.Layout.regularHorizontalPadding

    public init(
        content: Content,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>,
        onPrimary: @escaping () -> Void,
        onSkip: @escaping () -> Void)
    {
        self.content = content
        self._isLoading = isLoading
        self._errorMessage = errorMessage
        self.onPrimary = onPrimary
        self.onSkip = onSkip
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: self.contentSpacing) {
                    OnboardingHeaderSection(
                        content: self.content,
                        iconSize: self.iconSize)
                    OnboardingFeatureList(
                        features: self.content.features,
                        featureSpacing: self.featureSpacing,
                        featureIconSize: self.featureIconSize,
                        featuresVisible: self.featuresVisible,
                        reduceMotion: self.reduceMotion)
                }
                .frame(maxWidth: Tokens.Layout.contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, self.horizontalPadding(for: geometry.size.width))
                .padding(.top, self.topPadding)
                .padding(.bottom, self.bottomPadding)
            }
            .scrollBounceBehavior(.basedOnSize)
            .onScrollGeometryChange(for: Double.self) { geometry in
                guard geometry.contentSize.height > 0 else { return 1 }
                let contentBottom = geometry.contentSize.height + geometry.contentInsets.bottom
                let distance = contentBottom - geometry.visibleRect.maxY
                return min(1, max(0, distance / self.scrollEdgeFadeHeight))
            } action: { _, newOpacity in
                self.scrollEdgeFadeOpacity = newOpacity
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ZStack {
                    OnboardingFooterSection(
                        content: self.content,
                        isLoading: self.isLoading,
                        onPrimary: self.onPrimary,
                        onSkip: self.onSkip)
                        .frame(maxWidth: Tokens.Layout.contentMaxWidth)
                        .padding(.horizontal, self.horizontalPadding(for: geometry.size.width))
                }
                .frame(maxWidth: .infinity)
                .background(alignment: .top) {
                    LinearGradient(
                        colors: [
                            Tokens.background.opacity(0),
                            Tokens.background,
                        ],
                        startPoint: .top,
                        endPoint: .bottom)
                        .frame(height: self.scrollEdgeFadeHeight)
                        .offset(y: -self.scrollEdgeFadeHeight)
                        .opacity(self.scrollEdgeFadeOpacity)
                        .allowsHitTesting(false)
                }
                .background(Tokens.background)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .interactiveDismissDisabled()
        #if os(macOS)
            .frame(minWidth: 520, minHeight: 620)
        #endif
            .alert(
                self.content.errorAlertTitle,
                isPresented: self.errorPresented,
                actions: {
                    Button(role: .cancel) {
                        self.errorMessage = nil
                    } label: {
                        self.content.errorOKText
                    }
                },
                message: {
                    if let message = self.errorMessage {
                        Text(message)
                    }
                })
            .onAppear {
                self.featuresVisible = true
            }
    }

    private func horizontalPadding(for width: CGFloat) -> CGFloat {
        width < Tokens.Layout.compactWidthBreakpoint ? self.compactHorizontalPadding : self.regularHorizontalPadding
    }

    private var errorPresented: Binding<Bool> {
        Binding(
            get: { self.errorMessage != nil },
            set: { newValue in
                if !newValue { self.errorMessage = nil }
            })
    }
}

private struct OnboardingHeaderSection<Content: OnboardingContent>: View {
    let content: Content
    let iconSize: CGFloat

    var body: some View {
        VStack(spacing: Tokens.Spacing.large) {
            if let appIcon = self.content.appIcon {
                appIcon
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.iconSize, height: self.iconSize)
                    .clipShape(RoundedRectangle(cornerRadius: self.iconSize * Tokens.Radius.iconScale))
                    .accessibilityHidden(true)
            }

            self.content.title
            #if os(macOS)
                .font(.title)
            #else
                .font(.largeTitle)
            #endif
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            if let subtitle = self.content.subtitle {
                subtitle
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct OnboardingFeatureList: View {
    let features: [OnboardingFeatureItem]
    let featureSpacing: CGFloat
    let featureIconSize: CGFloat
    let featuresVisible: Bool
    let reduceMotion: Bool

    var body: some View {
        VStack(spacing: self.featureSpacing) {
            ForEach(Array(self.features.enumerated()), id: \.offset) { index, feature in
                OnboardingFeatureRow(
                    feature: feature,
                    index: index,
                    featureIconSize: self.featureIconSize,
                    featuresVisible: self.featuresVisible,
                    reduceMotion: self.reduceMotion)
            }
        }
    }
}

private struct OnboardingFeatureRow: View {
    let feature: OnboardingFeatureItem
    let index: Int
    let featureIconSize: CGFloat
    let featuresVisible: Bool
    let reduceMotion: Bool

    var body: some View {
        let delay = Tokens.Motion.featureBaseDelay + (Double(index) * Tokens.Motion.featureStaggerDelay)
        let isVisible = self.featuresVisible

        HStack(alignment: .top, spacing: Tokens.Spacing.large) {
            if let image = self.feature.image {
                image
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: self.featureIconSize, height: self.featureIconSize)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let label = self.feature.label {
                    label
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                self.feature.description
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.leading)
            .layoutPriority(1)

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : (self.reduceMotion ? 0 : Tokens.Motion.revealOffset))
        .animation(
            self.reduceMotion ? nil : .easeOut(duration: Tokens.Motion.revealDuration).delay(delay),
            value: isVisible)
    }
}

private struct OnboardingFooterSection<Content: OnboardingContent>: View {
    let content: Content
    let isLoading: Bool
    let onPrimary: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: Tokens.Spacing.medium) {
            Button {
                self.onPrimary()
            } label: {
                Group {
                    if self.isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        self.content.primaryButtonText
                            .font(.body.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 28)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            .disabled(self.isLoading)

            if let skipText = self.content.skipButtonText {
                Button {
                    self.onSkip()
                } label: {
                    skipText
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .disabled(self.isLoading)
            }
        }
        .padding(.vertical, Tokens.Spacing.medium)
    }
}

private struct OnboardingPreviewContent: OnboardingContent {
    var appIcon: Image? { Image(systemName: "app.gift.fill") }
    var title: Text { Text("Welcome") }
    var subtitle: Text? { Text("Here's what makes this app great.") }
    var features: [OnboardingFeatureItem] {
        [
            OnboardingFeatureItem(
                systemImage: "hand.tap.fill",
                label: "Tap to flip",
                description: "Review cards with a simple tap."),
            OnboardingFeatureItem(
                systemImage: "folder.fill",
                label: "Organize",
                description: "Group cards into decks and folders."),
            OnboardingFeatureItem(
                systemImage: "brain.head.profile.fill",
                label: "Spaced repetition",
                description: "Study smarter, not harder."),
        ]
    }
    var primaryButtonText: Text { Text("Get started") }
    var skipButtonText: Text? { Text("Skip for now") }
    var errorAlertTitle: Text { Text("Something went wrong") }
    var errorOKText: Text { Text("OK") }
}

private struct LongOnboardingPreviewContent: OnboardingContent {
    var appIcon: Image? { Image(systemName: "rectangle.stack.badge.plus.fill") }
    var title: Text {
        Text("A much longer onboarding title that must wrap cleanly")
    }
    var subtitle: Text? {
        Text("This subtitle is intentionally longer so narrow presentations and larger Dynamic Type sizes still have room to breathe.")
    }
    var features: [OnboardingFeatureItem] {
        (1...12).map { index in
            OnboardingFeatureItem(
                systemImage: "checkmark.circle.fill",
                label: "Onboarding feature \(index) with a longer localized label",
                description: "This onboarding description is long enough to wrap over multiple lines while keeping the icon, text, and action area stable.")
        }
    }
    var primaryButtonText: Text {
        Text("Get started with all sample data and preferences")
    }
    var skipButtonText: Text? {
        Text("Skip this longer onboarding flow for now")
    }
    var errorAlertTitle: Text { Text("Something went wrong") }
    var errorOKText: Text { Text("OK") }
}

#Preview("Onboarding") {
    @Previewable @State var isLoading = false
    @Previewable @State var errorMessage: String?

    OnboardingView(
        content: OnboardingPreviewContent(),
        isLoading: $isLoading,
        errorMessage: $errorMessage,
        onPrimary: { isLoading = true },
        onSkip: {})
}

#Preview("Onboarding Long Narrow") {
    OnboardingView(
        content: LongOnboardingPreviewContent(),
        isLoading: .constant(false),
        errorMessage: .constant(nil),
        onPrimary: {},
        onSkip: {})
        .frame(width: 320, height: 760)
}

#Preview("Onboarding Loading") {
    OnboardingView(
        content: OnboardingPreviewContent(),
        isLoading: .constant(true),
        errorMessage: .constant(nil),
        onPrimary: {},
        onSkip: {})
        .frame(width: 390, height: 740)
}

#Preview("Onboarding Dark Accessibility") {
    OnboardingView(
        content: LongOnboardingPreviewContent(),
        isLoading: .constant(false),
        errorMessage: .constant(nil),
        onPrimary: {},
        onSkip: {})
        .frame(width: 390, height: 780)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility2)
}
#endif
