// FileOperationTests.swift
// Tests for file operation commands (Phase 6)

import XCTest

final class FileOperationTests: XCTestCase {
    var runner: TestRunner!
    var swiftyboxPath: String {
        let cwd = FileManager.default.currentDirectoryPath
        return "\(cwd)/.build/debug/swiftybox"
    }

    override func setUp() {
        super.setUp()
        runner = TestRunner(verbose: ProcessInfo.processInfo.environment["VERBOSE"] != nil,
                           swiftyboxPath: swiftyboxPath)
    }

    override func tearDown() {
        runner.printSummary()
        XCTAssertEqual(runner.failureCount, 0, "\(runner.failureCount) tests failed")
        super.tearDown()
    }

    // MARK: - ls tests

    func testLs_currentDirectory() {
        // Test that ls produces output
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["ls"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        XCTAssertFalse(output.isEmpty, "ls should produce output")
        XCTAssertEqual(task.terminationStatus, 0)
    }

    func testLs_longFormat() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftyboxPath)
        task.arguments = ["ls", "-l"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        // Long format should include permissions
        XCTAssertTrue(output.contains("r") || output.contains("w") || output.contains("x"),
                     "ls -l should show permissions")
        XCTAssertEqual(task.terminationStatus, 0)
    }

    // MARK: - mkdir/rmdir tests

    func testMkdir_simple() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mkdir-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let testDir = tempDir.appendingPathComponent("testdir")
        runner.testing(
            "mkdir creates directory",
            command: "cd '\(tempDir.path)' && busybox mkdir testdir && test -d testdir",
            expectedOutput: ""
        )
    }

    func testMkdir_parents() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mkdir-p-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        runner.testing(
            "mkdir -p creates parent directories",
            command: "cd '\(tempDir.path)' && busybox mkdir -p a/b/c && test -d a/b/c",
            expectedOutput: ""
        )
    }

    // MARK: - touch tests

    func testTouch_createFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-touch-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        runner.testing(
            "touch creates file",
            command: "cd '\(tempDir.path)' && busybox touch testfile && test -f testfile",
            expectedOutput: ""
        )
    }

    // MARK: - rm tests

    func testRm_singleFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-rm-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let testFile = tempDir.appendingPathComponent("testfile")
        try? "test".write(to: testFile, atomically: true, encoding: .utf8)

        runner.testing(
            "rm removes file",
            command: "cd '\(tempDir.path)' && busybox rm testfile && test ! -f testfile",
            expectedOutput: ""
        )
    }

    // MARK: - cp tests

    func testCp_singleFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-cp-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let srcFile = tempDir.appendingPathComponent("src")
        try? "content".write(to: srcFile, atomically: true, encoding: .utf8)

        runner.testing(
            "cp copies file",
            command: "cd '\(tempDir.path)' && busybox cp src dst && cat dst",
            expectedOutput: "content"
        )
    }

    // MARK: - mv tests

    func testMv_renameFile() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-mv-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let srcFile = tempDir.appendingPathComponent("old")
        try? "content".write(to: srcFile, atomically: true, encoding: .utf8)

        runner.testing(
            "mv renames file",
            command: "cd '\(tempDir.path)' && busybox mv old new && test ! -f old && cat new",
            expectedOutput: "content"
        )
    }

    // MARK: - ln tests

    func testLn_hardLink() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-ln-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let srcFile = tempDir.appendingPathComponent("src")
        try? "content".write(to: srcFile, atomically: true, encoding: .utf8)

        runner.testing(
            "ln creates hard link",
            command: "cd '\(tempDir.path)' && busybox ln src dst && cat dst",
            expectedOutput: "content"
        )
    }

    func testLn_symbolicLink() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-ln-s-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let srcFile = tempDir.appendingPathComponent("src")
        try? "content".write(to: srcFile, atomically: true, encoding: .utf8)

        runner.testing(
            "ln -s creates symbolic link",
            command: "cd '\(tempDir.path)' && busybox ln -s src dst && cat dst",
            expectedOutput: "content"
        )
    }

    // MARK: - chmod tests

    func testChmod_octalMode() {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-chmod-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let testFile = tempDir.appendingPathComponent("testfile")
        try? "test".write(to: testFile, atomically: true, encoding: .utf8)

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        task.arguments = ["-c", "cd '\(tempDir.path)' && \(swiftyboxPath) chmod 755 testfile && test -x testfile"]
        try? task.run()
        task.waitUntilExit()

        XCTAssertEqual(task.terminationStatus, 0, "chmod should set executable bit")
    }
}
