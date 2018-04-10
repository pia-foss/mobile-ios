//
//  CircleProgressView.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 11/30/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

/// Displays a group of concentric spinning circles indicating indeterminate progress.
public class CircleProgressView: UIView {
    private lazy var outerArc = CAShapeLayer()

    private lazy var innerArc = CAShapeLayer()

    private lazy var fixedCircle = CAShapeLayer()

    /// The color of the outer spinning circle.
    public var outerColor: UIColor? = .gray {
        didSet {
            outerArc.strokeColor = outerColor?.cgColor
            setNeedsDisplay()
        }
    }

    /// The color of the inner spinning circle.
    public var innerColor: UIColor? = .black {
        didSet {
            innerArc.strokeColor = innerColor?.cgColor
            setNeedsDisplay()
        }
    }
    
    /// The color of the fixed circle.
    public var fixedColor: UIColor? = .green {
        didSet {
            fixedCircle.fillColor = fixedColor?.cgColor
            setNeedsDisplay()
        }
    }
    
    /// The thickness of the spinning circles in points.
    public var thickness: CGFloat = 5.0 {
        didSet {
            outerArc.lineWidth = thickness
            innerArc.lineWidth = thickness
            setNeedsDisplay()
        }
    }
    
    /// :nodoc:
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        let rect = bounds
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = rect.width / 2.0 - thickness
        let outerRadius = maxRadius
        let innerRadius = 0.75 * maxRadius
        let fixedRadius = 0.35 * maxRadius
        let fixedInsetX = (rect.width - 2.0 * fixedRadius) / 2.0
        let fixedInsetY = (rect.height - 2.0 * fixedRadius) / 2.0

        outerArc.path = UIBezierPath(
            arcCenter: .zero,
            radius: outerRadius,
            startAngle: 0.0,
            endAngle: .pi / 2.0,
            clockwise: false
        ).cgPath
        outerArc.strokeColor = outerColor?.cgColor
        outerArc.fillColor = nil
        outerArc.lineWidth = thickness
        outerArc.position = center

        innerArc.path = UIBezierPath(
            arcCenter: .zero,
            radius: innerRadius,
            startAngle: .pi * 3.0 / 2.0,
            endAngle: 0.0,
            clockwise: false
        ).cgPath
        innerArc.strokeColor = innerColor?.cgColor
        innerArc.fillColor = nil
        innerArc.lineWidth = thickness
        innerArc.position = center

        fixedCircle.path = UIBezierPath(
            ovalIn: bounds.insetBy(dx: fixedInsetX, dy: fixedInsetY)
        ).cgPath
        fixedCircle.fillColor = fixedColor?.cgColor

        layer.addSublayer(outerArc)
        layer.addSublayer(innerArc)
        layer.addSublayer(fixedCircle)
    }

    /**
     Starts the spinning circles animation.
     */
    public func startAnimating() {
        let angle: CGFloat = .pi * 2.0

        CATransaction.begin()
        let outerRotation = CABasicAnimation(keyPath: "transform.rotation")
        let innerRotation = CABasicAnimation(keyPath: "transform.rotation")

        for anim: CABasicAnimation in [outerRotation, innerRotation] {
            anim.duration = 3.0
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            anim.repeatCount = .infinity
//            anim.autoreverses = true
        }

        outerRotation.fromValue = 0.0
        outerRotation.toValue = angle
        innerRotation.fromValue = 0.0
        innerRotation.toValue = -angle

        outerArc.add(outerRotation, forKey: "rotation")
        innerArc.add(innerRotation, forKey: "rotation")
        CATransaction.commit()
    }
}
