import UIKit

@objcMembers
class MUTableViewHeaderLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        font = UIFont.boldSystemFont(ofSize: 18.0)
        textColor = .white
        if #available(iOS 7, *) {
            // Don't use shadows on iOS 7 or greater.
        } else {
            shadowColor = .darkGray
            shadowOffset = CGSize(width: 1.5, height: 1.5)
        }
        backgroundColor = .clear
        textAlignment = .center
    }

    class func defaultHeaderHeight() -> CGFloat {
        return 44.0
    }

    class func label(withText text: String?) -> MUTableViewHeaderLabel {
        let label = MUTableViewHeaderLabel()
        label.text = text
        return label
    }
}
