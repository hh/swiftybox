import Foundation

/// Du command - Estimate file space usage
/// Usage: du [OPTIONS] [FILE...]
struct DuCommand {
    static func main(_ args: [String]) -> Int32 {
        var humanReadable = false
        var summarize = false
        var files: [String] = []

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-h" || arg == "--human-readable" { humanReadable = true }
            else if arg == "-s" || arg == "--summarize" { summarize = true }
            else if arg.hasPrefix("-") && arg.contains("h") { humanReadable = true }
            else if arg.hasPrefix("-") && arg.contains("s") { summarize = true }
            else { files.append(arg) }
        }

        if files.isEmpty { files = ["."] }

        for file in files {
            let size = calculateSize(file, summarize: summarize)
            if humanReadable {
                print("\(formatSize(size))\t\(file)")
            } else {
                print("\(size / 1024)\t\(file)")
            }
        }

        return 0
    }

    static func calculateSize(_ path: String, summarize: Bool) -> Int64 {
        let fm = FileManager.default
        var total: Int64 = 0
        var isDir: ObjCBool = false

        guard fm.fileExists(atPath: path, isDirectory: &isDir) else { return 0 }

        if isDir.boolValue {
            if let enumerator = fm.enumerator(atPath: path) {
                for case let file as String in enumerator {
                    let fullPath = (path as NSString).appendingPathComponent(file)
                    if let attrs = try? fm.attributesOfItem(atPath: fullPath) {
                        total += (attrs[.size] as? Int64) ?? 0
                    }
                }
            }
        } else {
            if let attrs = try? fm.attributesOfItem(atPath: path) {
                total = (attrs[.size] as? Int64) ?? 0
            }
        }

        return total
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
