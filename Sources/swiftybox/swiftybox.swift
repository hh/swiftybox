import Foundation

@main
struct SwiftyBox {
    static func main() {
        var args = CommandLine.arguments

        // Check if we should run as a shell (sh, ash, bash symlinks)
        if ShellMode.shouldRunAsShell() {
            print("SwiftyλBox Shell Mode (\(ShellMode.shellName()))")
            #if SWIFT_ASH_INTEGRATION
            print("✓ Swift commands integrated as ASH built-ins (NOFORK)")
            print("✓ BusyBox built-ins available")
            print("✓ External commands via fork+exec\n")
            #else
            print("✓ Swift commands available via symlinks in /bin")
            print("✓ BusyBox shell with standard built-ins")
            print("✓ External commands via fork+exec\n")
            #endif

            let exitCode = ShellMode.runASH(args: args)
            exit(exitCode)
        }

        // Check for implementation preference flag
        var impl: CommandImpl = .swift
        if let idx = args.firstIndex(of: "--use-busybox") {
            impl = .busybox
            args.remove(at: idx)
        } else if let idx = args.firstIndex(of: "--use-swift") {
            impl = .swift
            args.remove(at: idx)
        }

        let registry = CommandRegistry(preferredImpl: impl)

        // Check if we were called via symlink (BusyBox-style)
        let invokedAs = (args[0] as NSString).lastPathComponent

        // If invoked as a command name (not "swiftybox"), execute that command
        if invokedAs != "swiftybox" {
            // Try Swift NOFORK commands first (fastest)
            if registry.hasCommand(invokedAs) {
                let exitCode = registry.execute(command: invokedAs, args: args)
                exit(exitCode)
            }

            // Fall back to BusyBox NOFORK/NOEXEC applets
            if let exitCode = BusyBoxWrappers.runApplet(command: invokedAs, args: args) {
                exit(exitCode)
            }

            // Command not found
            let msg = "swiftybox: \(invokedAs): command not found\n"
            if let data = msg.data(using: .utf8) {
                FileHandle.standardError.write(data)
            }
            exit(127)
        }
        
        // Otherwise, use normal swiftybox behavior
        if args.count == 1 {
            runInteractiveShell(registry: registry)
        } else if args[1] == "--help" || args[1] == "-h" {
            printHelp(registry: registry)
        } else if args[1] == "--version" {
            printVersion(registry: registry)
        } else if args[1] == "--install" {
            installSymlinks()
        } else if args[1] == "--nofork-shell" {
            // Minimal shell demonstrating NOFORK execution
            let shell = MinimalShell()
            shell.run()
        } else if args[1] == "--benchmark" {
            // Benchmark NOFORK performance
            if args.count < 4 {
                print("Usage: swiftybox --benchmark <iterations> <command> [args...]")
                print("Example: swiftybox --benchmark 10000 echo test")
                exit(1)
            }
            guard let iterations = Int(args[2]) else {
                print("Error: iterations must be a number")
                exit(1)
            }
            let command = args[3]
            let cmdArgs = args.count > 4 ? Array(args[4...]) : []
            let shell = MinimalShell()
            shell.benchmark(command: command, args: cmdArgs, iterations: iterations)
        } else {
            // Execute command directly
            let commandName = args[1]
            let commandArgs = Array(args[1...])
            let exitCode = registry.execute(command: commandName, args: commandArgs)
            exit(exitCode)
        }
    }
    
    static func runInteractiveShell(registry: CommandRegistry) {
        print("SwiftyλBox - Where λ replaces fork+exec")
        print("Implementation: \(registry.implDescription())")
        print("Type 'help' for available commands, 'exit' to quit\n")
        
        while true {
            print("swiftybox> ", terminator: "")
            FileHandle.standardOutput.synchronizeFile()
            
            guard let line = readLine() else {
                print()
                break
            }
            
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty {
                continue
            }
            
            if trimmed == "exit" || trimmed == "quit" {
                break
            }
            
            if trimmed == "help" {
                printShellHelp(registry: registry)
                continue
            }
            
            let parts = trimmed.split(separator: " ").map(String.init)
            guard let commandName = parts.first else {
                continue
            }
            
            let exitCode = registry.execute(command: commandName, args: parts)
            
            if exitCode != 0 {
                print("(exit code: \(exitCode))")
            }
        }
        
        print("Goodbye!")
    }
    
