import XCTest
@testable import swiftybox

final class HostnameTests: XCTestCase {
    func testHostnameWorks() {
        let result = runCommand("hostname", [])
        XCTAssertEqual(result.exitCode, 0, "hostname should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "hostname should output the system hostname")
        // Output should be a single line (may have trailing newline)
        let trimmed = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(trimmed.isEmpty, "hostname should not be empty")
    }

    func testHostnameShortOption() {
        // hostname -s returns the short hostname (before first dot)
        let result = runCommand("hostname", ["-s"])
        XCTAssertEqual(result.exitCode, 0, "hostname -s should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "hostname -s should output short hostname")

        let shortName = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(shortName.contains("."), "Short hostname should not contain dots")
    }

    func testHostnameDomainOption() {
        // hostname -d returns the domain part (after first dot, or empty if no domain)
        let result = runCommand("hostname", ["-d"])
        XCTAssertEqual(result.exitCode, 0, "hostname -d should succeed")
        // Domain may be empty if hostname has no domain part
        // Just verify it doesn't crash
    }

    func testHostnameFQDN() {
        // hostname -f returns fully qualified domain name
        let result = runCommand("hostname", ["-f"])
        XCTAssertEqual(result.exitCode, 0, "hostname -f should succeed")
        XCTAssertFalse(result.stdout.isEmpty, "hostname -f should output FQDN")
    }

    func testHostnameIPAddress() {
        // hostname -i returns IP address(es)
        let result = runCommand("hostname", ["-i"])
        // This may fail on some systems or require network configuration
        // Just verify it doesn't crash - may return 0 or 1 depending on configuration
        XCTAssertTrue(result.exitCode == 0 || result.exitCode == 1,
                     "hostname -i should exit with 0 or 1")
    }

    func testHostnameConsistency() {
        // Verify that short + domain = fqdn (if domain exists)
        let fullResult = runCommand("hostname", ["-f"])
        let shortResult = runCommand("hostname", ["-s"])
        let domainResult = runCommand("hostname", ["-d"])

        if fullResult.exitCode == 0 && shortResult.exitCode == 0 && domainResult.exitCode == 0 {
            let fqdn = fullResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            let short = shortResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            let domain = domainResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            if !domain.isEmpty {
                // If there's a domain, fqdn should be short.domain
                XCTAssertTrue(fqdn.hasPrefix(short), "FQDN should start with short hostname")
            }
        }
    }
}
