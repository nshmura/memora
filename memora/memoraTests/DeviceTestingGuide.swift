//
//  DeviceTestingGuide.swift
//  memora
//
//  Created by AI Assistant on 2025-09-14.
//

/*
 DEVICE TESTING GUIDE
 ====================
 
 This guide provides comprehensive steps for testing the Memora app on a real iOS device.
 Follow these steps in order to validate all functionality works correctly on physical hardware.
 
 PREREQUISITES:
 1. Xcode project configured for device deployment
 2. Valid Apple Developer account and provisioning profile
 3. Physical iPhone/iPad running iOS 16.0 or later
 4. Device connected to Mac and trusted in Xcode
 
 TEST PLAN:
 
 ## Phase 1: Initial Setup & App Launch
 
 1. Clean build and install app on device:
    - Select physical device in Xcode
    - Run: Product → Clean Build Folder
    - Run: Product → Build
    - Run: Product → Run
    - Verify app launches without crashes
    - Check all 3 tabs (Home, Cards, Settings) load properly
 
 2. First Launch Experience:
    - Verify empty state shows correctly
    - Check default settings are loaded
    - Confirm timezone is set to JST (Asia/Tokyo)
 
 ## Phase 2: Notification Permission Testing
 
 3. Notification Permission Request:
    - Go to Settings tab
    - Change notification time
    - Should trigger permission request
    - Test DENY permission:
      * Verify app doesn't crash
      * Check appropriate error handling
      * Confirm alternative UI shows
    - Reset notification permissions in iOS Settings
    - Test ALLOW permission:
      * Verify success message
      * Check notification is scheduled
 
 4. Background Notification Behavior:
    - Set notification time to 1 minute from now
    - Close app completely (swipe up, swipe away)
    - Wait for notification to arrive
    - Verify notification content is correct
    - Tap notification to open app
    - Confirm app opens to appropriate view
 
 ## Phase 3: Core Functionality Testing
 
 5. Card Management:
    - Add 10+ cards with various lengths of text
    - Edit existing cards
    - Delete cards
    - Verify all operations persist after app restart
 
 6. Study Flow:
    - Start study session from Home
    - Answer questions correctly and incorrectly
    - Complete full study session
    - Verify progress updates correctly
    - Check next due dates are calculated properly
 
 7. Data Persistence:
    - Force close app during study session
    - Reopen app
    - Verify data is preserved
    - Complete interrupted study session
 
 ## Phase 4: Performance & Stress Testing
 
 8. Large Dataset Performance:
    - Add 100+ cards (use script if available)
    - Test app responsiveness during:
      * Card list scrolling
      * Search functionality
      * Study session with large dataset
    - Monitor memory usage in Xcode
    - Verify no crashes under load
 
 9. Date/Time Edge Cases:
    - Set device time to 23:58 JST
    - Add cards and start study
    - Let time cross midnight during study
    - Verify date boundaries handle correctly
 
 10. Background/Foreground Transitions:
     - Start study session
     - Switch to other apps
     - Receive phone call during study
     - Return to app and verify state
 
 ## Phase 5: Error Recovery Testing
 
 11. Storage Error Simulation:
     - Fill device storage to near capacity
     - Try to add new cards
     - Verify graceful error handling
 
 12. Network Interruption:
     - Disable Wi-Fi and cellular
     - Use app (should work offline)
     - Re-enable network
     - Verify no issues
 
 ## Phase 6: Accessibility & Usability
 
 13. Accessibility Features:
     - Enable VoiceOver
     - Navigate through all screens
     - Verify proper accessibility labels
     - Test with larger text sizes
 
 14. Different Device Orientations:
     - Test all screens in portrait/landscape
     - Verify layouts adapt properly
     - Check no UI elements are cut off
 
 ## Phase 7: Final Validation
 
 15. End-to-End User Journey:
     - Simulate complete new user experience
     - Add cards → Study → Set notifications → Wait for notification
     - Complete multi-day usage cycle
     - Verify streak counting works
 
 16. App Store Readiness:
     - Check app metadata and icons
     - Verify privacy permissions are properly described
     - Test app on multiple device sizes
 
 EXPECTED RESULTS:
 - No crashes or hangs during any operations
 - All data persists correctly across app launches
 - Notifications work reliably with proper permissions
 - Performance remains smooth with large datasets
 - Error states are handled gracefully
 - UI remains responsive under all conditions
 
 REPORTING ISSUES:
 For each issue found:
 1. Record device model and iOS version
 2. Note exact steps to reproduce
 3. Capture screenshots/screen recordings
 4. Check console logs in Xcode for errors
 5. Verify issue occurs consistently
 
 */

