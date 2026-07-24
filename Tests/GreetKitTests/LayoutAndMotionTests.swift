#if os(iOS) || os(macOS)
import SwiftUI
import Testing
@testable import GreetKit

@Suite("Layout, scroll fade, and motion")
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
    func scrollEdgeFadeIsFullyMaskedBeforeMeasurement() {
        #expect(ScrollEdgeFade.opacity(contentHeight: 0, visibleMaxY: 0, fadeHeight: 100) == 1)
        #expect(ScrollEdgeFade.opacity(contentHeight: 1_000, visibleMaxY: 0, fadeHeight: 0) == 1)
    }

    @Test
    func scrollEdgeFadeQuantizesToTheGivenStep() {
        #expect(ScrollEdgeFade.quantize(0.43) == 0.45)
        #expect(ScrollEdgeFade.quantize(0.43, step: 0.25) == 0.5)
        #expect(ScrollEdgeFade.quantize(0.43, step: 0) == 0.43)
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
