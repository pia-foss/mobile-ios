import PIALocalizations
import Testing

@testable import PIAConsent

@Suite
struct ConsentViewModelTests {
    @Test func exposesLegacyPanelCopy() {
        let viewModel = ConsentViewModel()

        #expect(viewModel.title == L10n.Signup.Share.Data.Text.title)
        #expect(viewModel.message == L10n.Signup.Share.Data.Text.description)
        #expect(viewModel.footer == L10n.Signup.Share.Data.Text.footer)
        #expect(viewModel.readMoreTitle == L10n.Signup.Share.Data.Buttons.readMore)
        #expect(viewModel.acceptTitle == L10n.Signup.Share.Data.Buttons.accept.uppercased())
        #expect(viewModel.noThanksTitle == L10n.Signup.Share.Data.Buttons.noThanks.uppercased())
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
