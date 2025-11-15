import Foundation

/// Uname command - Print system information
/// Usage: uname [-snrvmpio] [-a]
/// Print certain system information
struct UnameCommand {
    static func main(_ args: [String]) -> Int32 {
        var showAll = false
        var showSysname = false
        var showNodename = false
        var showRelease = false
        var showVersion = false
        var showMachine = false
        var showProcessor = false
        var showHardware = false
        var showOS = false

        // Parse arguments
        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-a" || arg == "--all" {
                showAll = true
            } else if arg.hasPrefix("-") {
                for c in arg.dropFirst() {
                    switch c {
                    case "s": showSysname = true
                    case "n": showNodename = true
                    case "r": showRelease = true
                    case "v": showVersion = true
                    case "m": showMachine = true
                    case "p": showProcessor = true
                    case "i": showHardware = true
                    case "o": showOS = true
                    default:
                        FileHandle.standardError.write("uname: invalid option -- '\(c)'\n".data(using: .utf8)!)
                        return 1
                    }
                }
            }
        }

        // Default is -s if no options
        if !showAll && !showSysname && !showNodename && !showRelease &&
           !showVersion && !showMachine && !showProcessor && !showHardware && !showOS {
            showSysname = true
        }

        // Get system information
        var systemInfo = utsname()
        uname(&systemInfo)

        var parts: [String] = []

        if showAll || showSysname {
            parts.append(String(cString: withUnsafePointer(to: &systemInfo.sysname.0) { $0 }))
        }
        if showAll || showNodename {
            parts.append(String(cString: withUnsafePointer(to: &systemInfo.nodename.0) { $0 }))
        }
        if showAll || showRelease {
            parts.append(String(cString: withUnsafePointer(to: &systemInfo.release.0) { $0 }))
        }
        if showAll || showVersion {
            parts.append(String(cString: withUnsafePointer(to: &systemInfo.version.0) { $0 }))
        }
        if showAll || showMachine {
            parts.append(String(cString: withUnsafePointer(to: &systemInfo.machine.0) { $0 }))
        }

        // Processor and hardware platform (often same as machine)
        if showAll || showProcessor {
            #if arch(x86_64)
            parts.append("x86_64")
            #elseif arch(arm64)
            parts.append("arm64")
            #elseif arch(arm)
            parts.append("arm")
            #else
            parts.append("unknown")
            #endif
        }

        if showAll || showHardware {
            #if arch(x86_64)
            parts.append("x86_64")
            #elseif arch(arm64)
            parts.append("arm64")
            #elseif arch(arm)
            parts.append("arm")
            #else
            parts.append("unknown")
            #endif
        }

        if showAll || showOS {
            #if os(Linux)
            parts.append("GNU/Linux")
            #elseif os(macOS)
            parts.append("Darwin")
            #else
            parts.append("unknown")
            #endif
        }

        print(parts.joined(separator: " "))
        return 0
    }
}
