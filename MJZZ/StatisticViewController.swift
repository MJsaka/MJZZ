//
//  StatisticViewController.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/9.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

class StatisticViewController: UIViewController , UITableViewDataSource ,UITableViewDelegate {

    @IBOutlet weak var axisY5: UILabel!
    @IBOutlet weak var axisY4: UILabel!
    @IBOutlet weak var axisY3: UILabel!
    @IBOutlet weak var axisY2: UILabel!
    @IBOutlet weak var axisY1: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var graphScrollView: UIScrollView!
    
    @IBOutlet weak var axisYView: StatisticAxisYView!
    let graphView : MJZZGraphView = MJZZGraphView()

    @IBOutlet weak var graphScopeSegment: UISegmentedControl!
    
    var selectedGraphScope : GraphScope = GraphScope.year    
    var currentGraphDataArray : [MJZZDataProtocol]!
    var currentGraphDataCount : Int = 0
    var selectedGraphDataIndex : Int = 0
    var axisYMinDuration : Int = 0
    var axisYMaxDuration : Int = 0


    
    let selectedDateIndex : MJZZSelectedDateIndex = MJZZSelectedDateIndex.selectedIndex()
    let statisticData : MJZZStatisticData = MJZZStatisticData.sharedData()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setSegmentedControlStyle(graphScopeSegment , fontSize : 16)
        
