import XCTest
import PIALibrary
@testable import PIA_VPN

class AccountInformationAvailabilityVerifierTests: XCTestCase {
    class Fixture {
        let accountProviderMock = AccountProviderMock()
        let notificationCenterMock = NotificationCenterMock()
        let userDefaultsMock = UserDefaultsMock(suiteName: "accountInfoAvailabilityTests")!
        let twelveHoursInSeconds: TimeInterval = 43200
        
        func stubAccountInformationAvailabilityChecked(on date: Date) {
            userDefaultsMock.dateResult = date
        }
        
    }
    
    var fixture: Fixture!
    var sut: AccountInformationAvailabilityVerifier!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func getDateForHoursAgo(_ hoursAgo: Double) -> Date {
        let now = Date()
        let hoursAgoInSeconds = ((hoursAgo * 60) * 60)
        return Date(timeInterval: -hoursAgoInSeconds, since: now)
    }
    
    private func instantiateSut() {
        sut = AccountInformationAvailabilityVerifier(accountProvider: fixture.accountProviderMock, notificationCenter: fixture.notificationCenterMock, userDefaults: fixture.userDefaultsMock)
    }
    
    func test_verifyAccountInformationAvailabilityAfterDeadline() async {
        // GIVEN that the account information has been checked 12 hours ago
        fixture.stubAccountInformationAvailabilityChecked(on: getDateForHoursAgo(12))
        
        instantiateSut()
        
        let now = Date()
        // WHEN calling to verify the account information after the default deadline (12 hours)
        await sut.verifyAccountInformationAvailabity(after: fixture.twelveHoursInSeconds)

        // THEN the account provider is called to retrieve the information
        XCTAssertEqual(fixture.accountProviderMock.accountInformationCalledAttempt, 1)
        
        // AND the UserDafaults is called to update the date of the account information verification
        XCTAssertEqual(fixture.userDefaultsMock.setDateAttempt, 1)
        let setDateForKey = fixture.userDefaultsMock.setDateCalledWithArguments?.key
        let setDateWithDate = fixture.userDefaultsMock.setDateCalledWithArguments?.date
        
        XCTAssertEqual(setDateForKey, "kAccountInfoAvailabilityDate")
        let isIntheSameMinute = Calendar.current.compare(setDateWithDate ?? Date(), to: now, toGranularity: .minute)
        XCTAssertEqual(isIntheSameMinute, ComparisonResult.orderedSame)
        
        // AND No Notification is posted
        XCTAssertEqual(fixture.notificationCenterMock.postNotificationCalledAttempt, 0)
        
        
    }
    
    func test_verifyAccountInformationAvailabilityBeforeDeadline() async {
        // GIVEN that the account information has been checked 11 hours ago
        fixture.stubAccountInformationAvailabilityChecked(on: getDateForHoursAgo(11))
        
        instantiateSut()
        
        // WHEN calling to verify the account information after the default deadline (12 hours)
        await sut.verifyAccountInformationAvailabity(after: fixture.twelveHoursInSeconds)

        // THEN the account provider is NOT called to retrieve the information
        XCTAssertEqual(fixture.accountProviderMock.accountInformationCalledAttempt, 0)
        
        // AND the UserDafaults is NOT called to update the date of the account information verification
        XCTAssertEqual(fixture.userDefaultsMock.setDateAttempt, 0)
        
        // AND No Notification is posted
        XCTAssertEqual(fixture.notificationCenterMock.postNotificationCalledAttempt, 0)
        
    }
    
    func test_verifyAccountInformationAvailabilityWithoutDeadline() async {
        // GIVEN that the account information has been checked 11 hours ago
        fixture.stubAccountInformationAvailabilityChecked(on: getDateForHoursAgo(11))
        
        instantiateSut()
        
        // WHEN calling to verify the account information without any deadline
        await sut.verifyAccountInformationAvailabity(after: nil)

        // THEN the account provider is called to retrieve the information
        XCTAssertEqual(fixture.accountProviderMock.accountInformationCalledAttempt, 1)
        
        // AND the UserDafaults is called to update the date of the account information verification
        XCTAssertEqual(fixture.userDefaultsMock.setDateAttempt, 1)
        
        // AND No Notification is posted
        XCTAssertEqual(fixture.notificationCenterMock.postNotificationCalledAttempt, 0)
        
    }
    
    func test_verifyAccountInformationAvailabilityWhenUnAuthorizedError() async {
        // GIVEN that there is an 'unauthorized' error when checking the account information
        fixture.accountProviderMock.accountInformationError = ClientError.unauthorized
        
        instantiateSut()
        
        // WHEN calling to verify the account information
        await sut.verifyAccountInformationAvailabity(after: nil)

        // THEN the account provider is called to retrieve the information
        XCTAssertEqual(fixture.accountProviderMock.accountInformationCalledAttempt, 1)
        
        // AND the `PIAUnauthorized` Notification is posted
        XCTAssertEqual(fixture.notificationCenterMock.postNotificationCalledAttempt, 1)
        XCTAssertEqual(fixture.notificationCenterMock.postNotificationCalledWithName, Notification.Name.PIAUnauthorized)
        
        // AND the UserDafaults is NOT called to update anything
        XCTAssertEqual(fixture.userDefaultsMock.setDateAttempt, 0)
        
    }
    
}
