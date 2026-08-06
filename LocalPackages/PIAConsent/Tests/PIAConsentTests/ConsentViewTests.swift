import Testing

@testable import PIAConsent

@Suite
struct ConsentViewTests {
    @Test @MainActor func bodyBuildsWithViewModel() {
        let view = ConsentView(viewModel: ConsentViewModel())

        _ = view.body
    }
}

@Suite
struct ConsentViewModelTests {
    @Test func exposesLegacyPanelCopy() {
        let viewModel = ConsentViewModel()

        #expect(viewModel.title == "Please help us improve our service")
        #expect(
            viewModel.message
                == "To help us ensure our service's connection performance, you can anonymously share your connection stats with us. These reports do not include any personally identifiable information."
        )
        #expect(viewModel.footer == "You can always control this from your settings")
        #expect(viewModel.readMoreTitle == "Read more")
        #expect(viewModel.acceptTitle == "ACCEPT")
        #expect(viewModel.noThanksTitle == "NO, THANKS")
    }

    @Test func acceptButtonWasTappedInvokesOnAccept() {
        var acceptedCount = 0
        let viewModel = ConsentViewModel(onAccept: { acceptedCount += 1 })

        viewModel.acceptButtonWasTapped()

        #expect(acceptedCount == 1)
    }

    @Test func noThanksButtonWasTappedInvokesOnReject() {
        var rejectedCount = 0
        let viewModel = ConsentViewModel(onReject: { rejectedCount += 1 })

        viewModel.noThanksButtonWasTapped()

        #expect(rejectedCount == 1)
    }
}
