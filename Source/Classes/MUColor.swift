import UIKit

@objc class MUColor: NSObject {
    @objc class func selectedTextColor() -> UIColor {
        return UIColor(red: 0x5d/255.0, green: 0x5d/255.0, blue: 0x5d/255.0, alpha: 1.0)
    }

    @objc class func goodPingColor() -> UIColor {
        return UIColor(red: 0x60/255.0, green: 0x9a/255.0, blue: 0x4b/255.0, alpha: 1.0)
    }

    @objc class func mediumPingColor() -> UIColor {
        return UIColor(red: 0xf2/255.0, green: 0xde/255.0, blue: 0x69/255.0, alpha: 1.0)
    }

    @objc class func badPingColor() -> UIColor {
        return UIColor(red: 0xd1/255.0, green: 0x4d/255.0, blue: 0x54/255.0, alpha: 1.0)
    }

    @objc class func userCountColor() -> UIColor {
        return UIColor.darkGray
    }

    @objc class func verifiedCertificateChainColor() -> UIColor {
        return UIColor(red: 0xdf/255.0, green: 1.0, blue: 0xdf/255.0, alpha: 1.0)
    }

    @objc class func backgroundViewiOS7Color() -> UIColor {
        return UIColor(red: 0x1C/255.0, green: 0x1C/255.0, blue: 0x1C/255.0, alpha: 1.0)
    }
}
