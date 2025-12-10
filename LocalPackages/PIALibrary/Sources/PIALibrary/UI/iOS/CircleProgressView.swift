//
//  CircleProgressView.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 11/30/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
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
            anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
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
