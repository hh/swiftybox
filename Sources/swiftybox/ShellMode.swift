import Foundation
import BusyBox

/// Hybrid shell mode that combines:
/// 1. Swift NOFORK built-ins (echo, pwd, true, false)
/// 2. BusyBox C built-ins (via libbusybox)
/// 3. External commands (fork+exec)
struct ShellMode {

    /// Run BusyBox ASH shell with Swift commands as built-ins
    static func runASH(args: [String]) -> Int32 {
        // Initialize BusyBox library
        lbb_prepare("ash", nil)

        // Convert Swift args to C argv
        var cArgs = args.map { strdup($0) }
        cArgs.append(nil)

        let argc = Int32(args.count)
        let argv = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: args.count + 1)
        for (i, arg) in cArgs.enumerated() {
            argv[i] = arg
        }

        // Call BusyBox ash_main
        // This will use our Swift commands as built-ins via the ASH patch!
        let exitCode = ash_main(argc, argv)

        // Cleanup
        for arg in cArgs {
            if let ptr = arg {
                free(ptr)
            }
        }
        argv.deallocate()

        return exitCode
    }

    /// Check if we should run in shell mode
    static func shouldRunAsShell() -> Bool {
        let invokedAs = (CommandLine.arguments[0] as NSString).lastPathComponent

        // If called as "sh", "ash", or "bash", run as shell
        return invokedAs == "sh" ||
               invokedAs == "ash" ||
               invokedAs == "bash" ||
               invokedAs == "-sh" ||  // Login shell
               invokedAs == "-ash"
    }

    /// Get shell name for display
    static func shellName() -> String {
        let invokedAs = (CommandLine.arguments[0] as NSString).lastPathComponent
        if invokedAs.hasPrefix("-") {
            return String(invokedAs.dropFirst())  // Remove leading dash
        }
        return invokedAs
    }
}
