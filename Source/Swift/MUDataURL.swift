import UIKit

@objcMembers
public class MUDataURL: NSObject {
    public static func data(from dataURL: String) -> Data? {
        guard dataURL.hasPrefix("data:") else { return nil }
        let afterPrefix = dataURL.dropFirst(5)
        guard let semicolon = afterPrefix.firstIndex(of: ";") else { return nil }
        let rest = afterPrefix[semicolon...]
        let base64Token = ";base64,"
        guard rest.hasPrefix(base64Token) else { return nil }
        let base64Part = rest.dropFirst(base64Token.count)
        let decodedString = base64Part.removingPercentEncoding?.replacingOccurrences(of: " ", with: "") ?? String(base64Part)
        return Data(base64Encoded: decodedString)
    }

    public static func image(from dataURL: String) -> UIImage? {
        guard let data = self.data(from: dataURL) else { return nil }
        return UIImage(data: data)
    }
}
