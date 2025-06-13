import UIKit

@objc(BadgeView)
class BadgeView: UILabel {
    @objc var value: Int = 0 {
        didSet {
            text = "\(value)"
            isHidden = value == 0
            invalidateIntrinsicContentSize()
        }
    }

    @objc var shadow: Bool = false {
        didSet {
            layer.shadowOpacity = shadow ? 0.5 : 0.0
            layer.shadowRadius = shadow ? 1.0 : 0.0
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowColor = UIColor.black.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        textAlignment = .center
        textColor = .white
        backgroundColor = .red
        font = .boldSystemFont(ofSize: 10)
        clipsToBounds = true
        isHidden = true
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += 10
        size.height = max(size.height, 18)
        return size
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
