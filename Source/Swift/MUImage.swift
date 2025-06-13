import UIKit

@objcMembers
public class MUImage: NSObject {
    public static func tableViewCellImage(from srcImage: UIImage) -> UIImage {
        let scale = UIScreen.main.scale
        let scaledWidth = srcImage.size.width * (44.0 / srcImage.size.height)
        let rect = CGRect(x: 0, y: 0, width: scaledWidth, height: 44)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        let ctx = UIGraphicsGetCurrentContext()!
        let radius: CGFloat = 10
        ctx.beginPath()
        ctx.move(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        ctx.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - radius))
        ctx.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius, startAngle: .pi, endAngle: .pi/2, clockwise: true)
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        ctx.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        ctx.addLine(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        ctx.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius, startAngle: -.pi/2, endAngle: .pi, clockwise: true)
        ctx.closePath()
        UIColor.black.setFill()
        ctx.fillPath()
        let alphaMask = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        let ctx2 = UIGraphicsGetCurrentContext()!
        ctx2.clip(to: rect, mask: alphaMask.cgImage!)
        srcImage.draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return scaledImage
    }

    public static func imageNamed(_ imageName: String) -> UIImage? {
        let scale = UIScreen.main.scale
        let height = UIScreen.main.bounds.size.height
        if height == 568 && scale == 2 {
            let expected = "\(imageName)-568h"
            if let attempted = UIImage(named: expected) {
                return attempted
            }
        }
        return UIImage(named: imageName)
    }

    public static func clearColorImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}
