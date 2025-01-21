//
//  CarPlayNavigationStyleKit.swift
//  ProjectName
//
//  Created by Nicholas Hubbard on 1/20/25.
//  Copyright © 2025 Zed Said Studio LLC. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import UIKit

public class CarPlayNavigationStyleKit : NSObject {

    //// Drawing Methods

    @objc dynamic public class func drawUserLocationPuckFollowing(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 40, height: 40), resizing: ResizingBehavior = .aspectFit, puckArrowColor: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000), puckBorderColor: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000), puckColor: UIColor = UIColor(red: 0.241, green: 0.727, blue: 1.000, alpha: 1.000)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 40, height: 40), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 40, y: resizedFrame.height / 40)
        let resizedShadowScale: CGFloat = min(resizedFrame.width / 40, resizedFrame.height / 40)



        //// Shadow Declarations
        let userLocationPuckShadow = NSShadow()
        userLocationPuckShadow.shadowColor = UIColor.black.withAlphaComponent(0.4)
        userLocationPuckShadow.shadowOffset = CGSize(width: 0, height: 0)
        userLocationPuckShadow.shadowBlurRadius = 5

        //// Group
        context.saveGState()
        context.translateBy(x: 20, y: 20)



        //// Location Puck Border Drawing
        let locationPuckBorderPath = UIBezierPath(ovalIn: CGRect(x: -14, y: -14, width: 28, height: 28))
        context.saveGState()
        context.setShadow(offset: CGSize(width: userLocationPuckShadow.shadowOffset.width * resizedShadowScale, height: userLocationPuckShadow.shadowOffset.height * resizedShadowScale), blur: userLocationPuckShadow.shadowBlurRadius * resizedShadowScale, color: (userLocationPuckShadow.shadowColor as! UIColor).cgColor)
        puckBorderColor.setFill()
        locationPuckBorderPath.fill()
        context.restoreGState()



        //// Location Puck Inside Drawing
        let locationPuckInsidePath = UIBezierPath(ovalIn: CGRect(x: -12, y: -12, width: 24, height: 24))
        puckColor.setFill()
        locationPuckInsidePath.fill()


        //// Location Arrow Drawing
        let locationArrowPath = UIBezierPath()
        locationArrowPath.move(to: CGPoint(x: -5.49, y: 7.5))
        locationArrowPath.addCurve(to: CGPoint(x: -4.26, y: 6.91), controlPoint1: CGPoint(x: -5.02, y: 7.5), controlPoint2: CGPoint(x: -4.73, y: 7.34))
        locationArrowPath.addLine(to: CGPoint(x: 0.05, y: 2.87))
        locationArrowPath.addCurve(to: CGPoint(x: 0.18, y: 2.8), controlPoint1: CGPoint(x: 0.09, y: 2.83), controlPoint2: CGPoint(x: 0.13, y: 2.8))
        locationArrowPath.addCurve(to: CGPoint(x: 0.3, y: 2.87), controlPoint1: CGPoint(x: 0.22, y: 2.8), controlPoint2: CGPoint(x: 0.26, y: 2.83))
        locationArrowPath.addLine(to: CGPoint(x: 4.61, y: 6.91))
        locationArrowPath.addCurve(to: CGPoint(x: 5.84, y: 7.5), controlPoint1: CGPoint(x: 5.08, y: 7.34), controlPoint2: CGPoint(x: 5.37, y: 7.5))
        locationArrowPath.addCurve(to: CGPoint(x: 6.85, y: 6.44), controlPoint1: CGPoint(x: 6.47, y: 7.5), controlPoint2: CGPoint(x: 6.85, y: 7.04))
        locationArrowPath.addCurve(to: CGPoint(x: 6.55, y: 5.32), controlPoint1: CGPoint(x: 6.85, y: 6.11), controlPoint2: CGPoint(x: 6.7, y: 5.7))
        locationArrowPath.addLine(to: CGPoint(x: 1.43, y: -7.88))
        locationArrowPath.addCurve(to: CGPoint(x: 0.18, y: -9), controlPoint1: CGPoint(x: 1.13, y: -8.65), controlPoint2: CGPoint(x: 0.69, y: -9))
        locationArrowPath.addCurve(to: CGPoint(x: -1.08, y: -7.88), controlPoint1: CGPoint(x: -0.35, y: -9), controlPoint2: CGPoint(x: -0.78, y: -8.65))
        locationArrowPath.addLine(to: CGPoint(x: -6.2, y: 5.32))
        locationArrowPath.addCurve(to: CGPoint(x: -6.5, y: 6.44), controlPoint1: CGPoint(x: -6.35, y: 5.7), controlPoint2: CGPoint(x: -6.5, y: 6.11))
        locationArrowPath.addCurve(to: CGPoint(x: -5.49, y: 7.5), controlPoint1: CGPoint(x: -6.5, y: 7.04), controlPoint2: CGPoint(x: -6.12, y: 7.5))
        locationArrowPath.close()
        puckArrowColor.setFill()
        locationArrowPath.fill()



        context.restoreGState()
        
        context.restoreGState()

    }

    @objc dynamic public class func drawUserLocationPuck(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 40, height: 40), resizing: ResizingBehavior = .aspectFit, puckBorderColor: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000), puckColor: UIColor = UIColor(red: 0.241, green: 0.727, blue: 1.000, alpha: 1.000)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 40, height: 40), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 40, y: resizedFrame.height / 40)
        let resizedShadowScale: CGFloat = min(resizedFrame.width / 40, resizedFrame.height / 40)



        //// Shadow Declarations
        let userLocationPuckShadow = NSShadow()
        userLocationPuckShadow.shadowColor = UIColor.black.withAlphaComponent(0.4)
        userLocationPuckShadow.shadowOffset = CGSize(width: 0, height: 0)
        userLocationPuckShadow.shadowBlurRadius = 5

        //// Group
        context.saveGState()
        context.translateBy(x: 20, y: 20)



        //// Location Puck Border Drawing
        let locationPuckBorderPath = UIBezierPath(ovalIn: CGRect(x: -12, y: -12, width: 24, height: 24))
        context.saveGState()
        context.setShadow(offset: CGSize(width: userLocationPuckShadow.shadowOffset.width * resizedShadowScale, height: userLocationPuckShadow.shadowOffset.height * resizedShadowScale), blur: userLocationPuckShadow.shadowBlurRadius * resizedShadowScale, color: (userLocationPuckShadow.shadowColor as! UIColor).cgColor)
        puckBorderColor.setFill()
        locationPuckBorderPath.fill()
        context.restoreGState()



        //// Location Puck Inside Drawing
        let locationPuckInsidePath = UIBezierPath(ovalIn: CGRect(x: -9, y: -9, width: 18, height: 18))
        puckColor.setFill()
        locationPuckInsidePath.fill()



        context.restoreGState()
        
        context.restoreGState()

    }

    //// Generated Images

    @objc dynamic public class func imageOfUserLocationPuckFollowing(puckArrowColor: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000), puckBorderColor: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000), puckColor: UIColor = UIColor(red: 0.241, green: 0.727, blue: 1.000, alpha: 1.000)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 40, height: 40), false, 0)
            CarPlayNavigationStyleKit.drawUserLocationPuckFollowing(puckArrowColor: puckArrowColor, puckBorderColor: puckBorderColor, puckColor: puckColor)

        let imageOfUserLocationPuckFollowing = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfUserLocationPuckFollowing
    }

    @objc dynamic public class func imageOfUserLocationPuck(puckBorderColor: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000), puckColor: UIColor = UIColor(red: 0.241, green: 0.727, blue: 1.000, alpha: 1.000)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 40, height: 40), false, 0)
            CarPlayNavigationStyleKit.drawUserLocationPuck(puckBorderColor: puckBorderColor, puckColor: puckColor)

        let imageOfUserLocationPuck = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfUserLocationPuck
    }




    @objc(CarPlayNavigationStyleKitResizingBehavior)
    public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
