//
//  FMZoomOutAnimationController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/26.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMZoomOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var interactionInProgress = false
    
    var getDestFrame: (() -> CGRect)!
    
    let interactionController: FMPhotoInteractionAnimator?
    
    init(interactionController: FMPhotoInteractionAnimator?) {
        self.interactionController = interactionController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? FMPhotoPresenterViewController,
            let toVC = transitionContext.viewController(forKey: .to),
            let photoVC = fromVC.pageViewController.viewControllers?.first as? FMPhotoViewController
            else {
                return
        }
        
        let snapshot = photoVC.scalingImageView.imageView.ins_snapshotView()
        let containerView = transitionContext.containerView
        
        let pannedVector = fromVC.pageViewController.view.frame.origin
        containerView.addSubview(snapshot)
        snapshot.frame = CGRect(x: 0, y: 0, width: photoVC.scalingImageView.imageView.frame.width, height: photoVC.scalingImageView.imageView.frame.height)
        snapshot.center =  containerView.center
        snapshot.frame = CGRect(origin: CGPoint(x: snapshot.frame.origin.x + pannedVector.x,
                                                y: snapshot.frame.origin.y + pannedVector.y),
                                size: snapshot.frame.size)
        
        fromVC.view.isHidden = true
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.9) {
                    snapshot.frame = self.realDestinationFrame(scaledFrame: self.getDestFrame(), realSize: snapshot.frame.size)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                    snapshot.alpha = 0.0
                }
        },
            completion: { _ in
                fromVC.view.isHidden = false
                snapshot.removeFromSuperview()
                if transitionContext.transitionWasCancelled {
                    toVC.view.removeFromSuperview()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    private func realDestinationFrame(scaledFrame: CGRect, realSize: CGSize) -> CGRect {
        let scaledSize = scaledFrame.size
        let ratio = realSize.width / realSize.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var width: CGFloat = scaledSize.width
        var height: CGFloat = scaledSize.height
        
        if ratio >= 1 {
            let scaleRatio = scaledSize.height / realSize.height
            width = realSize.width * scaleRatio
            x = -(width - scaledSize.width) / 2
        } else {
            let scaleRatio = scaledSize.width / realSize.width
            height = realSize.height * scaleRatio
            y = -(height - scaledSize.height) / 2
        }
        
        let frame = CGRect(x: scaledFrame.origin.x + x,
                           y: scaledFrame.origin.y + y,
                           width: width,
                           height: height)
        return frame
    }
}

