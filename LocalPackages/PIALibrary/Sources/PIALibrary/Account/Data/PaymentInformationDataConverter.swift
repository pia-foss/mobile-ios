
import Foundation

protocol PaymentInformationDataConverterType {
    func callAsFunction(payment: Payment) -> Data?
}

class PaymentInformationDataConverter: PaymentInformationDataConverterType, JSONToStringCoverterType {

    func callAsFunction(payment: Payment) -> Data? {
        let paymentInformation = PaymentInformation(
            store: "apple_app_store", 
            receipt: payment.receipt.base64EncodedString(),
            marketing: stringify(json: payment.marketing, prettyPrinted: false),
            debug: stringify(json: payment.debug, prettyPrinted: false)
        )
        
        return paymentInformation.toData()
    }
}


