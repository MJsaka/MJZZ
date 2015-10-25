//
//  MJZZStatisticData.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/21.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

class MJZZTime {
    let year : Int
    let month : Int
    let day : Int
    let hour : Int
    let minute : Int
    convenience init() {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.systemTimeZone()
        let comp : NSDateComponents = calendar.components([.Year, .Month, .Day , .Hour , .Minute], fromDate: NSDate())
        self.init(year: comp.year , month: comp.month , day: comp.day ,hour: comp.hour , minute: comp.minute)
    }
    required init(year aYear:Int , month aMonth : Int , day aDay : Int ,hour aHour : Int , minute aMinute : Int){
        year = aYear
        month = aMonth
        day = aDay
        hour = aHour
        minute = aMinute
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

protocol MJZZDataProtocol {
    var data : [MJZZDataProtocol] {get set}
    var duration : Int {get set}
    var time : MJZZTime {get set}
    func appendOnceData (aData : MJZZData)
}

class MJZZData : NSObject , MJZZDataProtocol {
    var data : [MJZZDataProtocol]
    var duration : Int = 0
    var time : MJZZTime
    
    override init() {
        data = [MJZZData]()
        time = MJZZTime()
    }
    init(withTime aTime : MJZZTime){
        data = [MJZZData]()
        time = aTime
    }
    func appendOnceData(aData: MJZZData) {
        return
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

class MJZZStatisticData : MJZZData{
    private static let singleton : MJZZStatisticData = MJZZStatisticData()
    
    var bestOnceDuration : Int = 0
    
    class func appendOnceData (aData : MJZZData){
        var aYearData : MJZZYearData
        if singleton.data.last?.time.year == aData.time.year {
            aYearData = singleton.data.last as! MJZZYearData
        }else{
            aYearData = MJZZYearData(withTime: aData.time)
            singleton.data.append(aYearData)
        }
        aYearData.appendOnceData(aData)
        singleton.duration += aData.duration
        if aData.duration > singleton.bestOnceDuration {
            singleton.bestOnceDuration = aData.duration
        }
    }
    class func sharedData() -> MJZZStatisticData {
        return singleton
    }
}