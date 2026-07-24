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
        #expect(Tokens.Layout.minimumControlHeight == 44)
    }

    @Test
    func footerUsesAsymmetricPaddingToSitCloserToBottomEdge() {
        #expect(Tokens.Layout.footerBottomPadding == 0)
        #expect(Tokens.Layout.footerBottomPadding < Tokens.Layout.footerTopPadding)
    }

    @Test
    func compactSheetMinimumsLeaveRoomForContentAndFooter() {
        #expect(Tokens.Layout.compactSheetMinWidth <= Tokens.Layout.compactWidthBreakpoint)
        #expect(Tokens.Layout.compactSheetMinHeight > Tokens.Layout.compactSheetMinWidth)
    }
}
#endif
