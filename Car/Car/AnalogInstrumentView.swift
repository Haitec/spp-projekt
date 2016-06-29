//
//  AnalogInstrument.swift
//  Car
//
//  Created by michael on 03.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import UIKit

protocol AnalogInstrumentViewDataSource: class {
    /**
     Liefert für die Striche auf dem Instrument den passendend String
     - parameter sender: Absender der Anfrage
     - parameter LineNumber: Nummer der aktuellen Linie
     - returns: Text für die Linie
    */
    func textForLine(sender: AnalogInstrumentView, LineNumber: Int) -> String?
    
    /**
     Liefert den aktuellen Winkel für das Analog Instrument
     - parameter sender: Absender der Anfrage
     - returns: x: Winkel = (x*M_PI)
    */
    func arrowAngle(sender: AnalogInstrumentView) -> CGFloat
}

@IBDesignable class AnalogInstrumentView: UIView {

    
    private struct CONSTANTS {
        static let ANIM_DURATION = 0.5
        static let KEYPATH = "transform.rotation.z"
        static let TEXTRECTFAC = 0.3
        static let DISTANCEMULTIPLICATOR = 3.0
    }
    
    @IBInspectable var color1: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    @IBInspectable var colorDanger: UIColor = UIColor.redColor() { didSet { setNeedsDisplay() } }
    @IBInspectable var lineWidth: CGFloat = 3 { didSet { setNeedsDisplay() } }
    @IBInspectable var scale: CGFloat = 0.98 { didSet { setNeedsDisplay() } }
    @IBInspectable var LineLengthPercentBig: CGFloat = 0.08 { didSet { setNeedsDisplay() } }
    @IBInspectable var LineLengthPercentSmall: CGFloat = 0.05 { didSet { setNeedsDisplay() } }
    
    @IBInspectable var BigLineIncrease:CGFloat = 0.2 { didSet { setNeedsDisplay() } }
    @IBInspectable var SmallLineIncrease: CGFloat = 0.05 { didSet { setNeedsDisplay() } }
    
    @IBInspectable var arrowAngle: CGFloat = 0.8 { didSet { setNeedsDisplay() } }
    @IBInspectable var arrowLengthLongPercentage: CGFloat = 0.85 { didSet { setNeedsDisplay() } }
    @IBInspectable var arrowColor: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    
    @IBInspectable var startAngle: CGFloat = 0.8 { didSet { setNeedsDisplay() } }
    @IBInspectable var stopAngle: CGFloat = 1.6 { didSet { setNeedsDisplay() } }
    @IBInspectable var startDangerAngle: CGFloat = 1.6 { didSet { setNeedsDisplay() } }
    @IBInspectable var stopDangerAngle: CGFloat = 1.8 { didSet { setNeedsDisplay() } }
    
    @IBInspectable var textColor: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    @IBInspectable var text: String = "" { didSet { setNeedsDisplay() } }
    
    weak var dataSource: AnalogInstrumentViewDataSource?
    private var timer: NSTimer?
    
    private let arrowShape: CAShapeLayer
    
    override init(frame: CGRect) {
        arrowShape = CAShapeLayer()
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        arrowShape = CAShapeLayer()
        super.init(coder: aDecoder)
    }
    
    var viewCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    var circleRadius: CGFloat {
        return (min(bounds.size.width, bounds.size.height) / 2) * scale
    }
    // MARK: Hilfsfunktionen
    
    /**
     Berechnet einen Punkt auf dem Kreis
     
     - parameter Angle: Winkel des Punktes
     - parameter radius: Radius des Kreises
     - parameter center: Mittelpunkt des Kreises
     - return: Punkt auf dem Kreis
    */
    private func calcPoint(Angle: CGFloat, radius: CGFloat, center: CGPoint) -> CGPoint {
        let point = CGPoint(x: center.x + (radius*cos(Angle)), y: center.y + (radius*sin(Angle)))
        return point
    }
    
