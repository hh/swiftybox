import Foundation

/// Global command registry for ASH to use
/// Using @MainActor for thread safety
@MainActor
private var ashCommandRegistry: CommandRegistry?

/// Initialize the ASH bridge with command registry
public func initializeASHBridge() {
    Task { @MainActor in
        ashCommandRegistry = CommandRegistry(preferredImpl: .swift)
    }
}

/// Check if Swift has a command implementation (legacy name)
@_cdecl("swiftybox_has_command")
public func swiftybox_has_command(_ name: UnsafePointer<CChar>) -> Int32 {
    let cmdName = String(cString: name)
    let hasIt = CommandRegistry(preferredImpl: .swift).hasCommand(cmdName)
    return hasIt ? 1 : 0
}

/// Check if Swift has a command implementation (ASH expects this name)
@_cdecl("is_swiftybox_command")
public func is_swiftybox_command(_ name: UnsafePointer<CChar>) -> Int32 {
    return swiftybox_has_command(name)
}

/// Dispatch command to Swift implementation (legacy name)
@_cdecl("swiftybox_dispatch")
public func swiftybox_dispatch(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) -> Int32 {
    let registry = CommandRegistry(preferredImpl: .swift)

    // Convert C argv to Swift [String]
    var args: [String] = []
    for i in 0..<Int(argc) {
        if let arg = argv[i] {
            args.append(String(cString: arg))
        }
    }

    guard let cmdName = args.first else {
        return 127
    }

    return registry.execute(command: cmdName, args: args)
}

/// Wrapper for ASH built-in commands (ASH expects this name)
@_cdecl("swiftybox_builtin_wrapper")
public func swiftybox_builtin_wrapper(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) -> Int32 {
    return swiftybox_dispatch(argc, argv)
}

/// Get list of Swift commands for shell completion
@_cdecl("swiftybox_list_commands")
public func swiftybox_list_commands(_ buffer: UnsafeMutablePointer<CChar>, _ bufsize: Int32) -> Int32 {
    let registry = CommandRegistry(preferredImpl: .swift)
    let commands = registry.listCommands().joined(separator: " ")
    let cString = commands.utf8CString
    
    let maxLen = min(cString.count, Int(bufsize) - 1)
    for i in 0..<maxLen {
        buffer[i] = CChar(cString[i])
    }
    buffer[maxLen] = 0
    
    return Int32(registry.listCommands().count)
}
