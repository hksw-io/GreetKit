#if os(iOS) || os(macOS)
import SwiftUI

public struct GreetStyle: Sendable {
    public var tint: Color?
    public var titleColor: Color?
    public var subtitleColor: Color?
    public var featureIconColor: Color?
    public var featureTitleColor: Color?
    public var featureDescriptionColor: Color?
    public var primaryButtonForegroundColor: Color?
    public var secondaryButtonColor: Color?

    public static let standard = Self()

    public init(
        tint: Color? = nil,
        titleColor: Color? = nil,
        subtitleColor: Color? = nil,
        featureIconColor: Color? = nil,
        featureTitleColor: Color? = nil,
        featureDescriptionColor: Color? = nil,
        primaryButtonForegroundColor: Color? = nil,
        secondaryButtonColor: Color? = nil)
    {
        self.tint = tint
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.featureIconColor = featureIconColor
        self.featureTitleColor = featureTitleColor
        self.featureDescriptionColor = featureDescriptionColor
        self.primaryButtonForegroundColor = primaryButtonForegroundColor
        self.secondaryButtonColor = secondaryButtonColor
    }
}

extension GreetStyle {
    var subtitleForegroundStyle: AnyShapeStyle {
        Self.foregroundStyle(for: self.subtitleColor, fallback: AnyShapeStyle(.secondary))
    }

    var featureIconForegroundStyle: AnyShapeStyle {
        Self.foregroundStyle(for: self.featureIconColor ?? self.tint, fallback: AnyShapeStyle(.tint))
    }

    var featureDescriptionForegroundStyle: AnyShapeStyle {
        Self.foregroundStyle(for: self.featureDescriptionColor, fallback: AnyShapeStyle(.secondary))
    }

    var secondaryButtonForegroundStyle: AnyShapeStyle {
        Self.foregroundStyle(for: self.secondaryButtonColor, fallback: AnyShapeStyle(.secondary))
    }

    private static func foregroundStyle(for color: Color?, fallback: AnyShapeStyle) -> AnyShapeStyle {
        guard let color else {
            return fallback
        }

        return AnyShapeStyle(color)
    }
}
#endif
