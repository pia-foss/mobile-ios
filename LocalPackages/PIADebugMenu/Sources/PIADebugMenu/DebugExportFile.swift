import CoreTransferable
import UniformTypeIdentifiers

@available(iOS 16, *)
struct DebugExportFile: Transferable {
    let content: String
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .plainText) { file in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(file.filename)
            try Data(file.content.utf8).write(to: url)
            return SentTransferredFile(url)
        }
    }
}
