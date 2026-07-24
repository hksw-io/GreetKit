#if os(iOS) || os(macOS)
import Testing
@testable import GreetKit

@Suite("Keyboard policy")
struct KeyboardPolicyTests {
    @Test
    func escapeSkipsWhenTheSkipButtonIsVisibleAndDismissalIsAllowed() {
        #expect(GreetKeyboardPolicy.allowsCancelShortcut(
            hasSkipButton: true,
            allowsInteractiveDismissal: true))
    }

    /// Escape must not reach `onSkip` when the consumer left `skipButtonText` nil, because the
    /// action would have no counterpart on screen.
    @Test
    func escapeDoesNothingWithoutAVisibleSkipButton() {
        #expect(!GreetKeyboardPolicy.allowsCancelShortcut(
            hasSkipButton: false,
            allowsInteractiveDismissal: true))
    }

    /// A setup flow that blocks swipe and window dismissal must also block the keyboard.
    @Test
    func escapeDoesNothingWhenDismissalIsBlocked() {
        #expect(!GreetKeyboardPolicy.allowsCancelShortcut(
            hasSkipButton: true,
            allowsInteractiveDismissal: false))
    }

    @Test
    func escapeDoesNothingWhenBothConditionsFail() {
        #expect(!GreetKeyboardPolicy.allowsCancelShortcut(
            hasSkipButton: false,
            allowsInteractiveDismissal: false))
    }
}
#endif
