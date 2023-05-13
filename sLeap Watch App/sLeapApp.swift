//
//  sLeapApp.swift
//  sLeap Watch App
//
//  Created by 성수한 on 2023/05/12.
//

import SwiftUI
import HealthKit

@main
struct sLeap_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var sleepText: String = "Fetching sleep data..."
    private let healthStore = HKHealthStore()
    
    var body: some View {
        Text(sleepText)
            .onAppear(perform: requestAuthorization)
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            sleepText = "Health data is not available."
            return
        }
        
        let readDataTypes: Set<HKObjectType> = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
        
        healthStore.requestAuthorization(toShare: nil, read: readDataTypes) { (success, error) in
            if success {
                self.fetchLatestSleepAnalysis()
            } else {
                DispatchQueue.main.async {
                    self.sleepText = "Authorization failed."
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
                    self.sleepText = "No sleep data available."
                }
                return
            }
            
            let duration = Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)
            
            DispatchQueue.main.async {
                self.sleepText = "\(duration)분 수면"
            }
        }
        
        healthStore.execute(query)
    }
}
