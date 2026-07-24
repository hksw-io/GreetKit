#if os(iOS) || os(macOS)
import Foundation

enum GreetRouteTransitionDirection: Equatable {
    case forward
    case backward
}

/// Transient navigation state for the primary button flow.
///
/// Kept as a plain value type so the transitions stay testable without a hosted view.
/// Every accessor resolves against the caller's current routes, so a route list that
/// changes while a route is open cannot leave the state pointing at a route that is
/// no longer rendered.
struct GreetRouteState: Equatable {
    struct ActiveRoute: Equatable {
        let index: Int
        let route: GreetPrimaryRoute
    }

    private(set) var activeRouteID: GreetPrimaryRoute.ID?
    private(set) var showsSingleDestination: Bool
    private(set) var transitionDirection: GreetRouteTransitionDirection

    init(
        activeRouteID: GreetPrimaryRoute.ID? = nil,
        showsSingleDestination: Bool = false,
        transitionDirection: GreetRouteTransitionDirection = .forward)
    {
        self.activeRouteID = activeRouteID
        self.showsSingleDestination = showsSingleDestination
        self.transitionDirection = transitionDirection
    }

    /// Opens the first route of a chain, or the single destination, depending on what the caller supplied.
    ///
    /// A route chain takes precedence over a single destination. When neither is available the
    /// state is left untouched so the overview stays on screen.
    mutating func begin(
        routes: [GreetPrimaryRoute],
        hasRouteDestination: Bool,
        hasSingleDestination: Bool)
    {
        if hasRouteDestination, let firstRoute = routes.first {
            self.transitionDirection = .forward
            self.showsSingleDestination = false
            self.activeRouteID = firstRoute.id
            return
        }

        guard hasSingleDestination else {
            return
        }

        self.transitionDirection = .forward
        self.showsSingleDestination = true
    }

    /// Moves to the route following `index`, completing the chain when there is no route left.
    mutating func advance(after index: Int, in routes: [GreetPrimaryRoute]) {
        let nextIndex = index + 1

        guard routes.indices.contains(nextIndex) else {
            self.complete()
            return
        }

        self.transitionDirection = .forward
        self.activeRouteID = routes[nextIndex].id
    }

    /// Returns to the overview.
    mutating func complete() {
        self.transitionDirection = .backward
        self.activeRouteID = nil
        self.showsSingleDestination = false
    }

    /// The route currently on screen, or `nil` when the active id is not part of `routes`.
    func activeRoute(in routes: [GreetPrimaryRoute]) -> ActiveRoute? {
        guard let activeRouteID = self.activeRouteID else {
            return nil
        }

        guard let index = routes.firstIndex(where: { $0.id == activeRouteID }) else {
            return nil
        }

        return ActiveRoute(index: index, route: routes[index])
    }

    /// Identifies what is on screen so the container can key its transition animation.
    ///
    /// Resolved against `routes` rather than the raw active id, so the phase always matches
    /// the view that is actually rendered.
    func phaseID(in routes: [GreetPrimaryRoute]) -> String {
        if let activeRoute = self.activeRoute(in: routes) {
            return "route-\(activeRoute.route.id)"
        }

        return self.showsSingleDestination ? "single" : "overview"
    }
}
#endif
