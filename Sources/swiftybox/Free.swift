import Foundation

/// Free command - Display amount of free and used memory
/// Usage: free [-h]
/// Display amount of free and used memory in the system
struct FreeCommand {
    static func main(_ args: [String]) -> Int32 {
        let humanReadable = args.contains("-h") || args.contains("--human")

        // Read /proc/meminfo on Linux
        guard let meminfo = try? String(contentsOfFile: "/proc/meminfo", encoding: .utf8) else {
            FileHandle.standardError.write("free: cannot read /proc/meminfo\n".data(using: .utf8)!)
            return 1
        }

        var memTotal: Int64 = 0
        var memFree: Int64 = 0
        var memAvailable: Int64 = 0
        var buffers: Int64 = 0
        var cached: Int64 = 0
        var swapTotal: Int64 = 0
        var swapFree: Int64 = 0

        for line in meminfo.components(separatedBy: "\n") {
            let parts = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard parts.count >= 2 else { continue }

            let key = parts[0]
            let value = Int64(parts[1]) ?? 0

            switch key {
            case "MemTotal:": memTotal = value
            case "MemFree:": memFree = value
            case "MemAvailable:": memAvailable = value
            case "Buffers:": buffers = value
            case "Cached:": cached = value
            case "SwapTotal:": swapTotal = value
            case "SwapFree:": swapFree = value
            default: break
            }
        }

        // Convert from KB to bytes for calculations
        let used = memTotal - memFree - buffers - cached
        let swapUsed = swapTotal - swapFree

        // Print header
        print(String(format: "%-15@ %12@ %12@ %12@ %12@ %12@",
                     "" as NSString, "total" as NSString, "used" as NSString,
                     "free" as NSString, "shared" as NSString, "available" as NSString))

        // Print memory line
        if humanReadable {
            print(String(format: "%-15@ %12@ %12@ %12@ %12@ %12@",
                         "Mem:" as NSString,
                         formatBytes(memTotal * 1024) as NSString,
                         formatBytes(used * 1024) as NSString,
                         formatBytes(memFree * 1024) as NSString,
                         "-" as NSString,
                         formatBytes(memAvailable * 1024) as NSString))
            print(String(format: "%-15@ %12@ %12@ %12@",
                         "Swap:" as NSString,
                         formatBytes(swapTotal * 1024) as NSString,
                         formatBytes(swapUsed * 1024) as NSString,
                         formatBytes(swapFree * 1024) as NSString))
        } else {
            print(String(format: "%-15@ %12lld %12lld %12lld %12@ %12lld",
                         "Mem:" as NSString,
                         memTotal,
                         used,
                         memFree,
                         "-" as NSString,
                         memAvailable))
            print(String(format: "%-15@ %12lld %12lld %12lld",
                         "Swap:" as NSString,
                         swapTotal,
                         swapUsed,
                         swapFree))
        }

        return 0
    }

    static func formatBytes(_ bytes: Int64) -> String {
        let kb = Double(bytes) / 1024.0
        let mb = kb / 1024.0
        let gb = mb / 1024.0

        if gb >= 1.0 {
            return String(format: "%.1fG", gb)
        } else if mb >= 1.0 {
            return String(format: "%.1fM", mb)
        } else {
            return String(format: "%.1fK", kb)
        }
    }
}
