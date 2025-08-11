import UIKit

@objc class MUHorizontalFlipTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    @objc func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    @objc func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }

    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)

        let option: UIView.AnimationOptions = (toViewController.presentedViewController == fromViewController) ? .transitionFlipFromLeft : .transitionFlipFromRight
        UIView.transition(from: fromViewController.view,
                          to: toViewController.view,
                          duration: transitionDuration(using: transitionContext),
                          options: option) { _ in
            transitionContext.completeTransition(true)
        }
    }
}
