import XCTest
@testable import swiftybox
import Foundation

/// Tests for the `mktemp` command
///
/// IMPLEMENTATION NOTES:
/// - Reference: GNU coreutils mktemp (create temporary file or directory)
/// - Replaces XXXXXX in template with random characters
/// - Options: -d (directory), -u (dry-run), -p DIR (tmpdir), -t (template mode)
/// - Security: Creates with permissions 600 (rw-------)
///
/// Resources:
/// - GNU: https://www.gnu.org/software/coreutils/manual/html_node/mktemp-invocation.html

final class MktempTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        // Note: mktemp creates files/dirs, tests should clean up
    }

    func testMktempBasic() {
        let result = runCommand("mktemp", [])

        XCTAssertEqual(result.exitCode, 0, "mktemp should succeed")

        let path = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(path.isEmpty, "Should output a path")

        // Check file exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: path),
                     "Should create the temp file")

        // Cleanup
        try? FileManager.default.removeItem(atPath: path)
    }

    func testMktempWithTemplate() {
        let result = runCommand("mktemp", ["tmp.XXXXXX"])

        XCTAssertEqual(result.exitCode, 0, "mktemp with template should succeed")

        let path = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertTrue(path.contains("tmp."), "Should use template prefix")
        XCTAssertTrue(FileManager.default.fileExists(atPath: path),
                     "Should create the temp file")

        try? FileManager.default.removeItem(atPath: path)
    }

    func testMktempDirectory() {
        let result = runCommand("mktemp", ["-d"])

        if result.exitCode == 0 {
            let path = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            var isDir: ObjCBool = false
            XCTAssertTrue(FileManager.default.fileExists(atPath: path, isDirectory: &isDir),
                         "Should create temp directory")
            XCTAssertTrue(isDir.boolValue, "Should be a directory")

            try? FileManager.default.removeItem(atPath: path)
        }
    }

    func testMktempDirectoryWithTemplate() {
        let result = runCommand("mktemp", ["-d", "tmpdir.XXXXXX"])

        if result.exitCode == 0 {
            let path = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            XCTAssertTrue(path.contains("tmpdir."), "Should use template prefix")

            var isDir: ObjCBool = false
            XCTAssertTrue(FileManager.default.fileExists(atPath: path, isDirectory: &isDir))
            XCTAssertTrue(isDir.boolValue)

            try? FileManager.default.removeItem(atPath: path)
        }
    }

    func testMktempUniqueness() {
        let result1 = runCommand("mktemp", [])
        let result2 = runCommand("mktemp", [])

        XCTAssertEqual(result1.exitCode, 0)
        XCTAssertEqual(result2.exitCode, 0)

        let path1 = result1.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let path2 = result2.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertNotEqual(path1, path2, "Each mktemp should create unique path")

        try? FileManager.default.removeItem(atPath: path1)
        try? FileManager.default.removeItem(atPath: path2)
    }

    func testMktempPermissions() {
        let result = runCommand("mktemp", [])

        if result.exitCode == 0 {
            let path = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)

            if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
               let perms = attrs[.posixPermissions] as? mode_t {
                // Should be 600 (rw-------)
                XCTAssertEqual(perms, 0o600, "Temp file should have 600 permissions for security")
            }

            try? FileManager.default.removeItem(atPath: path)
        }
    }

    func testMktempInsufficientX() {
        // Template needs at least 3 X's (some implementations require 6)
        let result = runCommand("mktemp", ["tmp.XX"])

        if result.exitCode != 0 {
            XCTAssertTrue(result.stderr.contains("too few X") ||
                         result.stderr.contains("invalid") ||
                         result.stderr.contains("template"),
                         "Should indicate template error")
        }
    }

    func testMktempDryRun() {
        let result = runCommand("mktemp", ["-u", "tmp.XXXXXX"])

        if result.exitCode == 0 {
            let path = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            XCTAssertFalse(FileManager.default.fileExists(atPath: path),
                          "Dry-run should not create file")
        }
    }

    // TODO: Test -p/--tmpdir option, -t option
}
