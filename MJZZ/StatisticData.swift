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

@objc protocol MJZZDataProtocol{
    var data : [MJZZDataProtocol] {get set}
    var duration : Int {get set}
    var time : MJZZTime {get set}
    func deleteDataAtIndexes(indexes : [Int], withSelectedDataIndex dataIndex: MJZZDataIndex , withSelectedDataScope dataScope : MJZZDataScope)
}

class MJZZData : NSObject , MJZZDataProtocol , NSCoding {
    var data : [MJZZDataProtocol]
    var duration : Int = 0
    var time : MJZZTime
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
    required init(coder aDecoder: NSCoder) {
        duration = aDecoder.decodeIntegerForKey("duration")
        time = aDecoder.decodeObjectForKey("time") as! MJZZTime
        data = aDecoder.decodeObjectForKey("data") as! [MJZZDataProtocol]
    }
    func deleteDataAtIndexes(indexes : [Int], withSelectedDataIndex dataIndex: MJZZDataIndex , withSelectedDataScope dataScope : MJZZDataScope){
        return
    }
}

class MJZZDayData : MJZZData {
    func appendOnceData(aData : MJZZData){
        data.insert(aData, atIndex: 0)
        duration += aData.duration
    }
    override func deleteDataAtIndexes(indexes : [Int], withSelectedDataIndex dataIndex: MJZZDataIndex , withSelectedDataScope dataScope : MJZZDataScope){
        if dataScope == MJZZDataScope.day {
            for index in indexes {
                duration -= data[index].duration
            }
            if duration == 0 {
                return
            }
            for (var i = indexes.count - 1; i >= 0; --i) {
                let index = indexes[i]
                data.removeAtIndex(index)
            }
        }
    }
}

class MJZZMonthData : MJZZData {
    func appendOnceData (aData : MJZZData){
        var aDayData : MJZZDayData
        if !data.isEmpty && data.first!.time.day == aData.time.day{
            aDayData = data.first as! MJZZDayData
        }else{
            aDayData = MJZZDayData(withTime: aData.time)
            data.insert(aDayData, atIndex: 0)
        }
        aDayData.appendOnceData(aData)
        duration += aData.duration
    }
    override func deleteDataAtIndexes(indexes : [Int], withSelectedDataIndex dataIndex: MJZZDataIndex , withSelectedDataScope dataScope : MJZZDataScope){
        if dataScope == MJZZDataScope.month {
            for index in indexes {
                duration -= data[index].duration
            }
            if duration == 0 {
                return
            }
            for (var i = indexes.count - 1; i >= 0; --i) {
                let index = indexes[i]
                data.removeAtIndex(index)
            }
        } else {
            duration -= data[dataIndex.dayIndex].duration
            data[dataIndex.dayIndex].deleteDataAtIndexes(indexes, withSelectedDataIndex: dataIndex, withSelectedDataScope: dataScope)
            if data[dataIndex.dayIndex].duration == 0 {
                data.removeAtIndex(dataIndex.dayIndex)
            } else {
                duration += data[dataIndex.dayIndex].duration
            }
        }
    }
}

class MJZZYearData : MJZZData {
    func appendOnceData (aData : MJZZData){
        var aMonthData : MJZZMonthData
        if !data.isEmpty && data.first!.time.month == aData.time.month {
            aMonthData = data.first as! MJZZMonthData
        }else{
            aMonthData = MJZZMonthData(withTime: aData.time)
            data.insert(aMonthData, atIndex: 0)
        }
        aMonthData.appendOnceData(aData)
        duration += aData.duration
    }
    override func deleteDataAtIndexes(indexes : [Int], withSelectedDataIndex dataIndex: MJZZDataIndex , withSelectedDataScope dataScope : MJZZDataScope){
        if dataScope == MJZZDataScope.year {
            for index in indexes {
                duration -= data[index].duration
            }
            if duration == 0 {
                return
            }
            for (var i = indexes.count - 1; i >= 0; --i) {
                let index = indexes[i]
                data.removeAtIndex(index)
            }
        } else {
            duration -= data[dataIndex.monthIndex].duration
            data[dataIndex.monthIndex].deleteDataAtIndexes(indexes, withSelectedDataIndex: dataIndex, withSelectedDataScope: dataScope)
            if data[dataIndex.monthIndex].duration == 0 {
                data.removeAtIndex(dataIndex.monthIndex)
            } else {
                duration += data[dataIndex.monthIndex].duration
            }
        }
    }
}
var singletonStatisticData : MJZZStatisticData = MJZZStatisticData()
class MJZZStatisticData : MJZZData{
    
    var bestOnceDuration : Int = 0
    class func appendOnceData (aData : MJZZData){
        var aYearData : MJZZYearData
        if !singletonStatisticData.data.isEmpty && singletonStatisticData.data.first!.time.year == aData.time.year {
            aYearData = singletonStatisticData.data.first as! MJZZYearData
        }else{
            aYearData = MJZZYearData(withTime: aData.time)
            singletonStatisticData.data.insert(aYearData, atIndex: 0)
        }
        aYearData.appendOnceData(aData)
        singletonStatisticData.duration += aData.duration
        if aData.duration > singletonStatisticData.bestOnceDuration {
            singletonStatisticData.bestOnceDuration = aData.duration
            NSNotificationCenter.defaultCenter().postNotificationName("MJZZNotificationBestDurationChanged", object: singletonStatisticData)
        }
        NSNotificationCenter.defaultCenter().postNotificationName("MJZZNotificationStatisticDataChanged", object: singletonStatisticData)
    }
    class func deleteDataAtIndexes(indexes : [Int], withSelectedDataIndex dataIndex: MJZZDataIndex , withSelectedDataScope dataScope : MJZZDataScope){
        singletonStatisticData.duration -= singletonStatisticData.data[dataIndex.yearIndex].duration
        singletonStatisticData.data[dataIndex.yearIndex].deleteDataAtIndexes(indexes, withSelectedDataIndex: dataIndex, withSelectedDataScope: dataScope)
        if singletonStatisticData.data[dataIndex.yearIndex].duration == 0 {
            singletonStatisticData.data.removeAtIndex(dataIndex.yearIndex)
        } else {
            singletonStatisticData.duration += singletonStatisticData.data[dataIndex.yearIndex].duration
        }
    }
    class func sharedData() -> MJZZStatisticData {
        return singletonStatisticData
    }
    convenience init(){
        self.init(withTime : MJZZTime())
    }
    override init(withTime aTime: MJZZTime) {
        super.init(withTime: aTime)
    }
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeInteger(bestOnceDuration, forKey: "bestOnceDuration")
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        bestOnceDuration = aDecoder.decodeIntegerForKey("bestOnceDuration")
    }
}