    static func printHelp(registry: CommandRegistry) {
        print("""
        SwiftyλBox - A functional reimagining of BusyBox
        
        Usage:
          swiftybox [--use-swift|--use-busybox] <command> [args]
          swiftybox --help             Show this help
          swiftybox --version          Show version
          swiftybox --install          Create symlinks for all commands
        
        Implementation Flags:
          --use-swift      Use pure Swift implementations (default, Phase 1)
          --use-busybox    Use BusyBox C implementations (Phase 2)
        
        Symlink Usage (BusyBox-style):
          ln -s swiftybox echo
          ./echo "Hello!"              # Calls swiftybox via symlink
        
        Available commands:
        """)
        
        for cmd in registry.listCommands() {
            print("  \(cmd)")
        }
        
        print("""
        
        The λ in SwiftyλBox represents lambda calculus:
        Commands are direct function calls, not fork+exec processes!
        """)
    }
    
    static func printShellHelp(registry: CommandRegistry) {
        print("Available commands:")
        for cmd in registry.listCommands() {
            print("  \(cmd)")
        }
        print("\nBuilt-in shell commands:")
        print("  help  - Show this help")
        print("  exit  - Exit the shell")
    }
    
    static func printVersion(registry: CommandRegistry) {
        print("SwiftyλBox version 0.2.0")
        print("Implementation: \(registry.implDescription())")
        print("Phase 2: BusyBox integration + symlink support")
    }
    
    static func installSymlinks() {
        let registry = CommandRegistry()
        let binaryPath = CommandLine.arguments[0]
        let binaryURL = URL(fileURLWithPath: binaryPath)
        let directory = binaryURL.deletingLastPathComponent()

        // All commands to install symlinks for
        let allCommands = [
            // Swift NOFORK built-ins (Tier 1)
            "echo", "pwd", "true", "false",

            // Shell commands
            "sh", "ash", "bash",

            // File operations
            "cat", "ls", "cp", "mv", "rm", "mkdir", "rmdir",
            "touch", "chmod", "chown", "ln",

            // Text processing
            "grep", "sed", "awk", "cut", "sort", "uniq", "wc",
            "head", "tail", "tr", "tee",

            // Archiving
            "tar", "gzip", "gunzip", "bzip2", "bunzip2", "unzip", "zip",

            // File search
            "find", "which", "xargs", "locate",

            // System utils
            "date", "sleep", "env", "printenv", "id", "whoami", "uname",
            "hostname", "uptime", "free", "df", "du",

            // Tests
            "test", "[",

            // Process management
            "kill", "killall", "ps", "top", "pgrep", "pkill",

            // Networking
            "wget", "curl", "nc", "netcat", "ping", "traceroute",
            "ifconfig", "ip", "route",

            // Editors/viewers
            "vi", "vim", "less", "more", "nano",

            // Misc
            "basename", "dirname", "readlink", "realpath",
            "md5sum", "sha256sum",
            "watch", "seq", "yes", "clear", "reset"
        ]

        print("SwiftyλBox Symlink Installer")
        print("Installing symlinks in \(directory.path)...")
        print()

        var swiftCount = 0
        var totalCount = 0

        print("=== Swift NOFORK built-ins (0.28μs) ===")
        for command in registry.listCommands() {
            let symlinkURL = directory.appendingPathComponent(command)

            do {
                if FileManager.default.fileExists(atPath: symlinkURL.path) {
                    try FileManager.default.removeItem(at: symlinkURL)
                }

                try FileManager.default.createSymbolicLink(
                    atPath: symlinkURL.path,
                    withDestinationPath: binaryURL.lastPathComponent
                )

                print("  ✓ \(command) -> \(binaryURL.lastPathComponent) (NOFORK)")
                swiftCount += 1
                totalCount += 1
            } catch {
                print("  ✗ Failed to create symlink for \(command): \(error)")
            }
        }

        print()
        print("=== BusyBox/External commands ===")
        for command in allCommands {
            // Skip Swift commands (already installed)
            if registry.hasCommand(command) {
                continue
            }

            let symlinkURL = directory.appendingPathComponent(command)

            do {
                if FileManager.default.fileExists(atPath: symlinkURL.path) {
                    try FileManager.default.removeItem(at: symlinkURL)
                }

                try FileManager.default.createSymbolicLink(
                    atPath: symlinkURL.path,
                    withDestinationPath: binaryURL.lastPathComponent
                )

                print("  ✓ \(command) -> \(binaryURL.lastPathComponent)")
                totalCount += 1
            } catch {
                print("  ✗ Failed to create symlink for \(command): \(error)")
            }
        }

        print()
        print("========================================")
        print("✅ Installed \(totalCount) symlinks!")
        print()
        print("Swift NOFORK commands (\(swiftCount)): 0.28μs per call")
        print("BusyBox/External commands (\(totalCount - swiftCount)): Variable speed")
        print()
        print("Test with:")
        print("  ./sh -c 'echo Hello && pwd'")
        print("  ./cat /etc/hostname")
        print("  ./ls -la")
        print("========================================")
    }
}
