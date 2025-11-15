import Foundation
import BusyBox

/// Wrapper for calling BusyBox C implementations
/// These properly initialize BusyBox globals before calling *_main() functions
enum BusyBoxWrappers {
    
    /// Helper to convert Swift [String] to C char**
    private static func toCArgv(_ args: [String]) -> UnsafeMutablePointer<UnsafeMutablePointer<CChar>?> {
        // Allocate array of pointers (+1 for NULL terminator)
        let argv = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: args.count + 1)
        
        // Convert each string to C string
        for (i, arg) in args.enumerated() {
            argv[i] = strdup(arg)
        }
        
        // NULL terminate
        argv[args.count] = nil
        
        return argv
    }
    
    /// Helper to free C argv
    private static func freeCArgv(_ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>, count: Int) {
        for i in 0..<count {
            free(argv[i])
        }
        argv.deallocate()
    }
    
    /// Call BusyBox echo implementation
    static func echo(args: [String]) -> Int32 {
        let argv = toCArgv(args)
        defer { freeCArgv(argv, count: args.count) }
        
        // Initialize BusyBox for echo
        lbb_prepare("echo", argv)
        
        // Call BusyBox echo_main
        let result = echo_main(Int32(args.count), argv)
        
        return result
    }
    
    /// Call BusyBox pwd implementation
    static func pwd(args: [String]) -> Int32 {
        let argv = toCArgv(args)
        defer { freeCArgv(argv, count: args.count) }
        
        lbb_prepare("pwd", argv)
        let result = pwd_main(Int32(args.count), argv)
        
        return result
    }
    
    /// Call BusyBox true implementation
    static func trueCommand(args: [String]) -> Int32 {
        let argv = toCArgv(args)
        defer { freeCArgv(argv, count: args.count) }
        
        lbb_prepare("true", argv)
        let result = true_main(Int32(args.count), argv)
        
        return result
    }
    
    /// Call BusyBox false implementation
    static func falseCommand(args: [String]) -> Int32 {
        let argv = toCArgv(args)
        defer { freeCArgv(argv, count: args.count) }

        lbb_prepare("false", argv)
        let result = false_main(Int32(args.count), argv)

        return result
    }

    /// Generic dispatcher for any BusyBox NOFORK/NOEXEC applet
    /// This is the key to unlocking ~200 BusyBox commands!
    static func runApplet(command: String, args: [String]) -> Int32? {
        // TODO: Phase 7 - BusyBox NOEXEC integration
        // For now, return nil to indicate command not found
        // This will cause the shell to fall back to external execution

        // Future implementation:
        // 1. find_applet_by_name(command) to get applet number
        // 2. Check if applet is NOFORK or NOEXEC
        // 3. Call applet's main function directly or via run_nofork_applet

        return nil
    }
}
