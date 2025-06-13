import UIKit

@objcMembers
public class MUTableViewHeaderLabel: UILabel {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        font = UIFont.boldSystemFont(ofSize: 18)
        textColor = .white
        if MUGetOperatingSystemVersion().rawValue < MUOperatingSystemVersion.iOS7.rawValue {
            shadowColor = .darkGray
            shadowOffset = CGSize(width: 1.5, height: 1.5)
        }
        backgroundColor = .clear
        textAlignment = .center
    }

    public class func defaultHeaderHeight() -> CGFloat {
        return 44.0
    }

    public class func label(withText text: String?) -> MUTableViewHeaderLabel {
        let label = MUTableViewHeaderLabel()
        label.text = text
        return label
    }
}
