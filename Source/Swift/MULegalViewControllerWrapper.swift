import UIKit

@objc(MULegalViewControllerWrapper)
class MULegalViewControllerWrapper: UIViewController {
    private let objcController = MULegalViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(objcController)
        objcController.view.frame = view.bounds
        objcController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(objcController.view)
        objcController.didMove(toParent: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        objcController.view.frame = view.bounds
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return objcController.supportedInterfaceOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return objcController.preferredInterfaceOrientationForPresentation
    }
}
