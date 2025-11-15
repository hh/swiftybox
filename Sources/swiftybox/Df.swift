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
        var showType = false
        var showInodes = false
        var showAll = false
        var paths: [String] = []

        var i = 1
        while i < args.count {
            let arg = args[i]

            if arg == "-h" || arg == "--human-readable" {
                humanReadable = true
            } else if arg == "-T" || arg == "--print-type" {
                showType = true
            } else if arg == "-i" || arg == "--inodes" {
                showInodes = true
            } else if arg == "-a" || arg == "--all" {
                showAll = true
            } else if arg.hasPrefix("-") {
                // Handle combined short options like -hT
                if arg.count > 1 && !arg.hasPrefix("--") {
                    for char in arg.dropFirst() {
                        switch char {
                        case "h": humanReadable = true
                        case "T": showType = true
                        case "i": showInodes = true
                        case "a": showAll = true
                        default:
                            FileHandle.standardError.write("df: invalid option -- '\(char)'\n".data(using: .utf8)!)
                            return 1
                        }
                    }
                } else {
                    FileHandle.standardError.write("df: invalid option -- '\(arg)'\n".data(using: .utf8)!)
                    return 1
                }
            } else {
                paths.append(arg)
            }
            i += 1
        }

        // If no paths specified, show all mounted filesystems
        if paths.isEmpty {
            paths = getMountedFilesystems()
        }

        // Print header
        if showInodes {
            if showType {
                print("Filesystem     Type        Inodes   IUsed    IFree IUse% Mounted on")
            } else {
                print("Filesystem        Inodes   IUsed    IFree IUse% Mounted on")
            }
        } else {
            if showType {
                if humanReadable {
                    print("Filesystem     Type      Size  Used Avail Use% Mounted on")
                } else {
                    print("Filesystem     Type     1K-blocks      Used Available Use% Mounted on")
                }
            } else {
                if humanReadable {
                    print("Filesystem      Size  Used Avail Use% Mounted on")
                } else {
                    print("Filesystem     1K-blocks      Used Available Use% Mounted on")
                }
            }
        }

        for path in paths {
            #if os(Linux)
            var stats = statvfs()
            guard statvfs(path, &stats) == 0 else {
                FileHandle.standardError.write("df: cannot access '\(path)': No such file or directory\n".data(using: .utf8)!)
                continue
            }

            let blockSize = Int64(stats.f_frsize)
            let totalBlocks = Int64(stats.f_blocks)
            let freeBlocks = Int64(stats.f_bfree)
            let availBlocks = Int64(stats.f_bavail)
            let totalInodes = Int64(stats.f_files)
            let freeInodes = Int64(stats.f_ffree)
            #else
            var stats = statfs()
            guard statfs(path, &stats) == 0 else {
                FileHandle.standardError.write("df: cannot access '\(path)': No such file or directory\n".data(using: .utf8)!)
                continue
            }

            let blockSize = Int64(stats.f_bsize)
            let totalBlocks = Int64(stats.f_blocks)
            let freeBlocks = Int64(stats.f_bfree)
            let availBlocks = Int64(stats.f_bavail)
            let totalInodes = Int64(stats.f_files)
            let freeInodes = Int64(stats.f_ffree)
            #endif

            // Get filesystem type
            #if os(Linux)
            let fsType = getFsTypeName(UInt(stats.f_type))
            #else
            let fsType = String(cString: stats.f_fstypename)
            #endif

            // Skip pseudo filesystems unless -a is specified
            if !showAll && isPseudoFilesystem(fsType) {
                continue
            }

            let filesystem = getFilesystemName(path)

            if showInodes {
                let usedInodes = totalInodes - freeInodes
                let inodePercent = totalInodes > 0 ? (usedInodes * 100) / totalInodes : 0

                if showType {
                    print(String(format: "%-15s %-10s %8lld %8lld %8lld %3lld%% %s",
                                 filesystem, fsType, totalInodes, usedInodes, freeInodes, inodePercent, path))
                } else {
                    print(String(format: "%-15s %8lld %8lld %8lld %3lld%% %s",
                                 filesystem, totalInodes, usedInodes, freeInodes, inodePercent, path))
                }
            } else {
                let total = (totalBlocks * blockSize) / 1024
                let avail = (availBlocks * blockSize) / 1024
                let used = total - (freeBlocks * blockSize) / 1024
                let usedPercent = total > 0 ? (used * 100) / total : 0

                if showType {
                    if humanReadable {
                        print(String(format: "%-15s %-10s %5s %5s %5s %3lld%% %s",
                                     filesystem, fsType,
                                     formatSize(total * 1024),
                                     formatSize(used * 1024),
                                     formatSize(avail * 1024),
                                     usedPercent, path))
                    } else {
                        print(String(format: "%-15s %-10s %10lld %10lld %10lld %3lld%% %s",
                                     filesystem, fsType, total, used, avail, usedPercent, path))
                    }
                } else {
                    if humanReadable {
                        print(String(format: "%-15s %5s %5s %5s %3lld%% %s",
                                     filesystem,
                                     formatSize(total * 1024),
                                     formatSize(used * 1024),
                                     formatSize(avail * 1024),
                                     usedPercent, path))
                    } else {
                        print(String(format: "%-15s %10lld %10lld %10lld %3lld%% %s",
                                     filesystem, total, used, avail, usedPercent, path))
                    }
                }
            }
        }

        return 0
    }

    static func formatSize(_ bytes: Int64) -> String {
        let kb = Double(bytes) / 1024.0
        let mb = kb / 1024.0
        let gb = mb / 1024.0
        let tb = gb / 1024.0

        if tb >= 1.0 { return String(format: "%.1fT", tb) }
        else if gb >= 1.0 { return String(format: "%.1fG", gb) }
        else if mb >= 1.0 { return String(format: "%.1fM", mb) }
        else if kb >= 1.0 { return String(format: "%.1fK", kb) }
        else { return String(format: "%lldB", bytes) }
    }

    #if os(Linux)
    static func getFsTypeName(_ type: UInt) -> String {
        // Linux filesystem type magic numbers
        switch type {
        case 0xEF53: return "ext4"
        case 0x01021994: return "tmpfs"
        case 0x9123683E: return "btrfs"
        case 0x58465342: return "xfs"
        case 0x6969: return "nfs"
        case 0x9fa0: return "proc"
        case 0x62656572: return "sysfs"
        case 0x1cd1: return "devtmpfs"
        case 0x794c7630: return "overlay"
        case 0x2011BAB0: return "exfat"
        case 0x4d44: return "vfat"
        default: return String(format: "0x%x", type)
        }
    }
    #endif

    static func isPseudoFilesystem(_ fsType: String) -> Bool {
        let pseudoFs = ["proc", "sysfs", "devtmpfs", "devpts", "tmpfs", "cgroup", "cgroup2",
                        "pstore", "bpf", "tracefs", "debugfs", "securityfs", "fusectl",
                        "configfs", "hugetlbfs", "mqueue"]
        return pseudoFs.contains(fsType.lowercased())
    }

    static func getFilesystemName(_ path: String) -> String {
        // Try to get device name from mount point
        #if os(Linux)
        // On Linux, read /proc/mounts
        if let mounts = try? String(contentsOfFile: "/proc/mounts") {
            for line in mounts.split(separator: "\n") {
                let parts = line.split(separator: " ")
                if parts.count >= 2 {
                    let mountPoint = String(parts[1])
                    if mountPoint == path {
                        return String(parts[0])
                    }
                }
            }
        }
        #endif
        return "filesystem"
    }

    static func getMountedFilesystems() -> [String] {
        var mounts: [String] = []

        #if os(Linux)
        // Read /proc/mounts
        if let mountsContent = try? String(contentsOfFile: "/proc/mounts") {
            for line in mountsContent.split(separator: "\n") {
                let parts = line.split(separator: " ")
                if parts.count >= 2 {
                    mounts.append(String(parts[1]))
                }
            }
        }
        #else
        // On macOS/BSD, use getmntinfo
        // For simplicity, just return root
        mounts = ["/"]
        #endif

        // If nothing found, at least return root
        if mounts.isEmpty {
            mounts = ["/"]
        }

        return mounts
    }
}
