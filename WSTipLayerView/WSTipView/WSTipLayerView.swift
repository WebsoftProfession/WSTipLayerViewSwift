//
//  WSTipLayerView.swift
//  WSTipLayerView
//
//  Created by WebsoftProfession on 23/08/22.
//

import Foundation
import UIKit

public enum WSTipArrowStyle {
    case CenterTop
    case CenterBottom
};

public protocol WSTipLayerViewDelegate: NSObject {
    
    //required
    func numberOfTips() -> Int
    func viewForTipAtIndex(index: Int) -> UIView
    func messageForTipAtIndex(index: Int) -> String
    func tipArrowStyleForTipAtIndex(index: Int) -> WSTipArrowStyle
    
    //optional
    func didTapOnTipIndex(index: Int)
    func attributesForTipViewMessageAtIndex(index: Int) ->[NSAttributedString.Key: Any]
}

public extension WSTipLayerViewDelegate {
    
    func didTapOnTipIndex(index: Int) {
        
    }
    func attributesForTipViewMessageAtIndex(index: Int) ->[NSAttributedString.Key: Any] {
        return [:]
    }
}

public class WSTipLayerView: UIView {
    var layerImage:UIImage?
    public weak var tipDelegate:WSTipLayerViewDelegate?
    var shadowColor:UIColor?;
    var arrowColor:UIColor?;
    var tipViewIndex:Int = 0
    
    
    public func showWSTipView() {
        if self.tipDelegate != nil {
            let controller = self.tipDelegate as! UIViewController;
            if let image = self.getLayerImageOfController(controller: controller) {
                layerImage = image
            }
            self.setupInitialPropertiesOnController(controller: controller)
        }
    }
    
    func getLayerImageOfController(controller: UIViewController) -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(controller.view.frame.size, false, UIScreen.main.scale);
        let rect = CGRect(x:0, y:0, width:controller.view.frame.size.width, height:controller.view.frame.size.height)
        controller.view.drawHierarchy(in: rect, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    func setupInitialPropertiesOnController(controller: UIViewController) {
        self.frame = UIScreen.main.bounds;
        self.backgroundColor = UIColor.clear
        if self.shadowColor == nil {
            self.shadowColor = UIColor.white
        }
        
        if self.arrowColor == nil {
            self.arrowColor = UIColor.white
        }
        if self.superview == nil {
            controller.view.addSubview(self)
        }
    }
    
    
    
    
    public override func draw(_ rect: CGRect) {
        // Drawing code
        
        let backgroundPath = UIBezierPath.init(rect: rect)
        let view = self.tipDelegate?.viewForTipAtIndex(index: tipViewIndex)
        let controller = self.tipDelegate as! UIViewController
//        let frame = controller.view.convert(view!.frame, to: view?.superview)
        let frame = controller.view.convert(view!.frame, from: view?.superview)
        let buttonPath = UIBezierPath.init(rect: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height))
        backgroundPath.append(buttonPath)
        backgroundPath.usesEvenOddFillRule = true
        
        // draw shadow
        self.drawShadowForFrame(frame: frame)
        
        UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).setFill()
        backgroundPath.fill()
        buttonPath.lineWidth = 1.0
        self.shadowColor?.setStroke()
        buttonPath.stroke()
        
