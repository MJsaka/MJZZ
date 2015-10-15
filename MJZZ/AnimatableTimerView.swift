//
//  AnimatableTimerView.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/15.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

class AnimatableTimerView: UIView {
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    let PI : CGFloat = 3.14159
    var animateProgress : CGFloat = 0
    var animateLineBackgroudColor : UIColor = UIColor.redColor()
    var defaultLineBackgroudColor : UIColor = UIColor.lightGrayColor()
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        let center : CGPoint = CGPoint(x: rect.width/2, y: rect.height/2)
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        //设置线条样式
        CGContextSetLineCap(context, CGLineCap.Round)
        //设置线条粗细宽度
        CGContextSetLineWidth(context, 3.0);
        //设置颜色
        var cRed : CGFloat = CGFloat()
        var cGreen : CGFloat = CGFloat()
        var cBlue : CGFloat = CGFloat()
        var cAlpha : CGFloat = CGFloat()
        
        //绘制初始圆
        defaultLineBackgroudColor.getRed(&cRed, green: &cGreen, blue: &cBlue, alpha: &cAlpha)
        CGContextSetRGBStrokeColor(context, cRed, cGreen, cBlue, cAlpha)
        CGContextBeginPath(context)
        CGContextAddArc(context, center.x, center.y, center.x - 5, PI * 3 / 2, PI * 7 / 2 , 0)
        CGContextStrokePath(context);
        
        //绘制动画圆
        animateLineBackgroudColor.getRed(&cRed, green: &cGreen, blue: &cBlue, alpha: &cAlpha)
        CGContextSetRGBStrokeColor(context, cRed, cGreen, cBlue, cAlpha)

        CGContextBeginPath(context)
        CGContextAddArc(context, center.x, center.y, center.x-5, PI * 3 / 2,  PI * 3 / 2 + PI * 2 * animateProgress, 0)
        CGContextStrokePath(context);

    }
}
