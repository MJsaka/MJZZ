//
//  StatisticAxisYView.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/22.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

class StatisticAxisYView: UIView {
    var minDuration : Int = 0
    var maxDuration : Int = 0
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        if MJZZStatisticData.sharedData().data.count == 0 {
            return
        }
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetRGBFillColor(context, 0.6, 0.6, 0.6, 1)
        
        let maxHeight : CGFloat = rect.size.height * 0.85
        //绘制Y轴
        CGContextFillRect(context, CGRect(x: 90, y: 0, width: 1, height: rect.size.height))
        for i in 0 ... 5 {
            //绘制Y轴文本
            let maxDetaDuration : Int = maxDuration - minDuration
            
            let sectionTitle = compactStringFromTime(minDuration + i * maxDetaDuration / 5)
            let rightAlignmentStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
            rightAlignmentStyle.alignment = NSTextAlignment.Right
            let attr : [ String : AnyObject] = [
                NSFontAttributeName : UIFont.monospacedDigitSystemFontOfSize(15, weight: UIFontWeightRegular)  ,
                NSForegroundColorAttributeName : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) ,
                NSParagraphStyleAttributeName : rightAlignmentStyle
            ]
            let sectionRect : CGRect = CGRect(x: 0, y: maxHeight - CGFloat(i) / 5 * maxHeight - 20 , width: 85, height: 20)
            NSString(string: sectionTitle).drawInRect(sectionRect, withAttributes: attr)
            
            //绘制大刻度线
            CGContextFillRect(context, CGRect(x: 80, y: maxHeight - CGFloat(i) / 5 * maxHeight, width: 10, height: 1))
            for j in 1 ... 4 {
                //绘制小刻度线
                CGContextFillRect(context, CGRect(x: 85, y: maxHeight - (CGFloat(i) + CGFloat(j) / 5 ) / 5 * maxHeight , width: 5, height: 1))
            }
        }
    }
}
