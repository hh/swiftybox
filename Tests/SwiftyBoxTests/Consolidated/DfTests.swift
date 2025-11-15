import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `df` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils df (report filesystem disk space usage)
/// - Output: Filesystem, Size, Used, Avail, Use%, Mounted on
/// - Common options: -h (human-readable), -i (inodes), -T (type), -a (all)
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/df-invocation.html
/// - POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/df.html

final class DfTests: XCTestCase {

    // MARK: - Basic Tests

    func testDfBasic() {
        let result = runCommand("df", [])

        XCTAssertEqual(result.exitCode, 0, "df should succeed")
        XCTAssertTrue(result.stdout.contains("Filesystem") || result.stdout.contains("/"),
                     "Should show filesystem info")
    }

    func testDfSpecificPath() {
        let result = runCommand("df", ["/"])

        XCTAssertEqual(result.exitCode, 0, "df should succeed on /")
        XCTAssertTrue(result.stdout.contains("/"), "Should show root filesystem")
    }

    func testDfMultiplePaths() {
        let result = runCommand("df", ["/", "/tmp"])

        XCTAssertEqual(result.exitCode, 0, "df should succeed on multiple paths")

        let lines = result.stdout.split(separator: "\n")
        XCTAssertGreaterThan(lines.count, 1, "Should show multiple filesystems")
    }

    func testDfHumanReadable() {
        let result = runCommand("df", ["-h"])

        if result.exitCode == 0 {
            // -h option is supported
            XCTAssertTrue(result.stdout.contains("K") ||
                         result.stdout.contains("M") ||
                         result.stdout.contains("G") ||
                         result.stdout.contains("T"),
                         "Human-readable should show K/M/G/T suffixes")
        } else {
            XCTAssertTrue(result.stderr.contains("invalid option") ||
                         result.stderr.contains("unrecognized"))
        }
    }

    func testDfInodes() {
        let result = runCommand("df", ["-i"])

        if result.exitCode == 0 {
            // -i option is supported
            XCTAssertTrue(result.stdout.contains("Inode") || result.stdout.contains("IUsed"),
                         "Should show inode information")
        }
    }

    func testDfFilesystemType() {
        let result = runCommand("df", ["-T"])

        if result.exitCode == 0 {
            // -T option is supported
            XCTAssertTrue(result.stdout.contains("Type") ||
                         result.stdout.contains("ext4") ||
                         result.stdout.contains("tmpfs") ||
                         result.stdout.contains("xfs"),
                         "Should show filesystem types")
        }
    }

    func testDfShowAll() {
        let result = runCommand("df", ["-a"])

        if result.exitCode == 0 {
            // -a option is supported
            let lines = result.stdout.split(separator: "\n")
            XCTAssertGreaterThan(lines.count, 2,
                                "With -a should show more filesystems (including pseudo filesystems)")
        }
    }

    func testDfNonexistentPath() {
        let result = runCommand("df", ["/tmp/nonexistent-\(UUID().uuidString)"])

        XCTAssertNotEqual(result.exitCode, 0, "df should fail on nonexistent path")
        XCTAssertTrue(result.stderr.contains("No such file") || result.stderr.contains("not found"))
    }

    func testDfOutputFormat() {
        let result = runCommand("df", ["/"])

        XCTAssertEqual(result.exitCode, 0)

        let lines = result.stdout.split(separator: "\n")
        XCTAssertGreaterThan(lines.count, 0, "Should have output")

        // Should have columns: Filesystem, Size, Used, Avail, Use%, Mounted
        // At minimum should have space-separated values
        if let dataLine = lines.last {
            let parts = dataLine.split(separator: " ", omittingEmptySubsequences: true)
            XCTAssertGreaterThan(parts.count, 3,
                                "Should have multiple columns (filesystem, size, used, etc.)")
        }
    }

    // MARK: - TODO: Advanced Features
    // - [ ] df --total (show grand total) - P2
    // - [ ] df -B SIZE (block size) - P2
    // - [ ] df -t TYPE (limit to filesystem type) - P2
    // - [ ] df -x TYPE (exclude filesystem type) - P2
    // - [ ] df --output=FIELD_LIST (custom fields) - P2
}
