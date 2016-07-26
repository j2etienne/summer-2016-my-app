//
//  ViewController.swift
//  Alt Life
//
//  Created by keivn c on 7/26/16.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var pedometerLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var cirlceProgressBar: MCPercentageDoughnutView!
    
    let pedometer = CMPedometer()
    let activityManager = CMMotionActivityManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let date = NSDate()
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year, .TimeZone]
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: date)
        
        // reset to begin from current day's midnight
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = NSTimeZone.systemTimeZone()
        
        let midnightOfToday = NSCalendar.currentCalendar().dateFromComponents(components)
        
        
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data: CMMotionActivity?) in
                dispatch_async(dispatch_get_main_queue(), { 
                    if data?.stationary == true {
                        self.activityLabel.text = "Status: Stationary"
                    } else if data?.walking == true {
                        self.activityLabel.text = "Status: Walking"
                    } else if data?.running == true {
                        self.activityLabel.text = "Status: Running"
                    } else if data?.automotive == true {
                        self.activityLabel.text = "Status: Vehicle"
                    }
                })
            })
        }
        
        
        if CMPedometer.isStepCountingAvailable() {
            let fromDate = NSDate(timeIntervalSinceNow: -86400)
            self.pedometer.queryPedometerDataFromDate(fromDate, toDate: NSDate()) { (data: CMPedometerData?, error) -> Void in
                print(data)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if error == nil {
                        self.pedometerLabel.text = "\(data!.numberOfSteps)"
                        self.cirlceProgressBar.dataSource = self
                        self.cirlceProgressBar.linePercentage = 0.02
                        self.cirlceProgressBar.percentage = 0.5
                        self.cirlceProgressBar.animatesBegining = false
                    }
                })
            }
            
            self.pedometer.startPedometerUpdatesFromDate(midnightOfToday!, withHandler: { (data: CMPedometerData?, error) in
                dispatch_async(dispatch_get_main_queue(), { 
                    if error == nil {
                        self.pedometerLabel.text = "\(data!.numberOfSteps)"
                    }
                })
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

