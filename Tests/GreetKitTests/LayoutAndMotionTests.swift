#if os(iOS) || os(macOS)
import SwiftUI
import Testing
@testable import GreetKit

@Suite("Layout and motion")
struct LayoutAndMotionTests {
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
    func revealDelayTreatsNegativeIndexesAsFirst() {
        #expect(Tokens.Motion.revealDelay(for: -3) == Tokens.Motion.featureBaseDelay)
    }

    /// The reveal should read as a soft cascade, so both platforms take about a second to
    /// finish. Rushing the stagger collapses it into rows arriving at once, which is worse than
    /// not staggering at all. What macOS cuts is the travel, not the pace.
    @Test
    func revealIsASlowSoftStagger() {
        let lastRowSettles = Tokens.Motion.revealDelay(for: 100) + Tokens.Motion.revealDuration

        #expect(lastRowSettles > 1)
        #expect(Tokens.Motion.revealDuration >= 0.45)

        // The gap between rows has to be a real fraction of the fade, or each arrival smears into
        // its neighbours and the cascade reads as one fade rather than a stagger.
        #expect(Tokens.Motion.featureStaggerDelay >= Tokens.Motion.revealDuration * 0.3)

        // And the cap has to let enough rows have their own start time. Capping early makes every
        // row past the cap fire on the same frame, which is the same failure by another route.
        let distinctlyStaggeredRows =
            Tokens.Motion.maxFeatureStaggerDelay / Tokens.Motion.featureStaggerDelay
        #expect(distinctlyStaggeredRows >= 6)

        #if os(macOS)
            #expect(Tokens.Motion.revealOffset == 20)
            #expect(lastRowSettles < 2.1)
            // The first row arrives promptly — a wait before anything happens reads as the sheet
            // being slow to draw. The pace comes from the gap between rows instead.
            #expect(Tokens.Motion.featureBaseDelay <= 0.1)
            #expect(Tokens.Motion.featureStaggerDelay > Tokens.Motion.featureBaseDelay)
        #else
            #expect(Tokens.Motion.revealOffset == 38)
            #expect(lastRowSettles < 2.1)
        #endif
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

    /// The container width arrives one layout pass late, from an `onGeometryChange` observer.
    /// The seeded value has to pick the same padding the measured pass will, or the content
    /// reflows and rewraps underneath the feature reveal.
    @Test
    func assumedContainerWidthMatchesTheMeasuredPadding() {
        let assumed = LayoutMetrics.horizontalPadding(
            for: Tokens.Platform.assumedContainerWidth,
            compact: 16,
            regular: 24,
            breakpoint: Tokens.Layout.compactWidthBreakpoint)

        #if os(macOS)
            // Every Mac sheet is at least sheetMinWidth, which is past the breakpoint.
            let measured = LayoutMetrics.horizontalPadding(
                for: Tokens.Platform.sheetMinWidth,
                compact: 16,
                regular: 24,
                breakpoint: Tokens.Layout.compactWidthBreakpoint)

            #expect(assumed == 24)
            #expect(assumed == measured)
        #else
            // A phone-width sheet sits at or under the breakpoint.
            let measured = LayoutMetrics.horizontalPadding(
                for: Tokens.Layout.compactWidthBreakpoint,
                compact: 16,
                regular: 24,
                breakpoint: Tokens.Layout.compactWidthBreakpoint)

            #expect(assumed == 16)
            #expect(assumed == measured)
        #endif
    }

    @Test
    func footerControlsUseCompactVisualSpacingWithAccessibleSkipHeight() {
        #expect(Tokens.Layout.footerControlSpacing == Tokens.Spacing.medium)

        #if os(macOS)
            // A pointer target, not a touch target.
            #expect(Tokens.Platform.minimumControlHeight == 28)
        #else
            #expect(Tokens.Platform.minimumControlHeight == 44)
        #endif
    }

    /// The button must clear the sheet edge rather than hug it, without floating so high that the
    /// bar looks detached. A route page has no skip button under the primary one, so nothing else
    /// holds it off the edge.
    @Test
    func footerUsesAsymmetricPaddingThatStillClearsTheBottomEdge() {
        #expect(Tokens.Layout.footerBottomPadding > 0)
        #expect(Tokens.Layout.footerBottomPadding < Tokens.Layout.footerTopPadding)
    }

    /// The Mac floor is a window shape, not a phone shape: wider than it is tall, and past the
    /// compact breakpoint so a Mac sheet never lands on the iPhone padding. iOS sets no floor —
    /// the presentation owns the size there.
    #if os(macOS)
        @Test
        func macSheetMinimumsAreWindowShaped() {
            #expect(Tokens.Platform.sheetMinWidth > Tokens.Platform.sheetMinHeight)
            #expect(Tokens.Platform.sheetMinWidth > Tokens.Layout.compactWidthBreakpoint)
            #expect(Tokens.Platform.sheetIdealWidth >= Tokens.Platform.sheetMinWidth)
            #expect(Tokens.Platform.sheetIdealHeight >= Tokens.Platform.sheetMinHeight)
        }
    #endif
}
#endif
