#if os(iOS) || os(macOS)
import Testing
@testable import GreetKit

@Suite("Greet route state")
struct GreetRouteStateTests {
    private let routes = [
        GreetPrimaryRoute(id: "permissions"),
        GreetPrimaryRoute(id: "sample-data"),
        GreetPrimaryRoute(id: "notifications"),
    ]

    @Test
    func startsOnTheOverview() {
        let state = GreetRouteState()

        #expect(state.activeRouteID == nil)
        #expect(!state.showsSingleDestination)
        #expect(state.phaseID(in: self.routes) == "overview")
        #expect(state.activeRoute(in: self.routes) == nil)
    }

    @Test
    func beginOpensTheFirstRouteOfAChain() {
        var state = GreetRouteState()

        state.begin(routes: self.routes, hasRouteDestination: true, hasSingleDestination: false)

        #expect(state.activeRouteID == "permissions")
        #expect(!state.showsSingleDestination)
        #expect(state.transitionDirection == .forward)
        #expect(state.phaseID(in: self.routes) == "route-permissions")
    }

    @Test
    func beginPrefersTheRouteChainOverASingleDestination() {
        var state = GreetRouteState()

        state.begin(routes: self.routes, hasRouteDestination: true, hasSingleDestination: true)

        #expect(state.activeRouteID == "permissions")
        #expect(!state.showsSingleDestination)
    }

    @Test
    func beginOpensTheSingleDestinationWhenThereIsNoChain() {
        var state = GreetRouteState()

        state.begin(routes: [], hasRouteDestination: false, hasSingleDestination: true)

        #expect(state.activeRouteID == nil)
        #expect(state.showsSingleDestination)
        #expect(state.transitionDirection == .forward)
        #expect(state.phaseID(in: []) == "single")
    }

    @Test
    func beginFallsBackToTheSingleDestinationWhenTheChainIsEmpty() {
        var state = GreetRouteState()

        state.begin(routes: [], hasRouteDestination: true, hasSingleDestination: true)

        #expect(state.activeRouteID == nil)
        #expect(state.showsSingleDestination)
    }

    @Test
    func beginStaysOnTheOverviewWithoutAnyDestination() {
        var state = GreetRouteState()

        state.begin(routes: self.routes, hasRouteDestination: false, hasSingleDestination: false)

        #expect(state.activeRouteID == nil)
        #expect(!state.showsSingleDestination)
        #expect(state.phaseID(in: self.routes) == "overview")
    }

    @Test
    func advanceMovesToTheNextRoute() {
        var state = GreetRouteState()
        state.begin(routes: self.routes, hasRouteDestination: true, hasSingleDestination: false)

        state.advance(after: 0, in: self.routes)

        #expect(state.activeRouteID == "sample-data")
        #expect(state.transitionDirection == .forward)

        state.advance(after: 1, in: self.routes)

        #expect(state.activeRouteID == "notifications")
    }

    @Test
    func advancingPastTheLastRouteReturnsToTheOverview() {
        var state = GreetRouteState()
        state.begin(routes: self.routes, hasRouteDestination: true, hasSingleDestination: false)

        state.advance(after: self.routes.count - 1, in: self.routes)

        #expect(state.activeRouteID == nil)
        #expect(state.transitionDirection == .backward)
        #expect(state.phaseID(in: self.routes) == "overview")
    }

    @Test
    func completeReturnsToTheOverviewAndReversesTheTransition() {
        var state = GreetRouteState()
        state.begin(routes: self.routes, hasRouteDestination: true, hasSingleDestination: false)

        state.complete()

        #expect(state.activeRouteID == nil)
        #expect(!state.showsSingleDestination)
        #expect(state.transitionDirection == .backward)
    }

    @Test
    func activeRouteResolvesIndexAndRoute() {
        var state = GreetRouteState()
        state.begin(routes: self.routes, hasRouteDestination: true, hasSingleDestination: false)
        state.advance(after: 0, in: self.routes)

        let activeRoute = state.activeRoute(in: self.routes)

        #expect(activeRoute?.index == 1)
        #expect(activeRoute?.route.id == "sample-data")
    }

    /// A consumer can compute `primaryRoutes`, so the list can change while a route is open.
    /// The state must resolve against the current list rather than trust the stored id.
    @Test
    func activeRouteIsNilWhenTheRouteIsNoLongerInTheList() {
        let state = GreetRouteState(activeRouteID: "removed-route")

        #expect(state.activeRoute(in: self.routes) == nil)
    }

    @Test
    func phaseIDFallsBackToTheOverviewWhenTheActiveRouteDisappears() {
        let state = GreetRouteState(activeRouteID: "removed-route")

        #expect(state.phaseID(in: self.routes) == "overview")
    }

    @Test
    func phaseIDPrefersTheRouteOverTheSingleDestination() {
        let state = GreetRouteState(activeRouteID: "sample-data", showsSingleDestination: true)

        #expect(state.phaseID(in: self.routes) == "route-sample-data")
    }

    @Test
    func phaseIDReportsTheSingleDestinationWhenNoRouteResolves() {
        let state = GreetRouteState(activeRouteID: "removed-route", showsSingleDestination: true)

        #expect(state.phaseID(in: self.routes) == "single")
    }

    @Test
    func advanceHandlesASingleRouteChain() {
        let singleRoute = [GreetPrimaryRoute(id: "only")]
        var state = GreetRouteState()
        state.begin(routes: singleRoute, hasRouteDestination: true, hasSingleDestination: false)

        #expect(state.activeRouteID == "only")

        state.advance(after: 0, in: singleRoute)

        #expect(state.activeRouteID == nil)
        #expect(state.transitionDirection == .backward)
    }

    @Test
    func reopeningAChainAfterCompletionRestoresForwardMotion() {
        var state = GreetRouteState()
        state.begin(routes: self.routes, hasRouteDestination: true, hasSingleDestination: false)
        state.complete()

        #expect(state.transitionDirection == .backward)

        state.begin(routes: self.routes, hasRouteDestination: true, hasSingleDestination: false)

        #expect(state.transitionDirection == .forward)
        #expect(state.activeRouteID == "permissions")
    }
}
#endif
