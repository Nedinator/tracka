//
//  AppUsageTracker.swift
//  tracka
//
//  Created by Neal Carico on 2/12/24.
//

import AppKit
import SwiftUI

class AppUsageTracker: ObservableObject {
    static let shared = AppUsageTracker()
    
    @Published var activities: [AppActivity] = []
    private var updateTimer: Timer?
    public var allowedServices: Set<String> = []
    
    init() {
        startTracking()
        loadActivities()
    }
    
    private func startTracking() {
        // Ensures the timer starts tracking immediately when the app launches.
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateActiveAppUsage()
        }
    }
    
    private func updateActiveAppUsage() {
        guard let activeApp = NSWorkspace.shared.frontmostApplication,
              let appName = activeApp.localizedName,
              let bundleID = activeApp.bundleIdentifier else { return }
        
        // Temporarily comment this out for testing
        // if allowedServices.contains(bundleID) {
            if let index = activities.firstIndex(where: { $0.bundleIdentifier == bundleID }) {
                DispatchQueue.main.async {
                    self.activities[index].usageDuration += 1
                }
            } else {
                let newActivity = AppActivity(name: appName, usageDuration: 1, bundleIdentifier: bundleID)
                DispatchQueue.main.async {
                    self.activities.append(newActivity)
                }
            }
        // }
        saveActivities()
    }


    func allowService(_ bundleIdentifier: String) {
        allowedServices.insert(bundleIdentifier)
    }

    func removeService(_ bundleIdentifier: String) {
        allowedServices.remove(bundleIdentifier)
        DispatchQueue.main.async {
            self.activities.removeAll { $0.bundleIdentifier == bundleIdentifier }
        }
    }
    
    func saveActivities() {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("activities.json")

            let data = try JSONEncoder().encode(activities)
            try data.write(to: fileURL)
        } catch {
            print("Error saving activities: \(error)")
        }
    }

    func loadActivities() {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("activities.json")

            let data = try Data(contentsOf: fileURL)
            activities = try JSONDecoder().decode([AppActivity].self, from: data)
        } catch {
            print("Error loading activities: \(error)")
        }
    }

    
    deinit {
        updateTimer?.invalidate()
    }
}

extension AppUsageTracker {
    func addTag(_ tag: String, toAppWithBundleIdentifier bundleIdentifier: String) {
        if let index = activities.firstIndex(where: { $0.bundleIdentifier == bundleIdentifier }) {
            activities[index].tags.insert(tag)
        }
    }

    func createAndAssignTag(_ tag: String, toAppWithBundleIdentifier bundleIdentifier: String) {
        // This example directly adds a tag, but you could also add logic to check if the tag already exists globally.
        addTag(tag, toAppWithBundleIdentifier: bundleIdentifier)
    }
    func incrementDuration(forBundleIdentifier bundleIdentifier: String) {
            guard let index = activities.firstIndex(where: { $0.bundleIdentifier == bundleIdentifier }) else { return }
            // Increment the duration
            DispatchQueue.main.async {
                self.activities[index].usageDuration += 1
                // To force SwiftUI to notice the change, you might need to replace the object or update the array in a more significant way, depending on your setup.
                // For instance, you could do something like this, but be mindful of performance:
                // self.activities[index] = updatedActivity
            }
        }
}
