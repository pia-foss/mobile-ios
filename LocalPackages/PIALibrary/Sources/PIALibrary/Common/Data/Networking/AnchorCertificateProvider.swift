
import Foundation

class AnchorCertificateProvider {
    static func getAnchorCertificate() -> SecCertificate? {
        
#if SWIFT_PACKAGE
            let bundle = Bundle.module
#else
            let bundle = Bundle(for: NetworkRequestClient.self)
#endif
        
       guard let certURL = bundle.url(forResource: "PIA", withExtension: "der"),
             let certificateData = try? Data(contentsOf: certURL) as CFData else {
           NSLog("AccountAnchorCertificateProvider: could no find or encode contents of anchor cert")
           return nil
       }
        
        let caRef = SecCertificateCreateWithData(nil, certificateData)
        
        if caRef == nil {
            NSLog("AccountAnchorCertificateProvider: anchorCert, could not generate SecCertificate")
        }
        
        return caRef
    }
}
