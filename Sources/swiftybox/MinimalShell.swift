import Foundation

/// Minimal shell demonstrating NOFORK command execution
/// This shows the λ (lambda) concept without full ASH integration
struct MinimalShell {
    let registry: CommandRegistry

    init() {
        self.registry = CommandRegistry(preferredImpl: .swift)
    }

    /// Run a simple REPL shell
    func run() {
        print("SwiftyλBox Mini Shell (NOFORK mode)")
        print("Type commands to execute them as direct function calls")
        print("Type 'exit' to quit\n")

        while true {
            // Print prompt
            print("λ> ", terminator: "")
            FileHandle.standardOutput.synchronizeFile()

            // Read input
            guard let line = readLine() else {
                break
            }

            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                continue
            }

            if trimmed == "exit" || trimmed == "quit" {
                break
            }

            // Parse command and args
            let parts = trimmed.split(separator: " ").map(String.init)
            guard let command = parts.first else {
                continue
            }

            // NOFORK EXECUTION: Direct function call!
            let start = DispatchTime.now()
            let exitCode = registry.execute(command: command, args: parts)
            let end = DispatchTime.now()

            let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
            let micros = Double(nanos) / 1000.0

            if exitCode != 0 {
                print("[Exit code: \(exitCode), Time: \(String(format: "%.2f", micros))μs]")
            }
        }

        print("\nGoodbye!")
    }

    /// Run a batch of commands for benchmarking
    func benchmark(command: String, args: [String], iterations: Int) {
        print("Benchmarking NOFORK execution...")
        print("Command: \(([command] + args).joined(separator: " "))")
        print("Iterations: \(iterations)\n")

        // Redirect stdout to /dev/null during benchmark
        let savedStdout = dup(STDOUT_FILENO)
        let devNull = open("/dev/null", O_WRONLY)
        dup2(devNull, STDOUT_FILENO)
        close(devNull)

        let start = DispatchTime.now()

        for _ in 0..<iterations {
            _ = registry.execute(command: command, args: [command] + args)
        }

        let end = DispatchTime.now()

        // Restore stdout
        dup2(savedStdout, STDOUT_FILENO)
        close(savedStdout)

        let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
        let millis = Double(nanos) / 1_000_000.0
        let perCall = Double(nanos) / Double(iterations) / 1000.0  // microseconds

        print("Total time: \(String(format: "%.2f", millis))ms")
        print("Per-call: \(String(format: "%.2f", perCall))μs")
        print("Throughput: \(Int(Double(iterations) / (millis / 1000.0))) calls/sec")
    }
}
