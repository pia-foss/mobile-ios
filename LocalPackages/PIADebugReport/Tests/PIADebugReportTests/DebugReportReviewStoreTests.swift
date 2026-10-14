//
//  DebugReportReviewStoreTests.swift
//  PIADebugReportTests
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import CoreArchitecture
import PIALibrary
import Testing

@testable import PIADebugReport

@MainActor
struct DebugReportReviewStoreTests {

    private let spy = DebugReportDependencySpy()

    private func makeStore(
        state: DebugReportReview.State = .init()
    ) -> TestStore<DebugReportReview.State, DebugReportReview.Action> {
        TestStore(
            initial: state,
            reduce: DebugReportReview.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    /// Runs the build effect and applies the action it produces.
    private func buildReport(on sut: TestStore<DebugReportReview.State, DebugReportReview.Action>) async {
        _ = await sut.receive()
        await sut.finish()
    }

    @Test("Appearing builds the report")
    func appearingBuildsReport() async {
        let sut = makeStore()

        sut.send(.onAppear)
        #expect(sut.state.isBuilding)

        await buildReport(on: sut)

        #expect(sut.state.sections.count == 2)
        #expect(sut.state.hasBuilt)
        #expect(!sut.state.isBuilding)
        #expect(spy.buildCallCount == 1)
    }

    @Test("Re-appearing does not rebuild an already built report")
    func reAppearingDoesNotRebuild() async {
        let sut = makeStore()
        sut.send(.onAppear)
        await buildReport(on: sut)

        sut.send(.onAppear)
        await sut.finish()

        #expect(spy.buildCallCount == 1)
    }

    @Test("Sending submits exactly the reviewed report and emits the id")
    func sendingSubmitsReviewedReport() async {
        let sut = makeStore()
        sut.send(.onAppear)
        await buildReport(on: sut)
        let reviewed = DebugReport(sections: sut.state.sections)

        sut.send(.sendTapped)
        #expect(sut.state.isSending)

        _ = await sut.receive()
        await sut.finish()

        #expect(!sut.state.isSending)
        #expect(spy.submitCallCount == 1)
        #expect(spy.submittedReport == reviewed)
        #expect(spy.emittedOutputs == [.didSubmit(reportId: "ABC123")])
    }

    @Test("A failed submission emits failure and stops sending")
    func failedSubmissionEmitsFailure() async {
        spy.submitResult = .failure(DebugReportReviewTestError())
        let sut = makeStore()
        sut.send(.onAppear)
        await buildReport(on: sut)

        sut.send(.sendTapped)
        _ = await sut.receive()
        await sut.finish()

        #expect(!sut.state.isSending)
        #expect(spy.emittedOutputs == [.submissionFailed])
        #expect(sut.state.canSend)
    }

    @Test("A report that was sent successfully cannot be sent again")
    func sentReportCannotBeResent() async {
        let sut = makeStore()
        sut.send(.onAppear)
        await buildReport(on: sut)
        sut.send(.sendTapped)
        _ = await sut.receive()
        await sut.finish()

        #expect(sut.state.hasSubmitted)
        #expect(!sut.state.canSend)

        sut.send(.sendTapped)
        await sut.finish()

        #expect(spy.submitCallCount == 1)
        #expect(spy.emittedOutputs == [.didSubmit(reportId: "ABC123")])
    }

    @Test("Sending before the report is built is ignored")
    func sendBeforeBuildIsIgnored() async {
        let sut = makeStore()

        sut.send(.sendTapped)
        await sut.finish()

        #expect(spy.submitCallCount == 0)
        #expect(spy.emittedOutputs.isEmpty)
    }
}
