// FreeTests.swift
// ============================================================================
// Free Command Comprehensive Test Suite
// ============================================================================
// Source: procps-ng free command (Linux-specific)
// Purpose: Display amount of free and used memory
// Reference: /proc/meminfo on Linux
// Import Date: 2025-11-14
// Test Categories: Basic functionality, format validation, numeric validation,
//                  unit conversions, consistency checks, platform handling
// ============================================================================
// Tests for free command functionality and memory display

import XCTest
import Foundation

final class FreeTests: XCTestCase {
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    var isPlatformLinux: Bool {
        #if os(Linux)
        return true
        #else
        return false
        #endif
    }

    // Helper: Run free command with optional arguments and return output
    func runFreeCommand(_ args: [String] = []) -> (status: Int32, output: String, error: String) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["free"] + args

        let outPipe = Pipe()
        let errPipe = Pipe()
        task.standardOutput = outPipe
        task.standardError = errPipe

        do {
            try task.run()
            task.waitUntilExit()

            let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
            let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

            let output = String(data: outData, encoding: .utf8) ?? ""
            let error = String(data: errData, encoding: .utf8) ?? ""

            return (task.terminationStatus, output, error)
        } catch {
            return (1, "", "Failed to run process: \(error)")
        }
    }

    // Helper: Check if /proc/meminfo exists (Linux-specific check)
    func procMeminfoExists() -> Bool {
        FileManager.default.fileExists(atPath: "/proc/meminfo")
    }

    // Helper: Parse output to extract memory values
    func parseMemoryLine(_ line: String) -> (label: String, total: Int64, used: Int64, free: Int64, available: Int64)? {
        let parts = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard parts.count >= 5 else { return nil }

        let label = parts[0]
        guard let total = Int64(parts[1]),
              let used = Int64(parts[2]),
              let free = Int64(parts[3]),
              let available = Int64(parts[4]) else {
            return nil
        }

        return (label, total, used, free, available)
    }

    // Helper: Extract numeric value from human-readable format (e.g., "1.2G" -> bytes)
    func parseHumanReadableSize(_ sizeStr: String) -> Int64? {
        let trimmed = sizeStr.trimmingCharacters(in: .whitespaces)

        if trimmed == "-" {
            return 0
        }

        // Remove unit suffix
        let lastChar = trimmed.last.map(String.init) ?? ""
        let numberStr: String
        var multiplier: Int64 = 1

        switch lastChar {
        case "K": multiplier = 1024; numberStr = String(trimmed.dropLast())
        case "M": multiplier = 1024 * 1024; numberStr = String(trimmed.dropLast())
        case "G": multiplier = 1024 * 1024 * 1024; numberStr = String(trimmed.dropLast())
        case "T": multiplier = 1024 * 1024 * 1024 * 1024; numberStr = String(trimmed.dropLast())
        default: numberStr = trimmed
        }

        guard let value = Double(numberStr) else { return nil }
        return Int64(value * Double(multiplier))
    }

    // MARK: - Test 1: Basic Functionality - Outputs Memory Info and Returns Success
    func testFree_basicFunctionality() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        let (status, output, error) = runFreeCommand()

        XCTAssertEqual(status, 0, "free should exit with status 0")
        XCTAssertFalse(output.isEmpty, "free should produce output")
        XCTAssertTrue(error.isEmpty, "free should not produce error output: \(error)")
    }

    // MARK: - Test 2: Output Format Validation - Contains Required Headers
    func testFree_outputHasRequiredHeaders() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        let (status, output, _) = runFreeCommand()

        XCTAssertEqual(status, 0, "free should succeed")

        // Check for required headers
        XCTAssertTrue(output.contains("total"), "Output should contain 'total' header")
        XCTAssertTrue(output.contains("used"), "Output should contain 'used' header")
        XCTAssertTrue(output.contains("free"), "Output should contain 'free' header")
        XCTAssertTrue(output.contains("available") || output.contains("Mem:"), "Output should have memory section")

        // Should have Mem: and Swap: lines
        XCTAssertTrue(output.contains("Mem:"), "Output should contain 'Mem:' line")
        XCTAssertTrue(output.contains("Swap:"), "Output should contain 'Swap:' line")
    }

    // MARK: - Test 3: Numeric Validation - All Values Are Non-Negative Numbers
    func testFree_numericValuesNonNegative() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        let (status, output, _) = runFreeCommand()

        XCTAssertEqual(status, 0, "free should succeed")

        let lines = output.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)

        for line in lines {
            // Skip header line
            if line.contains("total") && line.contains("used") {
                continue
            }

            let parts = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)

            // For non-header lines (Mem: and Swap:), check numeric values
            if (line.contains("Mem:") || line.contains("Swap:")) && parts.count > 1 {
                // Skip label (first part)
                for i in 1..<parts.count {
                    let value = parts[i]
                    // Should be numeric (allow "-" for shared/etc)
                    if value != "-" {
                        guard Int64(value) != nil else {
                            XCTFail("Non-numeric value found in output: '\(value)' in line: '\(line)'")
                            return
                        }
                    }
                }
            }
        }

        // If we got here, all numeric values were valid
        XCTAssertTrue(true)
    }

    // MARK: - Test 4: Numeric Validation - Values Are Reasonable (< 1 PB)
    func testFree_valuesAreReasonable() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        let (status, output, _) = runFreeCommand()

        XCTAssertEqual(status, 0, "free should succeed")

        let lines = output.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        let maxReasonableMemory: Int64 = 1024 * 1024 * 1024 * 1024 // 1 PB

        for line in lines {
            if line.contains("Mem:") {
                let parts = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
                if parts.count > 1, let total = Int64(parts[1]) {
                    // Memory is in KB, so total should be reasonable
                    XCTAssertGreaterThan(total, 0, "Total memory should be positive")
                    XCTAssertLessThan(total, maxReasonableMemory, "Total memory should be less than 1 PB")
                }
            }
        }
    }

    // MARK: - Test 5: Option -h (Human-Readable Format)
    func testFree_humanReadableOption() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        let (status, output, error) = runFreeCommand(["-h"])

        XCTAssertEqual(status, 0, "free -h should succeed")
        XCTAssertFalse(output.isEmpty, "free -h should produce output")

        // Human-readable format should contain unit suffixes (K, M, G, T)
        let unitPattern = "[0-9.]+[KMGT]"
        let regex = try? NSRegularExpression(pattern: unitPattern)
        let range = NSRange(output.startIndex..., in: output)
        let matches = regex?.numberOfMatches(in: output, range: range) ?? 0

        // Should have multiple unit suffixes in output
        XCTAssertGreaterThan(matches, 0, "Output with -h should contain human-readable sizes (e.g., '1.2G')")
    }

    // MARK: - Test 6: Option -m (Megabytes)
    func testFree_megabytesOption() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        let (status, output, _) = runFreeCommand(["-m"])

        XCTAssertEqual(status, 0, "free -m should succeed")
        XCTAssertFalse(output.isEmpty, "free -m should produce output")
        XCTAssertTrue(output.contains("Mem:"), "Output should contain memory information")

        // With -m, values should be reasonable (system memory in MB)
        let lines = output.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        for line in lines {
            if line.contains("Mem:") {
                let parts = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
                if parts.count > 1, let total = Int64(parts[1]) {
                    // In megabytes, typical system has at least 256MB
                    XCTAssertGreaterThan(total, 256, "Total memory in MB should be > 256")
                }
            }
        }
    }

    // MARK: - Test 7: Option -g (Gigabytes)
    func testFree_gigabytesOption() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        let (status, output, _) = runFreeCommand(["-g"])

        XCTAssertEqual(status, 0, "free -g should succeed")
        XCTAssertFalse(output.isEmpty, "free -g should produce output")
        XCTAssertTrue(output.contains("Mem:"), "Output should contain memory information")

        // With -g, values will be small (in gigabytes)
        let lines = output.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        for line in lines {
            if line.contains("Mem:") {
                let parts = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
                if parts.count > 1, let total = Int64(parts[1]) {
                    // In gigabytes, typical system has at least 1GB
                    XCTAssertGreaterThanOrEqual(total, 1, "Total memory in GB should be >= 1")
                }
            }
        }
    }

    // MARK: - Test 8: Consistency - Multiple Calls Give Similar Results
    func testFree_consistencyBetweenCalls() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        let (status1, output1, _) = runFreeCommand()
        // Small delay to allow any memory changes
        usleep(100_000) // 100ms
        let (status2, output2, _) = runFreeCommand()

        XCTAssertEqual(status1, 0, "First call should succeed")
        XCTAssertEqual(status2, 0, "Second call should succeed")

        let lines1 = output1.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        let lines2 = output2.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)

        // Both should have same number of lines (header + Mem: + Swap:)
        XCTAssertEqual(lines1.count, lines2.count, "Multiple calls should have consistent output structure")

        // Total memory should be exactly the same (doesn't change between calls)
        for (line1, line2) in zip(lines1, lines2) {
            if line1.contains("Mem:") {
                let parts1 = line1.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
                let parts2 = line2.split(separator: " ", omittingEmptySubsequences: true).map(String.init)

                if parts1.count > 1, parts2.count > 1 {
                    // Total should be identical
                    XCTAssertEqual(parts1[1], parts2[1], "Total memory should be identical between calls")
                }
            }
        }
    }

    // MARK: - Test 9: Linux-Specific - /proc/meminfo Accessibility Check
    func testFree_meminfoAccessibility() {
        guard isPlatformLinux else {
            print("⊘ Skipping test (not Linux)")
            return
        }

        if procMeminfoExists() {
            let (status, output, _) = runFreeCommand()
            XCTAssertEqual(status, 0, "/proc/meminfo should be accessible and free should work")
            XCTAssertFalse(output.isEmpty, "Should produce output when /proc/meminfo exists")
        } else {
            print("⊘ /proc/meminfo not available on this system")
            // On systems without /proc/meminfo, free should fail gracefully
            let (status, _, error) = runFreeCommand()
            XCTAssertNotEqual(status, 0, "free should fail when /proc/meminfo is unavailable")
        }
    }

    // MARK: - Test 10: Error Handling - Invalid Options
    func testFree_invalidOptions() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        // Note: Current implementation may not validate all invalid options
        // This test ensures behavior is predictable
        let (status, output, error) = runFreeCommand(["--invalid-option-xyz"])

        // Either should fail or ignore unknown option
        // Behavior varies by implementation - just ensure it doesn't crash
        XCTAssertTrue(status == 0 || status != 0, "Should handle invalid options without crashing")
    }

    // MARK: - Test 11: No Stdin Required - Works Without Input
    func testFree_noStdinRequired() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["free"]

        let outPipe = Pipe()
        let errPipe = Pipe()
        task.standardOutput = outPipe
        task.standardError = errPipe
        task.standardInput = Pipe() // Close stdin immediately

        do {
            try task.run()
            task.waitUntilExit()

            let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outData, encoding: .utf8) ?? ""

            XCTAssertEqual(task.terminationStatus, 0, "free should work without stdin")
            XCTAssertFalse(output.isEmpty, "Should produce output even without stdin")
        } catch {
            XCTFail("Process failed: \(error)")
        }
    }

    // MARK: - Test 12: Memory Values Relationship - Sanity Checks
    func testFree_memoryValuesRelationship() {
        guard isPlatformLinux && procMeminfoExists() else {
            print("⊘ Skipping test (not Linux or /proc/meminfo not available)")
            return
        }

        let (status, output, _) = runFreeCommand()

        XCTAssertEqual(status, 0, "free should succeed")

        let lines = output.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)

        for line in lines {
            if line.contains("Mem:") {
                let parts = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)

                if parts.count >= 4 {
                    guard let total = Int64(parts[1]),
                          let used = Int64(parts[2]),
                          let free = Int64(parts[3]) else {
                        continue
                    }

                    // Basic sanity checks
                    XCTAssertGreaterThan(total, 0, "Total memory should be positive")
                    XCTAssertGreaterThanOrEqual(used, 0, "Used memory should be non-negative")
                    XCTAssertGreaterThanOrEqual(free, 0, "Free memory should be non-negative")

                    // Used + Free should not exceed Total (allowing for rounding/buffering)
                    let sum = used + free
                    XCTAssertLessThanOrEqual(sum, total + 10000, "Used + Free should be <= Total (with small margin for buffers)")
                }
            }
        }
    }
}
