//
//  MJZZGraphView.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/22.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

class MJZZGraphView: UIView {
    
    var minDuration : Int = 0
    var maxDuration : Int = 0
    var selectedDataIndex : MJZZDataIndex!
    var selectedDataScope : MJZZDataScope = MJZZDataScope.year
    var currentDataArray : [MJZZDataProtocol]!
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        if currentDataArray.count == 0 {
            return
        }
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        let maxHeight : CGFloat = rect.size.height * 0.85

        //绘制X轴
        CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1)
        CGContextFillRect(context, CGRect(x: 0, y: maxHeight, width: rect.width, height: 1))

        let maxDetaDuration : Int = maxDuration - minDuration
        //记录所有点的连线
        let path : CGMutablePathRef = CGPathCreateMutable();

        for index in 0 ..< currentDataArray.count{
            //绘制X轴坐标
            CGContextSetRGBFillColor(context, 0.6, 0.6, 0.6, 1)
            CGContextFillRect(context, CGRect(x: 20 + CGFloat(index) * 40, y: maxHeight - 8, width: 1, height: 8))
            //绘制X轴文字
            var sectionTitle : NSString
            switch selectedDataScope {
            case MJZZDataScope.year :
                sectionTitle = NSString(format: "%.2d年",currentDataArray[index].time.year%100)
            case MJZZDataScope.month :
                sectionTitle = NSString(format: "%.2d月",currentDataArray[index].time.month)
            case MJZZDataScope.day :
                sectionTitle = NSString(format: "%.2d日",currentDataArray[index].time.day)
            }
            let center = CGPoint(x: 5 + CGFloat(index) * 40, y: maxHeight + 10)
            
            let attr : [ String : AnyObject] = [
                NSFontAttributeName : UIFont.monospacedDigitSystemFontOfSize(15, weight: UIFontWeightRegular) ,
                NSForegroundColorAttributeName : UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            ]
            sectionTitle.drawAtPoint(center, withAttributes: attr)
            //添加线
            let aDetaDuration : Int = currentDataArray[index].duration - minDuration
            let rate = CGFloat(aDetaDuration)/CGFloat(maxDetaDuration)
            if index == 0{
                CGPathMoveToPoint(path, nil, 20 + CGFloat(index) * 40, maxHeight - maxHeight * rate)
            }
            if index > 0 {
                CGPathAddLineToPoint(path, nil, 20 + CGFloat(index) * 40, maxHeight - maxHeight * rate)
            }
        }
        //绘制折线
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineJoin(context, CGLineJoin.Miter)
        CGContextSetLineWidth(context, 1)

        CGContextAddPath(context, path);
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
        //绘制圆点
        var selectedDataIndexOfCurrentScope : Int
        switch selectedDataScope {
        case MJZZDataScope.year :
            selectedDataIndexOfCurrentScope = selectedDataIndex.yearIndex
        case MJZZDataScope.month :
            selectedDataIndexOfCurrentScope = selectedDataIndex.monthIndex
        case MJZZDataScope.day :
            selectedDataIndexOfCurrentScope = selectedDataIndex.dayIndex
        }
        for index in 0 ..< currentDataArray.count{
            let aDetaDuration : Int = currentDataArray[index].duration - minDuration
            let rate = CGFloat(aDetaDuration)/CGFloat(maxDetaDuration)
            
            switch rate {
            case 0 ..< 0.2 :
                CGContextSetRGBFillColor(context, 0.9, 0, 0, 1)
            case 0.2 ..< 0.4 :
                CGContextSetRGBFillColor(context, 0.9, 0.6, 0, 1)
            case 0.4 ..< 0.6 :
                CGContextSetRGBFillColor(context, 0.9, 0.85, 0, 1)
            case 0.6 ..< 0.8 :
                CGContextSetRGBFillColor(context, 0, 0.8, 0.9, 1)
            case 0.8 ..< 1 :
                    CGContextSetRGBFillColor(context, 0, 0.9, 0.3, 1)
            default :
                break
            }
            
            if index == selectedDataIndexOfCurrentScope {
                CGContextAddArc(context, 20 + CGFloat(index) * 40, maxHeight - maxHeight * rate, 10, CGFloat(M_PI_2), CGFloat(7 * M_PI_2), 0)
            } else {
                CGContextAddArc(context, 20 + CGFloat(index) * 40, maxHeight - maxHeight * rate, 5, CGFloat(M_PI_2), CGFloat(7 * M_PI_2), 0)
            }
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        }
    }
}
