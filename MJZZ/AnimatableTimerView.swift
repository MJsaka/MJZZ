//
//  AnimatableTimerView.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/15.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit
enum TimeAnimateType : Int32{
    case IncreaseType = 0
    case DecreaseType = 1
}

class AnimatableTimerView: UIView {
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    var animateType : TimeAnimateType = TimeAnimateType.IncreaseType
    var animateProgress : Double = 0
    var animatingLineColor : UIColor = UIColor.redColor()
    var animatedLineColor : UIColor = UIColor.lightGrayColor()
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        let center : CGPoint = CGPoint(x: rect.width/2, y: rect.height/2)
        let radius : CGFloat = center.x * 3/4
        let startAngle : CGFloat = CGFloat(3/2 * M_PI)
        var endAngle : CGFloat
        var animateEndAngle : CGFloat
        if animateProgress > 1.0 {
            animateProgress = 0
            let aColor : UIColor = animatingLineColor
            animatingLineColor = animatedLineColor
            animatedLineColor = aColor
        }
        
        switch animateType {
        case TimeAnimateType.IncreaseType :
            endAngle = CGFloat(7/2 * M_PI)
            animateEndAngle = CGFloat((3+4*animateProgress)/2 * M_PI)
        case TimeAnimateType.DecreaseType :
            endAngle  = CGFloat(-1/2 * M_PI)
            animateEndAngle = CGFloat((3-4*animateProgress)/2 * M_PI)
            animatedLineColor = UIColor.redColor()
            animatingLineColor = UIColor.lightGrayColor()
        }
        
        var cRed : CGFloat = CGFloat()
        var cGreen : CGFloat = CGFloat()
        var cBlue : CGFloat = CGFloat()
        var cAlpha : CGFloat = CGFloat()
        
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, 5.0);
        //绘制初始圆
        CGContextBeginPath(context)
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, animateType.rawValue)
        animatedLineColor.getRed(&cRed, green: &cGreen, blue: &cBlue, alpha: &cAlpha)
        CGContextSetRGBStrokeColor(context, cRed, cGreen, cBlue, cAlpha)
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
       
        //绘制动画圆
        CGContextBeginPath(context)
        CGContextAddArc(context, center.x, center.y, radius, startAngle, animateEndAngle, animateType.rawValue)
        animatingLineColor.getRed(&cRed, green: &cGreen, blue: &cBlue, alpha: &cAlpha)
        CGContextSetRGBStrokeColor(context, cRed, cGreen, cBlue, cAlpha)
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
    }
}