import Foundation
import UIKit
import UserNotifications

// Import required for mach_task_basic_info
import Darwin.Mach

// MARK: - Device Testing Utilities

/// Utility class for device testing and validation
class DeviceTestingUtils {
    
    // MARK: - Device Info
    
    /// Get current device information for testing reports
    static func getDeviceInfo() -> [String: Any] {
        let device = UIDevice.current
        return [
            "device_model": device.model,
            "device_name": device.name,
            "system_name": device.systemName,
            "system_version": device.systemVersion,
            "device_uuid": device.identifierForVendor?.uuidString ?? "unknown",
            "timezone": TimeZone.current.identifier,
            "locale": Locale.current.identifier
        ]
    }
    
    // MARK: - Performance Testing
    
    /// Generate test cards for performance testing
    static func generateTestCards(count: Int) -> [Card] {
        var cards: [Card] = []
        for i in 1...count {
            let card = Card(
                front: "Test Question \(i): What is the answer to question number \(i)?",
                back: "Answer \(i): This is the detailed answer to question \(i). Lorem ipsum dolor sit amet, consectetur adipiscing elit."
            )
            cards.append(card)
        }
        return cards
    }
    
    // MARK: - Notification Testing
    
    /// Check current notification authorization status
    static func checkNotificationPermission(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    /// Check pending notifications
    static func checkPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    // MARK: - Memory Testing
    
    /// Get current memory usage for performance monitoring
    static func getCurrentMemoryUsage() -> Float {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Float(info.resident_size) / 1024.0 / 1024.0 // MB
        }
        return 0
    }
    
    // MARK: - Storage Testing
    
    /// Get available storage space
    static func getAvailableStorageSpace() -> Int64 {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let values = try documentsPath.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            return values.volumeAvailableCapacity ?? 0
        } catch {
            return 0
        }
    }
    
    // MARK: - Accessibility Testing
    
    /// Check if accessibility features are enabled
    static func getAccessibilityInfo() -> [String: Any] {
        return [
            "voice_over_enabled": UIAccessibility.isVoiceOverRunning,
            "switch_control_enabled": UIAccessibility.isSwitchControlRunning,
            "reduce_motion_enabled": UIAccessibility.isReduceMotionEnabled,
            "bold_text_enabled": UIAccessibility.isBoldTextEnabled,
            "larger_text_enabled": UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
        ]
    }
}

// MARK: - Device Test Results

/// Structure to capture test results
struct DeviceTestResult {
    let testName: String
    let passed: Bool
    let details: String
    let timestamp: Date
    let deviceInfo: [String: Any]
    
    func toDictionary() -> [String: Any] {
        return [
            "test_name": testName,
            "passed": passed,
            "details": details,
            "timestamp": ISO8601DateFormatter().string(from: timestamp),
            "device_info": deviceInfo
        ]
    }
}

// MARK: - Test Reporter

/// Utility to collect and report test results
class DeviceTestReporter {
    private var results: [DeviceTestResult] = []
    
    func addResult(testName: String, passed: Bool, details: String = "") {
        let result = DeviceTestResult(
            testName: testName,
            passed: passed,
            details: details,
            timestamp: Date(),
            deviceInfo: DeviceTestingUtils.getDeviceInfo()
        )
        results.append(result)
    }
    
    func generateReport() -> String {
        let passedCount = results.filter { $0.passed }.count
        let totalCount = results.count
        let successRate = totalCount > 0 ? Double(passedCount) / Double(totalCount) * 100 : 0
        
        var report = """
        DEVICE TESTING REPORT
        ====================
        
        Summary:
        - Total Tests: \(totalCount)
        - Passed: \(passedCount)
        - Failed: \(totalCount - passedCount)
        - Success Rate: \(String(format: "%.1f", successRate))%
        
        Device Info:
        """
        
        if let firstResult = results.first {
            let deviceInfo = firstResult.deviceInfo
            for (key, value) in deviceInfo {
                report += "\n- \(key): \(value)"
            }
        }
        
        report += "\n\nDetailed Results:\n"
        
        for result in results {
            let status = result.passed ? "✅ PASS" : "❌ FAIL"
            report += "\n\(status): \(result.testName)"
            if !result.details.isEmpty {
                report += "\n  Details: \(result.details)"
            }
            report += "\n  Time: \(DateFormatter.localizedString(from: result.timestamp, dateStyle: .none, timeStyle: .medium))"
            report += "\n"
        }
        
        return report
    }
    
    func exportResults() -> Data? {
        let reportData = results.map { $0.toDictionary() }
        return try? JSONSerialization.data(withJSONObject: reportData, options: .prettyPrinted)
    }
}