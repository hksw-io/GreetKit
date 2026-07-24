#if os(iOS) || os(macOS)
import SwiftUI
import Testing
@testable import GreetKit

@Suite("Footer mask metrics")
struct FooterMaskTests {
    @Test
    func heightQuantizesToWholePoints() {
        #expect(FooterMaskMetrics.quantizedHeight(123.4) == 123)
        #expect(FooterMaskMetrics.quantizedHeight(123.5) == 124)
    }

    @Test
    func frameQuantizesPositionAndHeight() {
        let frame = FooterMaskMetrics.quantizedFrame(CGRect(x: 0, y: 612.4, width: 390, height: 127.5))

        #expect(frame.minY == 612)
        #expect(frame.height == 128)
    }

    @Test
    func negativeAndZeroHeightsQuantizeToZero() {
        #expect(FooterMaskMetrics.quantizedHeight(0) == 0)
        #expect(FooterMaskMetrics.quantizedHeight(-12) == 0)
    }

    @Test
    func fadeHeightCapsToAvoidEarlyMasking() {
        #expect(FooterMaskMetrics.resolvedFadeHeight(80) == FooterMaskMetrics.maximumFadeHeight)
    }

    @Test
    func fadeHeightKeepsShorterValues() {
        #expect(FooterMaskMetrics.resolvedFadeHeight(18) == 18)
        #expect(FooterMaskMetrics.resolvedFadeHeight(0) == 0)
    }

    @Test
    func fadeBottomIsHiddenWhenScrollableContentContinues() {
        #expect(FooterMaskMetrics.fadeBottomOpacity(scrollEdgeFadeOpacity: 1) == 0)
    }

    @Test
    func fadeBottomIsVisibleAtScrollEnd() {
        #expect(FooterMaskMetrics.fadeBottomOpacity(scrollEdgeFadeOpacity: 0) == 1)
    }

    @Test
    func fadeBottomOpacityClampsOutOfRangeInput() {
        #expect(FooterMaskMetrics.fadeBottomOpacity(scrollEdgeFadeOpacity: 2) == 0)
        #expect(FooterMaskMetrics.fadeBottomOpacity(scrollEdgeFadeOpacity: -1) == 1)
    }

    @Test
    func layoutUsesMeasuredFooterTop() {
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
    func layoutStaysOpaqueBeforeFooterMeasurement() {
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
    func layoutClampsAFooterTallerThanItsContainer() {
        let layout = FooterMaskMetrics.layout(
            containerHeight: 200,
            footerFrame: FooterMaskFrame(minY: 400, height: 128),
            fadeHeight: 28,
            scrollEdgeFadeOpacity: 0)

        #expect(layout.opaqueHeight == 172)
        #expect(layout.fadeHeight == 28)
        #expect(layout.clearHeight == 0)
    }

    @Test
    func contentBottomInsetMatchesMeasuredFooterArea() {
        let inset = FooterMaskMetrics.contentBottomInset(
            containerHeight: 740,
            footerFrame: FooterMaskFrame(minY: 612, height: 128))

        #expect(inset == 128)
    }

    @Test
    func contentBottomInsetIsZeroBeforeFooterMeasurement() {
        let inset = FooterMaskMetrics.contentBottomInset(
            containerHeight: 740,
            footerFrame: .zero)

        #expect(inset == 0)
    }

    @Test
    func frameReportsWhetherItHasBeenMeasured() {
        #expect(!FooterMaskFrame.zero.isMeasured)
        #expect(FooterMaskFrame(minY: 612, height: 128).isMeasured)
    }
}
#endif
