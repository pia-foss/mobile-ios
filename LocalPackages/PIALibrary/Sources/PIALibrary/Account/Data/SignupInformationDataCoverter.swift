
import Foundation

class SignupInformationDataCoverter: SignupInformationDataCoverterType {
    func callAsFunction(signup: Signup) -> Data? {
        let signupInformation = SignupInformation(store: "apple_app_store",
                                                  receipt: signup.receipt.base64EncodedString(),
                                                  email: signup.email,
                                                  marketing: stringify(json: signup.marketing, prettyPrinted: false),
                                                  debug: stringify(json: signup.debug, prettyPrinted: false))
        
        return signupInformation.toData()
    }
}

extension SignupInformationDataCoverter: JSONToStringCoverterType {}
