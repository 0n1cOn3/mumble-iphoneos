import UIKit

@objc class MUDataURL: NSObject {
    // Read: data:<mimetype>;base64,<data>
    @objc class func dataFromDataURL(_ dataURL: String) -> Data? {
        guard dataURL.hasPrefix("data:") else { return nil }
        let mimeStr = String(dataURL.dropFirst(5))
        guard let semicolonIndex = mimeStr.firstIndex(of: ";") else { return nil }
        let mimeType = String(mimeStr[..<semicolonIndex])
        _ = mimeType
        let encodingStart = mimeStr.index(after: semicolonIndex)
        let expected = "base64,"
        guard mimeStr[encodingStart...].hasPrefix(expected) else { return nil }
        let dataStart = mimeStr.index(encodingStart, offsetBy: expected.count)
        var base64data = String(mimeStr[dataStart...])
        base64data = base64data.removingPercentEncoding ?? base64data
        base64data = base64data.replacingOccurrences(of: " ", with: "")
        return Data(base64Encoded: base64data)
    }

    @objc class func imageFromDataURL(_ dataURL: String) -> UIImage? {
        guard let data = MUDataURL.dataFromDataURL(dataURL) else { return nil }
        return UIImage(data: data)
    }
}

