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
        #expect(style.secondaryButtonColor == nil)
    }

    /// The primary button draws itself with `.glassProminent` and takes its colour from the
    /// tint `GreetView` applies, so the style carries no button background or progress role.
    /// `primaryButtonForegroundColor` stays as an opt-in override of the system label colour.
    @Test
    func primaryButtonForegroundIsUnsetUntilTheConsumerOverridesIt() {
        #expect(GreetStyle.standard.primaryButtonForegroundColor == nil)
        #expect(GreetStyle(primaryButtonForegroundColor: .black).primaryButtonForegroundColor == .black)
    }

    /// `AnyShapeStyle` cannot be compared, so the resolved roles are exercised for
    /// construction only. The colour precedence they encode is asserted through the
    /// stored roles here.
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
            secondaryButtonColor: .secondary)

        for style in [standard, custom] {
            _ = style.subtitleForegroundStyle
            _ = style.featureIconForegroundStyle
            _ = style.featureDescriptionForegroundStyle
            _ = style.secondaryButtonForegroundStyle
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