    /**
     Erstellt eine Linie von Kreisäusseren in Richtung Zentrum
     
     - parameter Angle: Winkel der Linie
     - parameter radius: Radius des Kreises (äusserer Punkt)
     - parameter center: Mittelpunkt des Kreises
     - parameter length: Länge der Linie
     - returns: UIBezierPath der Linie
    */
    func getLine(Angle: CGFloat, radius: CGFloat, center: CGPoint, length: CGFloat)-> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(calcPoint(Angle, radius: radius, center: center))
        path.addLineToPoint(calcPoint(Angle, radius: radius-length, center: center))
        return path
    }    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initArrow()
    }
    
    /**
     Initialisiert den Zeiger des Rundinstrumentes
    */
    func initArrow() {
        let arrowPath = getLine(CGFloat(Double(Double(startAngle))*M_PI), radius: circleRadius*CGFloat(arrowLengthLongPercentage), center: CGPoint(x: 0, y: 0), length: circleRadius)
        
        arrowShape.frame = CGRect(origin: viewCenter, size: CGSize(width: viewCenter.x, height: viewCenter.y))
        
        arrowShape.path = arrowPath.CGPath
        arrowShape.strokeColor = arrowColor.CGColor
        arrowShape.fillColor = arrowColor.CGColor
        arrowShape.lineWidth = lineWidth
        arrowShape.anchorPoint = CGPoint(x: 0, y: 0)
        self.layer.addSublayer(arrowShape)
    }
    
    /**
     Animiert den Zeiger von der alten Position zur neuen Position
    */
    func animateArrow() {
        let angle = dataSource?.arrowAngle(self) ?? 0.0
        let dest = CGFloat(Double(angle)*M_PI)
        arrowShape.transform = CATransform3DMakeRotation(dest, 0, 0, 1)
        
        let animateStrokeEnd = CABasicAnimation(keyPath: CONSTANTS.KEYPATH)
        animateStrokeEnd.fromValue = arrowAngle
        animateStrokeEnd.toValue = dest
        animateStrokeEnd.duration = CONSTANTS.ANIM_DURATION
        arrowAngle = CGFloat(dest)
        arrowShape.addAnimation(animateStrokeEnd, forKey: CONSTANTS.KEYPATH)
    }
    
    // MARK: DrawRect
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        
        let textFontAttributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(UIFont.systemFontSize()),
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let normalPath = UIBezierPath(arcCenter: viewCenter, radius: circleRadius, startAngle: CGFloat(Double(startAngle)*M_PI), endAngle: CGFloat(Double(stopAngle)*M_PI), clockwise: true)
        let dangerPath = UIBezierPath(arcCenter: viewCenter, radius: circleRadius, startAngle: CGFloat(Double(startDangerAngle)*M_PI), endAngle: CGFloat(Double(stopDangerAngle)*M_PI), clockwise: true)
        normalPath.lineWidth = lineWidth
        dangerPath.lineWidth = lineWidth
        color1.set()
        normalPath.stroke()
        var currentAngle: CGFloat = startAngle
        while currentAngle <= max(stopAngle, stopDangerAngle) {
           let line1 = getLine(CGFloat(Double(currentAngle)*M_PI), radius: circleRadius, center: viewCenter, length: circleRadius*LineLengthPercentSmall)
            line1.lineWidth = lineWidth
            if currentAngle <= stopAngle {
                color1.set()
            } else if currentAngle >= startDangerAngle {
                colorDanger.set()
            }
            if currentAngle <= stopAngle || currentAngle > startDangerAngle {
                line1.stroke()
            }
            currentAngle += SmallLineIncrease
        }
        
        currentAngle = startAngle
        var i = 0
        while currentAngle <= max(stopAngle, stopDangerAngle) {
            let line1 = getLine(CGFloat(Double(currentAngle)*M_PI), radius: circleRadius, center: viewCenter, length: circleRadius*LineLengthPercentBig)
            line1.lineWidth = lineWidth
            if currentAngle <= stopAngle {
                color1.set()
            } else if currentAngle >= startDangerAngle {
                colorDanger.set()
            }
            if currentAngle <= stopAngle || currentAngle > startDangerAngle {
                line1.stroke()
            }
            
            let point = calcPoint(CGFloat(Double(currentAngle)*M_PI), radius: circleRadius - ((circleRadius*LineLengthPercentBig)*CGFloat(CONSTANTS.DISTANCEMULTIPLICATOR)), center: viewCenter)
            let number = dataSource?.textForLine(self, LineNumber: i) ?? ""
            
            var rect = number.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributes, context: nil)
            
            rect.offsetInPlace(dx: point.x-rect.width/2, dy: point.y-rect.height/2)
            
            number.drawInRect(rect, withAttributes: textFontAttributes)
            
            i += 1
            currentAngle += BigLineIncrease
        }
        colorDanger.set()
        dangerPath.stroke()
        
        let textFontAttributesBig = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(UIFont.systemFontSize()),
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        var rect = text.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributesBig, context: nil)
        
        rect.offsetInPlace(dx: viewCenter.x-rect.width/2, dy: viewCenter.y-rect.height/2+circleRadius*CGFloat(CONSTANTS.TEXTRECTFAC))
        
        text.drawInRect(rect, withAttributes: textFontAttributesBig)
    }
    

}
