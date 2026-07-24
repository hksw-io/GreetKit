#if os(iOS) || os(macOS)
import SwiftUI

enum Tokens {
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
    }

    enum Radius {
        static let iconScale: CGFloat = 0.22
    }

    enum Layout {
        static let contentMaxWidth: CGFloat = 560
        static let compactHorizontalPadding: CGFloat = 16
        static let regularHorizontalPadding: CGFloat = 24
        static let compactWidthBreakpoint: CGFloat = 390
        static let footerControlSpacing: CGFloat = Spacing.medium
        static let footerTopPadding: CGFloat = 20
        static let footerBottomPadding: CGFloat = 0
    }

    /// Kept here rather than in `Platform` so the shared `revealDelay(for:)` stays next to the
    /// values it composes.
    enum Motion {
        #if os(macOS)
            // A Mac sheet should be ready to use, not perform an entrance. Shorter travel,
            // tighter stagger, and roughly half the settle time.
            //
            // The base delay also has to outlast the sheet's own presentation animation. Starting
            // the reveal while the sheet is still moving composites one animation onto another and
            // reads as a shake, however clean each one is on its own.
            static let featureBaseDelay: Double = 0.2
            static let featureStaggerDelay: Double = 0.05
            static let maxFeatureStaggerDelay: Double = 0.2
            static let revealDuration: Double = 0.26
            static let revealOffset: CGFloat = 12
            static let routeTransitionDuration: Double = 0.26
        #else
            static let featureBaseDelay: Double = 0.3
            static let featureStaggerDelay: Double = 0.17
            static let maxFeatureStaggerDelay: Double = 0.68
            static let revealDuration: Double = 0.48
            static let revealOffset: CGFloat = 38
            static let routeTransitionDuration: Double = 0.32
        #endif

        static func revealDelay(for index: Int) -> Double {
            let staggerDelay = min(Double(max(0, index)) * self.featureStaggerDelay, self.maxFeatureStaggerDelay)
            return self.featureBaseDelay + staggerDelay
        }
    }

    enum Platform {
        #if os(macOS)
            static let iconSize: CGFloat = 64
            static let featureIconSize: CGFloat = 24
            static let contentSpacing: CGFloat = 24
            static let featureSpacing: CGFloat = 20
            static let topPadding: CGFloat = 32
            static let bottomPadding: CGFloat = 20
            /// A Mac window is wider than it is tall. The old 320x620 floor was an iPhone
            /// shape on a desktop.
            static let sheetMinWidth: CGFloat = 480
            static let sheetMinHeight: CGFloat = 420
            static let sheetIdealWidth: CGFloat = 560
            static let sheetIdealHeight: CGFloat = 520
            /// What to assume before the container reports its width, so the first layout pass
            /// already picks the padding the measured pass will confirm. A Mac sheet is never
            /// narrower than `sheetMinWidth`, which is past the compact breakpoint.
            static let assumedContainerWidth: CGFloat = sheetIdealWidth
            /// A pointer target, not a touch target.
            static let minimumControlHeight: CGFloat = 28
        #else
            static let iconSize: CGFloat = 100
            static let featureIconSize: CGFloat = 35
            static let contentSpacing: CGFloat = 38
            static let featureSpacing: CGFloat = 32
            static let topPadding: CGFloat = 32
            static let bottomPadding: CGFloat = 24
            static let minimumControlHeight: CGFloat = 44
            /// Phone width, which is what a sheet is on the overwhelming majority of iOS
            /// presentations. iPad still corrects itself on the measured pass.
            static let assumedContainerWidth: CGFloat = 0
        #endif
    }

    static var background: Color {
        #if os(macOS)
            Color(.windowBackgroundColor)
        #else
            Color(.systemBackground)
        #endif
    }
}
#endif
