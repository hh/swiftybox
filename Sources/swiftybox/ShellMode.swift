import Foundation
// import BusyBox  // Disabled - not needed for pure Swift implementation

/// Hybrid shell mode that combines:
/// 1. Swift NOFORK built-ins (echo, pwd, true, false)
/// 2. BusyBox C built-ins (via libbusybox)
/// 3. External commands (fork+exec)
struct ShellMode {

    /// Run BusyBox ASH shell with Swift commands as built-ins
    static func runASH(args: [String]) -> Int32 {
        // Disabled - BusyBox integration not currently used
        // Using pure Swift minimal shell instead
        print("Error: ASH shell not available - BusyBox integration disabled")
        return 1
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
