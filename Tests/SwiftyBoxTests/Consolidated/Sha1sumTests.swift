// Sha1sumTests.swift
// Tests for the `sha1sum` command - SHA-1 checksum

import XCTest
@testable import swiftybox

/// Tests for the `sha1sum` command
///
/// IMPLEMENTATION STATUS: NOT IMPLEMENTED
/// The `sha1sum` command is not yet implemented in SwiftyλBox.
/// Note: SHA-256 and SHA-512 are implemented and preferred.
///
/// Expected behavior:
/// - Calculate SHA-1 checksum of files
/// - Note: SHA-1 is deprecated for security use (collisions found)
/// - Prefer sha256sum or sha512sum for security applications
/// - Reference: GNU coreutils sha1sum

final class Sha1sumTests: XCTestCase {

    func testSha1sumNotImplemented() {
        // sha1sum is not implemented
        // Use sha256sum or sha512sum instead (both implemented)
        // XCTExpectFailure("sha1sum not yet implemented - use sha256sum instead")

        // When/if implemented, sha1sum should:
        // - Calculate SHA-1 hash
        // - Support binary/text mode
        // - Support check mode (-c)
        // - Match GNU coreutils output format
    }

    // TODO: Consider whether SHA-1 should be implemented
    // SHA-1 is cryptographically broken (collision attacks exist)
    // SwiftyλBox already has sha256sum and sha512sum which are secure
    // Implementation priority: LOW
}
