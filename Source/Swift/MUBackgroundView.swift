import UIKit

@objcMembers
public class MUBackgroundView: UIView {
    public static func backgroundView() -> UIView {
        if MUGetOperatingSystemVersion().rawValue >= MUOperatingSystemVersion.iOS7.rawValue {
            let view = UIView()
            view.backgroundColor = MUColor.backgroundViewiOS7Color()
            return view
        }
        return UIImageView(image: MUImage.imageNamed("BackgroundTextureBlackGradient"))
    }
}
