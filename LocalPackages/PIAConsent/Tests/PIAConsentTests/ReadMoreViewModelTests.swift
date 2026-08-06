import PIALocalizations
import Testing

@testable import PIAConsent

@Suite
struct ReadMoreViewModelTests {
    @Test func exposesLegacyReadMoreCopy() {
        let viewModel = ReadMoreViewModel()

        #expect(viewModel.description == L10n.Signup.Share.Data.ReadMore.Text.description)
        #expect(viewModel.closeAccessibilityLabel == L10n.Global.close)
    }

    @Test func closeButtonWasTappedInvokesOnClose() {
        var closedCount = 0
        let viewModel = ReadMoreViewModel(onClose: { closedCount += 1 })

        viewModel.closeButtonWasTapped()

        #expect(closedCount == 1)
    }
}
