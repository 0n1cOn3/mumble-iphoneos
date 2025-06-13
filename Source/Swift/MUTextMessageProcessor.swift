import Foundation

@objcMembers
public class MUTextMessageProcessor: NSObject {
    @objc(processedHTMLFromPlainTextMessage:)
    public static func processedHTML(fromPlainTextMessage plain: String) -> String? {
        var str = plain.replacingOccurrences(of: "<", with: "&lt;")
        str = str.replacingOccurrences(of: ">", with: "&gt;")

        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            var output = "<p>"
            let nsStr = str as NSString
            let matches = detector.matches(in: str, options: [], range: NSRange(location: 0, length: nsStr.length))
            var lastIndex = 0
            for match in matches {
                let urlRange = match.range
                let beforeRange = NSRange(location: lastIndex, length: urlRange.location - lastIndex)
                output += nsStr.substring(with: beforeRange)
                let url = nsStr.substring(with: urlRange)
                output += "<a href=\"\(url)\">\(url)</a>"
                lastIndex = urlRange.location + urlRange.length
            }
            output += nsStr.substring(from: lastIndex)
            output += "</p>"
            return output
        }
        return "<p>\(str)</p>"
    }
}