        graphView.backgroundColor = UIColor.whiteColor()
        graphScrollView.addSubview(graphView)
        graphScrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        for i in 2011 ... 2015 {
            let aYear : Int = i
            for j in 1 ... 10 {
                let aMonth : Int = j
                for k in 1 ... 25 {
                    let aDay : Int = k
                    let aData : MJZZData = MJZZData(withTime: MJZZTime(year: aYear, month: aMonth, day: aDay, hour: 0, minute: 0))
                    aData.duration = random() % 360000
                    MJZZStatisticData.appendOnceData(aData)
                }
            }
        }
        refreshAll()
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshAll()
    }
    
    
    @IBAction func graphScopeChanged(sender: UISegmentedControl) {
        switch graphScopeSegment.selectedSegmentIndex {
        case 0 :
            selectedGraphScope = .year
        case 1 :
            selectedGraphScope = .month
        case 2 :
            selectedGraphScope = .day
        default :
            break
        }
        graphScrollView.contentOffset = CGPoint(x: 0, y: 0)
        refreshAll()
    }
    
    func refreshAll() {
        if selectedDateIndex.dayIndex == -1 {
            MJZZSelectedDateIndex.updateIndex()
        }
        if selectedDateIndex.yearIndex == -1 {
            return
        }
        
        let selectedYearData = statisticData.data[selectedDateIndex.yearIndex] as! MJZZYearData
        let selectedMonthData = selectedYearData.data[selectedDateIndex.monthIndex] as! MJZZMonthData
 
        switch selectedGraphScope {
        case .year :
            currentGraphDataArray = statisticData.data
            selectedGraphDataIndex = selectedDateIndex.yearIndex
            currentGraphDataCount = statisticData.data.count
        case .month :
            currentGraphDataArray = selectedYearData.data
            selectedGraphDataIndex = selectedDateIndex.monthIndex
            currentGraphDataCount = selectedYearData.data.count
        case .day :
            currentGraphDataArray = selectedMonthData.data
            selectedGraphDataIndex = selectedDateIndex.dayIndex
            currentGraphDataCount = selectedMonthData.data.count
        }
        var longestGraphDataDuration : Int = 0
        var shortestGraphDataDuration = Int(INT64_MAX)
        for aData in currentGraphDataArray {
            if aData.duration > longestGraphDataDuration {
                longestGraphDataDuration = aData.duration
            }
            if aData.duration < shortestGraphDataDuration {
                shortestGraphDataDuration = aData.duration
            }
        }
        axisYMinDuration = Int(Double(shortestGraphDataDuration) * 0.9)
        axisYMaxDuration = Int(Double(longestGraphDataDuration) * 1.1)
        self.refreshGraphView()
        self.refreshGraphAxisYView()
        tableView.reloadData()
    }
    
    func refreshGraphView() {
        graphView.currentGraphDataArray = currentGraphDataArray
        graphView.selectedGraphDataIndex = selectedGraphDataIndex
        graphView.axisYMinDuration = axisYMinDuration
        graphView.axisYMaxDuration = axisYMaxDuration
        graphView.selectedGraphScope = selectedGraphScope
        graphView.frame.size.height = axisYView.frame.height
        var aWidth : CGFloat = CGFloat(currentGraphDataCount * 40 + 80)
        if aWidth < self.view.frame.width {
            aWidth = self.view.frame.width
        }
        graphView.frame.size.width = aWidth
        graphView.frame.origin = CGPoint(x: 0, y: 0)
        graphScrollView.contentSize = graphView.frame.size
        graphView.setNeedsDisplay()
    }
    func refreshGraphAxisYView() {
        axisYView.axisYMinDuration = axisYMinDuration
        axisYView.axisYMaxDuration = axisYMaxDuration
        axisYView.setNeedsDisplay()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return currentGraphDataArray[selectedGraphDataIndex].data.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var aString : String
        let aTime : MJZZTime = currentGraphDataArray[selectedGraphDataIndex].time
        switch selectedGraphScope{
        case .year :
            aString = String(format:"%d年每月累计时长",aTime.year)
        case .month :
            aString = String(format:"%d年%d月每天累计时长",aTime.year,aTime.month)
        case .day :
            aString = String(format:"%d年%d月%d天每次时长",aTime.year,aTime.month,aTime.day)
        }
        return aString
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let aCell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("StatisticTableViewCell") as UITableViewCell!
        let startTimeLabel : UILabel = aCell.viewWithTag(2) as! UILabel
        let durationLabel : UILabel = aCell.viewWithTag(3) as! UILabel
        
        let aData = currentGraphDataArray[selectedGraphDataIndex].data[indexPath.row]
        
        durationLabel.text = compactStringFromTime(aData.duration)
        switch selectedGraphScope{
        case .year :
            startTimeLabel.text = String(format:"%d月",aData.time.month)
        case .month :
            startTimeLabel.text = String(format:"%d日",aData.time.day)
        case .day :
            startTimeLabel.text = String(format:"%.2d:%.2d",aData.time.hour,aData.time.minute)
        }
        return aCell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return true
    }
    
    func setSegmentedControlStyle(segment : UISegmentedControl, fontSize aSize : CGFloat){
        segment.setBackgroundImage(UIImage(named: "Segment_Normal")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        segment.setBackgroundImage(UIImage(named: "Segment_Selected")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 0)), forState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
        segment.setDividerImage(UIImage(named: "Segment_Separate")?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)), forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
        segment.setDividerImage(UIImage(named: "Segment_Separate")?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)), forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        segment.setDividerImage(UIImage(named: "Segment_Separate")?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)), forLeftSegmentState: UIControlState.Selected, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        segment.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "Heiti SC", size: aSize)! ,
            NSForegroundColorAttributeName : UIColor.darkGrayColor() ],
            forState: UIControlState.Normal)
        segment.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "Heiti SC", size: aSize)! ,
            NSForegroundColorAttributeName : UIColor.redColor() ],
            forState: UIControlState.Selected)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

func compactStringFromTime(aTime : Int) -> String {
    switch aTime {
    case 0 ..< 6000 :
        return String(format:"%.2d秒%.2d",aTime/100 , aTime%100)
    case 6000 ..< 360000 :
        return String(format:"%.2d分%.2d秒",aTime/6000 , (aTime/100)%60)
    case 360000 ..< 8640000 :
        return String(format:"%.2d时%.2d分",aTime/360000 , (aTime/6000)%60)
    case 8640000 ..< Int(INT64_MAX) :
        return String(format:"%.2d天%.2d时",aTime/8640000 , (aTime/360000)%24)
    default :
        return String()
    }
}
