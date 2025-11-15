import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Df command - Report file system disk space usage
/// Usage: df [OPTIONS] [FILE...]
struct DfCommand {
    static func main(_ args: [String]) -> Int32 {
        var humanReadable = false
        var paths = ["/"]

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-h" || arg == "--human-readable" { humanReadable = true }
            else if !arg.hasPrefix("-") { paths.append(arg) }
        }

        print("Filesystem     1K-blocks      Used Available Use% Mounted on")

        for path in paths {
            #if os(Linux)
            var stats = statvfs()
            guard statvfs(path, &stats) == 0 else { continue }

            let blockSize = Int64(stats.f_frsize)
            let totalBlocks = Int64(stats.f_blocks)
            let freeBlocks = Int64(stats.f_bfree)
            let availBlocks = Int64(stats.f_bavail)
            #else
            var stats = statfs()
            guard statfs(path, &stats) == 0 else { continue }

            let blockSize = Int64(stats.f_bsize)
            let totalBlocks = Int64(stats.f_blocks)
            let freeBlocks = Int64(stats.f_bfree)
            let availBlocks = Int64(stats.f_bavail)
            #endif

            let total = (totalBlocks * blockSize) / 1024
            let avail = (availBlocks * blockSize) / 1024
            let used = total - (freeBlocks * blockSize) / 1024
            let usedPercent = total > 0 ? (used * 100) / total : 0

            if humanReadable {
                print(String(format: "%-15s %10s %10s %10s %3lld%% %s",
                             "filesystem",
                             formatSize(total * 1024),
                             formatSize(used * 1024),
                             formatSize(avail * 1024),
                             usedPercent,
                             path))
            } else {
                print(String(format: "%-15s %10lld %10lld %10lld %3lld%% %s",
                             "filesystem", total, used, avail, usedPercent, path))
            }
        }

        return 0
    }

    static func formatSize(_ bytes: Int64) -> String {
        let kb = Double(bytes) / 1024.0
        let mb = kb / 1024.0
        let gb = mb / 1024.0

        if gb >= 1.0 { return String(format: "%.1fG", gb) }
        else if mb >= 1.0 { return String(format: "%.1fM", mb) }
        else { return String(format: "%.1fK", kb) }
    }
}
