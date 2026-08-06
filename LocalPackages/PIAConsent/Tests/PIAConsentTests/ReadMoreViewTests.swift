import Testing

@testable import PIAConsent

@Suite
struct ReadMoreViewTests {
    @Test @MainActor func bodyBuildsWithViewModel() {
        let view = ReadMoreView(viewModel: ReadMoreViewModel())

        _ = view.body
    }
}

@Suite
struct ReadMoreViewModelTests {
    @Test func exposesLegacyReadMoreCopy() {
        let viewModel = ReadMoreViewModel()

        #expect(viewModel.description.contains("Connection Attempt"))
        #expect(viewModel.closeAccessibilityLabel == "Close")
    }

    @Test func closeButtonWasTappedInvokesOnClose() {
        var closedCount = 0
        let viewModel = ReadMoreViewModel(onClose: { closedCount += 1 })

        viewModel.closeButtonWasTapped()

        #expect(closedCount == 1)
    }
}
