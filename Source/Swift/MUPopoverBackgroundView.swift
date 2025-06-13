import UIKit

@objc(MUPopoverBackgroundView)
public class MUPopoverBackgroundView: UIPopoverBackgroundView {
    private let imageView: UIImageView

    public override init(frame: CGRect) {
        self.imageView = UIImageView()
        super.init(frame: frame)
        setupImage()
    }

    required init?(coder: NSCoder) {
        self.imageView = UIImageView()
        super.init(coder: coder)
        setupImage()
    }

    private func setupImage() {
        let insets = UIEdgeInsets(top: 41, left: 47, bottom: 10, right: 10)
        if let img = UIImage(named: "_UIPopoverViewBlackBackgroundArrowUp") {
            imageView.image = img.resizableImage(withCapInsets: insets)
        }
        addSubview(imageView)
    }

    public override var arrowDirection: UIPopoverArrowDirection {
        get { .up }
        set { }
    }

    public override var arrowOffset: CGFloat {
        get { 0.0 }
        set { }
    }

    public override class func arrowBase() -> CGFloat { 35.0 }
    public override class func arrowHeight() -> CGFloat { 19.0 }
    public override class func contentViewInsets() -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 11, bottom: 11, right: 11)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = frame
    }
}
