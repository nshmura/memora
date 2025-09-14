//
//  PerformanceTestingView.swift
//  memora
//
//  Created by AI Assistant on 2025-09-14.
//

import SwiftUI

/// Development-only view for performance testing on device
/// This view helps test app performance with large datasets
struct PerformanceTestingView: View {
    @ObservedObject var store: Store
    @State private var isGeneratingCards = false
    @State private var cardCount = 100
    @State private var testResults: [String] = []
    @State private var memoryUsage: Float = 0
    @State private var storageSpace: Int64 = 0
    @State private var showingResults = false
    
    let reporter = DeviceTestReporter()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Device Performance Testing")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Device Info Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Device Information")
                        .font(.headline)
                    
                    let deviceInfo = DeviceTestingUtils.getDeviceInfo()
                    ForEach(Array(deviceInfo.keys.sorted()), id: \.self) { key in
                        HStack {
                            Text("\(key.replacingOccurrences(of: "_", with: " ").capitalized):")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(deviceInfo[key] ?? "N/A")")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Performance Metrics
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Metrics")
                        .font(.headline)
                    
                    HStack {
                        Text("Memory Usage:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(String(format: "%.1f", memoryUsage)) MB")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Storage Available:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(ByteCountFormatter.string(fromByteCount: storageSpace, countStyle: .file))")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Cards in Database:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(store.cards.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                // Test Controls
                VStack(spacing: 15) {
                    Text("Performance Tests")
                        .font(.headline)
                    
                    HStack {
                        Text("Cards to Generate:")
                        Spacer()
                        TextField("Count", value: $cardCount, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    Button(action: generateTestCards) {
                        HStack {
                            if isGeneratingCards {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "plus.circle.fill")
                            }
                            Text(isGeneratingCards ? "Generating..." : "Generate Test Cards")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isGeneratingCards ? Color.gray : Color.green)
                        .cornerRadius(10)
                    }
                    .disabled(isGeneratingCards)
                    
                    Button(action: runPerformanceTests) {
                        HStack {
                            Image(systemName: "stopwatch.fill")
                            Text("Run Performance Tests")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                    
                    Button(action: clearAllCards) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Clear All Cards")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
                
                // Test Results
                if !testResults.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Test Results")
                            .font(.headline)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 5) {
                                ForEach(Array(testResults.enumerated()), id: \.offset) { index, result in
                                    Text(result)
                                        .font(.caption2)
                                        .foregroundColor(result.contains("✅") ? .green : result.contains("❌") ? .red : .primary)
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                        
                        Button("Export Results") {
                            exportResults()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Device Testing")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                updateMetrics()
            }
            .sheet(isPresented: $showingResults) {
                TestResultsView(reporter: reporter)
            }
        }
    }
    
    // MARK: - Test Actions
    
    private func generateTestCards() {
        isGeneratingCards = true
        testResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let startTime = CFAbsoluteTimeGetCurrent()
            let startMemory = DeviceTestingUtils.getCurrentMemoryUsage()
            
            let testCards = DeviceTestingUtils.generateTestCards(count: cardCount)
            
            DispatchQueue.main.async {
                for card in testCards {
                    store.addCard(card)
                }
                
                let endTime = CFAbsoluteTimeGetCurrent()
                let endMemory = DeviceTestingUtils.getCurrentMemoryUsage()
                let duration = endTime - startTime
                let memoryIncrease = endMemory - startMemory
                
                let result = "✅ Generated \(cardCount) cards in \(String(format: "%.2f", duration))s (Memory: +\(String(format: "%.1f", memoryIncrease))MB)"
                testResults.append(result)
                
                reporter.addResult(
                    testName: "Card Generation Performance",
                    passed: duration < 5.0, // Should complete within 5 seconds
                    details: "Generated \(cardCount) cards in \(String(format: "%.2f", duration))s, memory increased by \(String(format: "%.1f", memoryIncrease))MB"
                )
                
                isGeneratingCards = false
                updateMetrics()
            }
        }
    }
    
    private func runPerformanceTests() {
        testResults.removeAll()
        
        // Test 1: List Scrolling Performance
        testListScrolling()
        
        // Test 2: Search Performance
        testSearchPerformance()
        
        // Test 3: Study Session Performance
        testStudySessionPerformance()
        
        // Test 4: Data Persistence Performance
        testDataPersistence()
        
        showingResults = true
    }
    
    private func testListScrolling() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate rapid scrolling by accessing different parts of the card array
        for i in stride(from: 0, to: min(store.cards.count, 100), by: 10) {
            _ = store.cards.dropFirst(i).prefix(10)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        let passed = duration < 0.1
        let result = passed ? "✅" : "❌"
        testResults.append("\(result) List scrolling test: \(String(format: "%.3f", duration))s")
        
        reporter.addResult(
            testName: "List Scrolling Performance",
            passed: passed,
            details: "Scrolling simulation completed in \(String(format: "%.3f", duration))s"
        )
    }
    
    private func testSearchPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate search operations
        let searchTerms = ["Test", "Question", "Answer", "Lorem"]
        for term in searchTerms {
            _ = store.cards.filter { $0.front.contains(term) || $0.back.contains(term) }
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        let passed = duration < 0.5
        let result = passed ? "✅" : "❌"
        testResults.append("\(result) Search performance test: \(String(format: "%.3f", duration))s")
        
        reporter.addResult(
            testName: "Search Performance",
            passed: passed,
            details: "Search operations completed in \(String(format: "%.3f", duration))s"
        )
    }
    
    private func testStudySessionPerformance() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate study session with first 20 cards
        let testCards = Array(store.cards.prefix(20))
        for card in testCards {
            var updatedCard = card
            updatedCard.stepIndex = min(updatedCard.stepIndex + 1, 6)
            store.updateCard(updatedCard)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        let passed = duration < 1.0
        let result = passed ? "✅" : "❌"
        testResults.append("\(result) Study session test: \(String(format: "%.3f", duration))s")
        
        reporter.addResult(
            testName: "Study Session Performance",
            passed: passed,
            details: "Study session simulation with 20 cards completed in \(String(format: "%.3f", duration))s"
        )
    }
    
    private func testDataPersistence() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Force save operation
        store.saveData()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        let passed = duration < 2.0
        let result = passed ? "✅" : "❌"
        testResults.append("\(result) Data persistence test: \(String(format: "%.3f", duration))s")
        
        reporter.addResult(
            testName: "Data Persistence Performance",
            passed: passed,
            details: "Data save operation completed in \(String(format: "%.3f", duration))s"
        )
    }
    
    private func clearAllCards() {
        store.clearAllData()
        testResults.append("🗑️ All cards cleared")
        updateMetrics()
    }
    
    private func updateMetrics() {
        memoryUsage = DeviceTestingUtils.getCurrentMemoryUsage()
        storageSpace = DeviceTestingUtils.getAvailableStorageSpace()
    }
    
    private func exportResults() {
        if let data = reporter.exportResults() {
            // In a real implementation, you would use UIActivityViewController
            // or share the data via email/files app
            print("Test results exported")
            print(reporter.generateReport())
        }
    }
}

// MARK: - Test Results View

struct TestResultsView: View {
    let reporter: DeviceTestReporter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(reporter.generateReport())
                    .font(.system(.caption, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Test Results")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") { dismiss() },
                trailing: Button("Share") { shareResults() }
            )
        }
    }
    
    private func shareResults() {
        // Implementation for sharing results
        // Would use UIActivityViewController in real app
    }
}

#if DEBUG
struct PerformanceTestingView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceTestingView(store: Store())
    }
}
#endif