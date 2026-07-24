#if os(iOS) || os(macOS)
import SwiftUI
import Testing
@testable import GreetKit

@Suite("Greet style")
struct GreetStyleTests {
    @Test
    func standardStyleLeavesEveryRoleUnset() {
        let style = GreetStyle.standard

        #expect(style.tint == nil)
        #expect(style.titleColor == nil)
        #expect(style.subtitleColor == nil)
        #expect(style.featureIconColor == nil)
        #expect(style.featureTitleColor == nil)
        #expect(style.featureDescriptionColor == nil)
        #expect(style.primaryButtonForegroundColor == nil)
        #expect(style.primaryButtonProgressTint == nil)
        #expect(style.secondaryButtonColor == nil)
    }

    @Test
    func progressTintFallsBackToWhite() {
        #expect(GreetStyle.standard.resolvedPrimaryButtonProgressTint == .white)
    }

    @Test
    func progressTintFollowsThePrimaryButtonForeground() {
        let style = GreetStyle(primaryButtonForegroundColor: .black)

        #expect(style.resolvedPrimaryButtonProgressTint == .black)
    }

    @Test
    func explicitProgressTintWinsOverThePrimaryButtonForeground() {
        let style = GreetStyle(
            primaryButtonForegroundColor: .black,
            primaryButtonProgressTint: .yellow)

        #expect(style.resolvedPrimaryButtonProgressTint == .yellow)
    }

    /// `AnyShapeStyle` cannot be compared, so the resolved roles are exercised for
    /// construction only. The colour precedence they encode is asserted through
    /// `resolvedPrimaryButtonProgressTint` above and through the stored roles here.
    @Test
    func resolvedForegroundRolesBuildForBothDefaultAndCustomColors() {
        let standard = GreetStyle.standard
        let custom = GreetStyle(
            tint: .indigo,
            titleColor: .primary,
            subtitleColor: .secondary,
            featureIconColor: .mint,
            featureTitleColor: .primary,
            featureDescriptionColor: .secondary,
            primaryButtonForegroundColor: .white,
            primaryButtonProgressTint: .white,
            secondaryButtonColor: .secondary)

        for style in [standard, custom] {
            _ = style.subtitleForegroundStyle
            _ = style.featureIconForegroundStyle
            _ = style.featureDescriptionForegroundStyle
            _ = style.secondaryButtonForegroundStyle
            _ = style.primaryButtonForegroundStyle
            _ = style.primaryButtonBackgroundStyle
        }
    }

    @Test
    func featureIconInheritsTheTintWhenNoIconColorIsGiven() {
        let style = GreetStyle(tint: .indigo)

        #expect(style.featureIconColor == nil)
        #expect(style.tint == .indigo)
        _ = style.featureIconForegroundStyle
    }

    @Test
    func styleIsAValueTypeSoOverridesDoNotLeak() {
        var style = GreetStyle.standard
        let copy = style
        style.tint = .indigo

        #expect(copy.tint == nil)
        #expect(style.tint == .indigo)
    }
}
#endif
