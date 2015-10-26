//
//  MJZZStatisticData.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/21.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

class MJZZTime : NSObject , NSCoding{
    let year : Int
    let month : Int
    let day : Int
    let hour : Int
    let minute : Int
    override convenience init() {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        let comp : NSDateComponents = calendar.components([.Year, .Month, .Day , .Hour , .Minute], fromDate: NSDate())
        self.init(year: comp.year , month: comp.month , day: comp.day ,hour: comp.hour , minute: comp.minute)
    }
    init(year aYear:Int , month aMonth : Int , day aDay : Int ,hour aHour : Int , minute aMinute : Int){
        year = aYear
        month = aMonth
        day = aDay
        hour = aHour
        minute = aMinute
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(year, forKey: "year")
        aCoder.encodeInteger(month, forKey: "month")
        aCoder.encodeInteger(day, forKey: "day")
        aCoder.encodeInteger(hour, forKey: "hour")
        aCoder.encodeInteger(minute, forKey: "minute")
    }
    required init?(coder aDecoder: NSCoder) {
        year = aDecoder.decodeIntegerForKey("year")
        month = aDecoder.decodeIntegerForKey("month")
        day = aDecoder.decodeIntegerForKey("day")
        hour = aDecoder.decodeIntegerForKey("hour")
        minute = aDecoder.decodeIntegerForKey("minute")
    }
}

class MJZZSelectedDateIndex {
    var yearIndex : Int
    var monthIndex : Int
    var dayIndex : Int
    private static let singleton : MJZZSelectedDateIndex = MJZZSelectedDateIndex()
    
    init(){
        yearIndex = -1
        monthIndex = -1
        dayIndex = -1
    }
    class func selectedIndex() -> MJZZSelectedDateIndex{
        return singleton
    }
    class func updateIndex() {
        let statisticData = MJZZStatisticData.sharedData()
        if singleton.yearIndex == -1 {
            if statisticData.data.count != 0 {
                //只要yearData存在，一定有dayData存在
                let aYearData = statisticData.data.last!
                singleton.yearIndex = aYearData.time.year - statisticData.data[0].time.year
                
                let aMonthData = aYearData.data.last!
                singleton.monthIndex = aMonthData.time.month - aYearData.data[0].time.month
                
                let aDayData = aMonthData.data.last!
                singleton.dayIndex = aDayData.time.day - aMonthData.data[0].time.day
            }
        } else if singleton.monthIndex == -1 {
            let aYearData = statisticData.data[singleton.yearIndex]
            
            let aMonthData = aYearData.data.last!
            singleton.monthIndex = aMonthData.time.month - aYearData.data[0].time.month
            
            let aDayData = aMonthData.data.last!
            singleton.dayIndex = aDayData.time.day - aMonthData.data[0].time.day

        } else if singleton.dayIndex == -1 {
            let aYearData = statisticData.data[singleton.yearIndex]
            let aMonthData = aYearData.data[singleton.monthIndex]
            let aDayData = aMonthData.data.last!
            singleton.dayIndex = aDayData.time.day - aMonthData.data[0].time.day

        }
    }
}

@objc protocol MJZZDataProtocol{
    var data : [MJZZDataProtocol] {get set}
    var duration : Int {get set}
    var time : MJZZTime {get set}
    func appendOnceData (aData : MJZZData)
}

class MJZZData : NSObject , MJZZDataProtocol , NSCoding {
    var data : [MJZZDataProtocol]
    var duration : Int = 0
    var time : MJZZTime
    func appendOnceData(aData: MJZZData) {
        return
    }
    override convenience init() {
        self.init(withTime : MJZZTime())
    }
    init(withTime aTime : MJZZTime){
        data = [MJZZDataProtocol]()
        time = aTime
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(duration, forKey: "duration")
        aCoder.encodeObject(time, forKey: "time")
        aCoder.encodeObject(data, forKey: "data")
    }
    required init?(coder aDecoder: NSCoder) {
        duration = aDecoder.decodeIntegerForKey("duration")
        time = aDecoder.decodeObjectForKey("time") as! MJZZTime
        data = aDecoder.decodeObjectForKey("data") as! [MJZZDataProtocol]
    }
}

class MJZZDayData : MJZZData {
    override func appendOnceData(aData : MJZZData){
        data.append(aData)
        duration += aData.duration
    }
}

class MJZZMonthData : MJZZData {
    override func appendOnceData (aData : MJZZData){
        var aDayData : MJZZDayData
        if data.last?.time.day == aData.time.day{
            aDayData = data.last as! MJZZDayData
        }else{
            aDayData = MJZZDayData(withTime: aData.time)
            data.append(aDayData)
        }
        aDayData.appendOnceData(aData)
        duration += aData.duration
    }
}

class MJZZYearData : MJZZData {
    override func appendOnceData (aData : MJZZData){
        var aMonthData : MJZZMonthData
        if data.last?.time.month == aData.time.month {
            aMonthData = data.last as! MJZZMonthData
        }else{
            aMonthData = MJZZMonthData(withTime: aData.time)
            data.append(aMonthData)
        }
        aMonthData.appendOnceData(aData)
        duration += aData.duration
    }
}
var singletonStatisticData : MJZZStatisticData = MJZZStatisticData()

class MJZZStatisticData : MJZZData{
    
    var bestOnceDuration : Int = 0
    
    class func appendOnceData (aData : MJZZData){
        var aYearData : MJZZYearData
        if singletonStatisticData.data.last?.time.year == aData.time.year {
            aYearData = singletonStatisticData.data.last as! MJZZYearData
        }else{
            aYearData = MJZZYearData(withTime: aData.time)
            singletonStatisticData.data.append(aYearData)
        }
        aYearData.appendOnceData(aData)
        singletonStatisticData.duration += aData.duration
        if aData.duration > singletonStatisticData.bestOnceDuration {
            singletonStatisticData.bestOnceDuration = aData.duration
        }
    }
    class func sharedData() -> MJZZStatisticData {
        return singletonStatisticData
    }
}