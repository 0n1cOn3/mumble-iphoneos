import UIKit

@objcMembers
public class MUHorizontalFlipTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        containerView.addSubview(fromVC.view)
        containerView.addSubview(toVC.view)
        let option: UIView.AnimationOptions = (toVC.presentedViewController == fromVC) ? .transitionFlipFromLeft : .transitionFlipFromRight
        UIView.transition(from: fromVC.view,
                          to: toVC.view,
                          duration: transitionDuration(using: transitionContext),
                          options: option) { _ in
            transitionContext.completeTransition(true)
        }
    }
}