        // draw arrow
        self.drawArrowOfFrame(frame: frame, controller: controller, arrowStyle: (self.tipDelegate?.tipArrowStyleForTipAtIndex(index: tipViewIndex))!)
        
    }
    
    func drawShadowForFrame(frame:CGRect){
        
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                if layer === CAShapeLayer.self {
                    if layer.name == "Top" || layer.name == "Left" || layer.name == "Right" || layer.name == "Bottom" {
                        DispatchQueue.main.async {
                            layer.removeFromSuperlayer()
                        }
                    }
                }
            }
        }
        
        
        // Top
        self.layer.addSublayer(self.generateShadowLayer(name: "Top", frame: CGRect.init(x: frame.origin.x, y: frame.origin.y-2, width: frame.size.width, height: 2), shadowOffset: CGSize.init(width: 0, height: -3)))
        
        // Left
        self.layer.addSublayer(self.generateShadowLayer(name: "Left", frame: CGRect.init(x: frame.origin.x-2, y: frame.origin.y, width: 2, height: frame.size.height), shadowOffset: CGSize.init(width: -3, height: 0)))
        
        // Right
        self.layer.addSublayer(self.generateShadowLayer(name: "Right", frame: CGRect.init(x: frame.origin.x+frame.size.width, y: frame.origin.y, width: 2, height: frame.size.height), shadowOffset: CGSize.init(width: 3, height: 0)))
        
        //Bottom
        self.layer.addSublayer(self.generateShadowLayer(name: "Bottom", frame: CGRect.init(x: frame.origin.x, y: frame.origin.y+frame.size.height, width: frame.size.width, height: 2), shadowOffset: CGSize.init(width: 0, height: 3)))
    }
    
    func generateShadowLayer(name:String, frame:CGRect, shadowOffset:CGSize) -> CAShapeLayer {
        let shadowLayer = CAShapeLayer()
        shadowLayer.name = name;
        shadowLayer.shadowPath = UIBezierPath.init(rect: frame).cgPath
        shadowLayer.shadowColor = self.shadowColor?.cgColor;
        shadowLayer.shadowOffset = shadowOffset
        shadowLayer.shadowOpacity = 1.0;
        shadowLayer.shadowRadius = 3;
        shadowLayer.masksToBounds = false;
        return shadowLayer
    }
    
    
    func drawArrowOfFrame(frame: CGRect, controller:UIViewController, arrowStyle:WSTipArrowStyle) {
        
        let centerPoint = CGPoint.init(x: frame.origin.x+frame.size.width/2, y: frame.origin.y+frame.size.height/2)
        let movePointBottom = CGPoint.init(x: centerPoint.x, y: centerPoint.y+frame.size.height/2+10)
        let movePointTop = CGPoint.init(x: centerPoint.x, y: centerPoint.y-frame.size.height/2-10)
        let lineArrowPath = UIBezierPath.init()
        let lineArrowPath2 = UIBezierPath.init()
        let message = (self.tipDelegate?.messageForTipAtIndex(index: tipViewIndex))!
        switch arrowStyle {
        case .CenterTop:
            
            lineArrowPath.move(to: movePointTop)
            
            if (centerPoint.x<controller.view.center.x) {
                // Top Left
                
                let endPoint = CGPoint.init(x: centerPoint.x+20, y: movePointTop.y-50)
                lineArrowPath.addQuadCurve(to: endPoint, controlPoint: CGPoint.init(x: (movePointTop.x+endPoint.x)/2-25, y: (movePointTop.y+endPoint.y)/2))
                
                lineArrowPath2.move(to: CGPoint.init(x: movePointTop.x-10, y: movePointTop.y-5))
                lineArrowPath2.addLine(to: movePointTop)
                lineArrowPath2.addLine(to: CGPoint.init(x: movePointTop.x+5, y: movePointTop.y-5))
                lineArrowPath.append(lineArrowPath2)
                
                self.drawString(message: message, font: UIFont.init(name: "Arial", size: 17)!, contextRect: CGRect(x:controller.view.frame.origin.x+20, y: endPoint.y-10, width: controller.view.frame.size.width-40, height: 10), viewFrame: frame)
                
            }
            else{
                // Top Right
                let endPoint = CGPoint.init(x: centerPoint.x-20, y: movePointTop.y-50)
                lineArrowPath.addQuadCurve(to: endPoint, controlPoint: CGPoint.init(x: (movePointTop.x+endPoint.x)/2+25, y: (movePointTop.y+endPoint.y)/2))
                lineArrowPath2.move(to: CGPoint.init(x: movePointTop.x-5, y: movePointTop.y-5))
                lineArrowPath2.addLine(to: movePointTop)
                lineArrowPath2.addLine(to: CGPoint.init(x: movePointTop.x+10, y: movePointTop.y-5))
                lineArrowPath.append(lineArrowPath2)
                
                self.drawString(message: message, font: UIFont.init(name: "Arial", size: 17)!, contextRect: CGRect(x:controller.view.frame.origin.x+20, y: endPoint.y-10, width: controller.view.frame.size.width-40, height: 10), viewFrame: frame)
            }
            
        case .CenterBottom:
            lineArrowPath.move(to: movePointBottom)
            
            if (centerPoint.x<controller.view.center.x) {
                // Bottom Left
                
                let endPoint = CGPoint.init(x: centerPoint.x+20, y: centerPoint.y+frame.size.height/2+50)
                lineArrowPath.addQuadCurve(to: endPoint, controlPoint: CGPoint(x:(movePointBottom.x+endPoint.x)/2-25, y:(movePointBottom.y+endPoint.y)/2))
                lineArrowPath2.move(to: CGPoint(x:movePointBottom.x-10, y:movePointBottom.y+5))
                lineArrowPath2.addLine(to: movePointBottom)
                
                lineArrowPath2.addLine(to: CGPoint(x:movePointBottom.x+5, y:movePointBottom.y+5))
                lineArrowPath.append(lineArrowPath2)
                
                self.drawString(message: message, font: UIFont.init(name: "Arial", size: 17)!, contextRect: CGRect(x:controller.view.frame.origin.x+20, y: endPoint.y+10, width: controller.view.frame.size.width-40, height: 10), viewFrame: frame)
                
            }
            else{
                // Bottom Right
                
                let endPoint = CGPoint(x:centerPoint.x-20, y:centerPoint.y+frame.size.height/2+50);
                lineArrowPath.addQuadCurve(to: endPoint, controlPoint: CGPoint(x:(movePointBottom.x+endPoint.x)/2+25, y:(movePointBottom.y+endPoint.y)/2))
                lineArrowPath2.move(to: CGPoint(x:movePointBottom.x-5, y:movePointBottom.y+5))
                lineArrowPath2.addLine(to: movePointBottom)
                
                lineArrowPath2.addLine(to: CGPoint(x:movePointBottom.x+10, y:movePointBottom.y+5))
                lineArrowPath.append(lineArrowPath2)
                
                self.drawString(message: message, font: UIFont.init(name: "Arial", size: 17)!, contextRect: CGRect(x:controller.view.frame.origin.x+20, y:endPoint.y+10, width: controller.view.frame.size.width-40, height: 10), viewFrame: frame)
            }
        }
        
        self.arrowColor?.set()
        lineArrowPath.lineWidth = 2;
        lineArrowPath.lineCapStyle = .round
        lineArrowPath.stroke()
        
    }
    
    func drawString(message:String, font:UIFont, contextRect:CGRect, viewFrame:CGRect){
        /// Make a copy of the default paragraph style
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        /// Set line break mode
        paragraphStyle.lineBreakMode = .byWordWrapping;
        /// Set text alignment
        paragraphStyle.alignment = .left;
        var attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        if self.tipDelegate != nil {
            if self.tipDelegate!.responds(to: Selector(("attributesForTipViewMessageAtIndex:"))) {
                attributes = self.tipDelegate!.attributesForTipViewMessageAtIndex(index: tipViewIndex)
            }
        }
        
        let textHeight = self.heightFor(message: message as NSString, width: contextRect.size.width, attributes: attributes)
        var context = contextRect
        if self.tipDelegate?.tipArrowStyleForTipAtIndex(index: tipViewIndex) == .CenterBottom {
            context.size.height = textHeight;
        }
        else if self.tipDelegate?.tipArrowStyleForTipAtIndex(index: tipViewIndex) == .CenterTop {
            context.origin.y -= textHeight;
            context.size.height = textHeight;
        }
        (message as NSString).draw(in: context, withAttributes: attributes)
    }
    
    func heightFor(message:NSString, width:CGFloat, attributes: [NSAttributedString.Key:Any]) -> CGFloat {
        let textRect = message.boundingRect(with: CGSize(width:width, height:CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return textRect.size.height
    }
    
    
}

extension WSTipLayerView {
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)
            
            let view = self.tipDelegate?.viewForTipAtIndex(index: tipViewIndex)
            let controller = self.tipDelegate as! UIViewController
//            let frame = controller.view.convert(view!.frame, to: controller.view)
            let frame = controller.view.convert(view!.frame, from: view?.superview)
            if frame.contains(touchPoint) {
                self.tipDelegate?.didTapOnTipIndex(index: tipViewIndex)
                tipViewIndex += 1
                if tipViewIndex < self.tipDelegate!.numberOfTips() {
                    self.setNeedsDisplay()
                    return
                }
                self.removeFromSuperview()
                
                tipViewIndex = 0;
            }
        }
        
        
        
    }
}
