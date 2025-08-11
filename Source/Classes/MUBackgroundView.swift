import UIKit

@objcMembers
class MUBackgroundView: UIView {
    @objc class func backgroundView() -> UIView {
        if #available(iOS 7, *) {
            let view = UIView()
            view.backgroundColor = MUColor.backgroundViewiOS7Color()
            return view
        } else {
            return UIImageView(image: MUImage.imageNamed("BackgroundTextureBlackGradient"))
        }
    }
}
