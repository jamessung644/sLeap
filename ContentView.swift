//
//  ContentView.swift
//  sLeap Watch App
//
//  Created by 성수한 on 2023/05/12.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var sleepLabel: WKInterfaceLabel!
    
    private let healthStore = HKHealthStore()
    private var timer: Timer?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        requestAuthorization()
    }
    
    override func willActivate() {
        super.willActivate()
        startTimer()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        stopTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.fetchLatestSleepAnalysis()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            sleepLabel.setText("Health data is not available.")
            return
        }
        
        let readDataTypes: Set<HKObjectType> = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
        
        healthStore.requestAuthorization(toShare: nil, read: readDataTypes) { (success, error) in
            if success {
                self.fetchLatestSleepAnalysis()
            } else {
                DispatchQueue.main.async {
                    self.sleepLabel.setText("Authorization failed.")
                }
            }
        }
    }
    
    func fetchLatestSleepAnalysis() {
        let sleepAnalysisType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepAnalysisType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let samples = samples as? [HKCategorySample], let sample = samples.first else {
                DispatchQueue.main.async {
                    self.sleepLabel.setText("No sleep data available.")
                }
                return
            }
            
            let duration = Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)
            
            DispatchQueue.main.async {
                self.sleepLabel.setText("\(duration)분 수면")
            }
        }
        
        healthStore.execute(query)
    }
}
