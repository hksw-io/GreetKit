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

    /// The reveal is tuned for a phone. On a Mac the same choreography reads as a marketing
    /// entrance, so the travel and the settle time are cut.
    @Test
    func macMotionIsShorterThanTheiOSReveal() {
        let lastRowSettles = Tokens.Motion.revealDelay(for: 100) + Tokens.Motion.revealDuration

        #if os(macOS)
            #expect(Tokens.Motion.revealOffset == 12)
            #expect(lastRowSettles < 0.6)
        #else
            #expect(Tokens.Motion.revealOffset == 38)
            #expect(lastRowSettles > 1)
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

    /// The container width feeds `horizontalPadding(for:)` from an `onGeometryChange`
    /// observer, so it starts at zero before the first layout pass and must land on the
    /// compact padding rather than the regular one.
    @Test
    func layoutUsesCompactPaddingBeforeTheContainerIsMeasured() {
        let padding = LayoutMetrics.horizontalPadding(
            for: 0,
            compact: 16,
            regular: 24,
            breakpoint: 390)

        #expect(padding == 16)
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

    @Test
    func footerUsesAsymmetricPaddingToSitCloserToBottomEdge() {
        #expect(Tokens.Layout.footerBottomPadding == 0)
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
