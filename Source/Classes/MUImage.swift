import UIKit

@objc class MUImage: NSObject {
    @objc class func tableViewCellImageFromImage(_ srcImage: UIImage) -> UIImage {
        let scale = UIScreen.main.scale
        let scaledWidth = srcImage.size.width * (44.0 / srcImage.size.height)
        let rect = CGRect(x: 0, y: 0, width: scaledWidth, height: 44.0)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return srcImage
        }
        let radius: CGFloat = 10.0
        ctx.beginPath()
        ctx.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + radius))
        ctx.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - radius))
        ctx.addArc(center: CGPoint(x: rect.origin.x + radius, y: rect.origin.y + rect.size.height - radius), radius: radius, startAngle: .pi, endAngle: .pi / 2, clockwise: true)
        ctx.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        ctx.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        ctx.addLine(to: CGPoint(x: rect.origin.x + radius, y: rect.origin.y))
        ctx.addArc(center: CGPoint(x: rect.origin.x + radius, y: rect.origin.y + radius), radius: radius, startAngle: -.pi / 2, endAngle: .pi, clockwise: true)
        ctx.closePath()
        UIColor.black.set()
        ctx.fillPath()
        let alphaMask = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        guard let ctx2 = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return srcImage
        }
        if let mask = alphaMask?.cgImage {
            ctx2.clip(to: rect, mask: mask)
        }
        srcImage.draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage ?? srcImage
    }

    @objc class func imageNamed(_ imageName: String) -> UIImage? {
        let scale = UIScreen.main.scale
        let height = UIScreen.main.bounds.size.height
        if height == 568 && scale == 2 {
            let expectedFn = "\(imageName)-568h"
            if let attemptedImage = UIImage(named: expectedFn) {
                return attemptedImage
            }
        }
        return UIImage(named: imageName)
    }

    // clearColorImage returns a 1x1 clear color image
    // that can be used as a transparent background image
    // for UIKit APIs that force you to provide UIImages.
    @objc class func clearColorImage() -> UIImage {
        let fillRect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(fillRect.size)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.fill(fillRect)
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }
}

