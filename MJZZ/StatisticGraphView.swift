//
//  MJZZGraphView.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/22.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

enum GraphScope {
    case year
    case month
    case day
}

class MJZZGraphView: UIView {
    
    var axisYMinDuration : Int = 0
    var axisYMaxDuration : Int = 0
    var currentGraphDataArray : [MJZZDataProtocol]!
    var selectedGraphDataIndex : Int = 0
    var selectedGraphScope : GraphScope = GraphScope.year
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let maxHeight : CGFloat = rect.size.height * 0.85
        let pointYOfAxisX : CGFloat = rect.size.height * 0.85
        let maxDetaDuration : Int = axisYMaxDuration - axisYMinDuration

        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        
        //绘制X轴
        CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1)
        CGContextFillRect(context, CGRect(x: 0, y: pointYOfAxisX, width: rect.width, height: 1))
        //设置连线及点的绘制属性
        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 1.0, 1.0)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, 2)
        CGContextSetLineJoin(context, CGLineJoin.Miter)
        //记录所有点的连线
        let path : CGMutablePathRef = CGPathCreateMutable();

        for index in 0 ..< currentGraphDataArray.count{
            let position = currentGraphDataArray.count - 1 - index
            let aDetaDuration : Int = currentGraphDataArray[index].duration - axisYMinDuration
            let rate = CGFloat(aDetaDuration)/CGFloat(maxDetaDuration)
            if index == 0{
                CGPathMoveToPoint(path, nil, 20 + CGFloat(position) * 40, pointYOfAxisX - maxHeight * rate)
            }
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
            CGContextAddArc(context, 20 + CGFloat(position) * 40, pointYOfAxisX - maxHeight * rate, 5, CGFloat(M_PI_2), CGFloat(7 * M_PI_2), 0)
            //绘制圆点
            if index == selectedGraphDataIndex {
                CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
            } else {
                CGContextDrawPath(context, CGPathDrawingMode.Fill)
            }
            //添加线
            if index > 0 {
                CGPathAddLineToPoint(path, nil, 20 + CGFloat(position) * 40, pointYOfAxisX - maxHeight * rate)
            }
            
            //绘制X轴坐标
            CGContextSetRGBFillColor(context, 0.6, 0.6, 0.6, 1)
            CGContextFillRect(context, CGRect(x: 20 + CGFloat(position) * 40, y: pointYOfAxisX - 8, width: 1, height: 8))
            //绘制X轴文字
            var axisXSectionTitle : NSString
            switch selectedGraphScope {
            case .year :
                axisXSectionTitle = NSString(format: "%.2d",currentGraphDataArray[index].time.year%100)
            case .month :
                axisXSectionTitle = NSString(format: "%.2d",currentGraphDataArray[index].time.month)
            case .day :
                axisXSectionTitle = NSString(format: "%.2d",currentGraphDataArray[index].time.day)
            }
            let center = CGPoint(x: 10 + CGFloat(position) * 40, y: pointYOfAxisX + 10)
            
            let attr : [ String : AnyObject] = [
                NSFontAttributeName : UIFont.monospacedDigitSystemFontOfSize(15, weight: UIFontWeightRegular) ,
                NSForegroundColorAttributeName : UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            ]
            axisXSectionTitle.drawAtPoint(center, withAttributes: attr)
        }
        CGContextAddPath(context, path);
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
    }
}
