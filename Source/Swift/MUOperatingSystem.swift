import UIKit

@objc public enum MUOperatingSystemVersion: Int {
    case unknown
    case iOS5
    case iOS6
    case iOS7
}

@objc(MUGetOperatingSystemVersion)
public func MUGetOperatingSystemVersion() -> MUOperatingSystemVersion {
    let versionString = UIDevice.current.systemVersion
    if let major = Int(versionString.split(separator: ".").first ?? "") ) {
        switch major {
        case 5: return .iOS5
        case 6: return .iOS6
        case 7: return .iOS7
        default:
            if major > 7 {
                return .iOS7
            }
        }
    }
    return .unknown
}
