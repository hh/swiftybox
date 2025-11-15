import Foundation

/// Ls command - List directory contents
/// Usage: ls [OPTIONS] [FILE...]
struct LsCommand {
    static func main(_ args: [String]) -> Int32 {
        var showAll = false
        var longFormat = false
        var humanReadable = false
        var showHidden = false
        var paths: [String] = []

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-a" || arg == "--all" { showAll = true }
            else if arg == "-l" { longFormat = true }
            else if arg == "-h" || arg == "--human-readable" { humanReadable = true }
            else if arg == "-A" { showHidden = true }
            else if arg.hasPrefix("-") && arg != "-" {
                for c in arg.dropFirst() {
                    if c == "a" { showAll = true }
                    else if c == "l" { longFormat = true }
                    else if c == "h" { humanReadable = true }
                    else if c == "A" { showHidden = true }
                }
            } else { paths.append(arg) }
        }

        if paths.isEmpty { paths.append(".") }

        let fm = FileManager.default
        var exitCode: Int32 = 0

        for path in paths {
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: path, isDirectory: &isDir) else {
                FileHandle.standardError.write("ls: cannot access '\(path)': No such file or directory\n".data(using: .utf8)!)
                exitCode = 1
                continue
            }

            if isDir.boolValue {
                guard let contents = try? fm.contentsOfDirectory(atPath: path) else {
                    FileHandle.standardError.write("ls: cannot open directory '\(path)'\n".data(using: .utf8)!)
                    exitCode = 1
                    continue
                }

                var files = contents.sorted()
                if !showAll && !showHidden {
                    files = files.filter { !$0.hasPrefix(".") }
                } else if showHidden && !showAll {
                    files = files.filter { !($0 == "." || $0 == "..") }
                }

                if longFormat {
                    for file in files {
                        let fullPath = (path as NSString).appendingPathComponent(file)
                        printLongFormat(fullPath, name: file, humanReadable: humanReadable)
                    }
                } else {
                    print(files.joined(separator: "  "))
                }
            } else {
                if longFormat {
                    printLongFormat(path, name: (path as NSString).lastPathComponent, humanReadable: humanReadable)
                } else {
                    print(path)
                }
            }
        }

        return exitCode
    }

    static func printLongFormat(_ path: String, name: String, humanReadable: Bool) {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path) else {
            print("?????????? ? ? ? ? \(name)")
            return
        }

        let perms = (attrs[.posixPermissions] as? UInt16) ?? 0
        let size = (attrs[.size] as? Int64) ?? 0
        let date = (attrs[.modificationDate] as? Date) ?? Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd HH:mm"

        let sizeStr = humanReadable ? formatSize(size) : "\(size)"
        let permsStr = formatPermissions(perms)

        print("\(permsStr) \(sizeStr.padding(toLength: 10, withPad: " ", startingAt: 0)) \(formatter.string(from: date)) \(name)")
    }

    static func formatPermissions(_ perms: UInt16) -> String {
        var result = ""
        let types = [(UInt16(0o400), "r"), (UInt16(0o200), "w"), (UInt16(0o100), "x")]
        for shift in [6, 3, 0] {
            for (mask, char) in types {
                result += (perms & (mask >> shift)) != 0 ? char : "-"
            }
        }
        return "-" + result
    }

    static func formatSize(_ size: Int64) -> String {
        let units = ["B", "K", "M", "G", "T"]
        var sz = Double(size)
        var unit = 0
        while sz >= 1024 && unit < units.count - 1 {
            sz /= 1024
            unit += 1
        }
        return String(format: "%.1f%@", sz, units[unit])
    }
}
