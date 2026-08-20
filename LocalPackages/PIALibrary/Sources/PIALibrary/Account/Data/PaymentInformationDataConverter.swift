import Foundation

protocol PaymentInformationDataConverterType: Sendable {
    func callAsFunction(payment: Payment) -> Data?
}

final class PaymentInformationDataConverter: PaymentInformationDataConverterType, JSONToStringCoverterType {

    func callAsFunction(payment: Payment) -> Data? {
        let paymentInformation = PaymentInformation(
            store: "apple_app_store",
            receipt: payment.receipt.value,
            marketing: stringify(json: payment.marketing, prettyPrinted: false),
            debug: stringify(json: payment.debug, prettyPrinted: false)
        )

        return paymentInformation.toData()
    }
}
