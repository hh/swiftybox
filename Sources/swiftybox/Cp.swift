import Foundation

/// Cp command - Copy files and directories
/// Usage: cp [OPTIONS] SOURCE DEST or cp [OPTIONS] SOURCE... DIRECTORY
struct CpCommand {
    static func main(_ args: [String]) -> Int32 {
        var recursive = false
        var force = false
        var verbose = false
        var files: [String] = []

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-r" || arg == "-R" || arg == "--recursive" { recursive = true }
            else if arg == "-f" || arg == "--force" { force = true }
            else if arg == "-v" || arg == "--verbose" { verbose = true }
            else if arg.hasPrefix("-") && arg != "-" {
                for c in arg.dropFirst() {
                    if c == "r" || c == "R" { recursive = true }
                    else if c == "f" { force = true }
                    else if c == "v" { verbose = true }
                }
            } else { files.append(arg) }
        }

        guard files.count >= 2 else {
            FileHandle.standardError.write("cp: missing file operand\n".data(using: .utf8)!)
            return 1
        }

        let fm = FileManager.default
        let dest = files.last!
        var isDir: ObjCBool = false
        let destIsDir = fm.fileExists(atPath: dest, isDirectory: &isDir) && isDir.boolValue

        if files.count == 2 && !destIsDir {
            return copyFile(files[0], to: dest, recursive: recursive, force: force, verbose: verbose)
        } else {
            guard destIsDir else {
                FileHandle.standardError.write("cp: target '\(dest)' is not a directory\n".data(using: .utf8)!)
                return 1
            }
            var exitCode: Int32 = 0
            for src in files.dropLast() {
                let target = (dest as NSString).appendingPathComponent((src as NSString).lastPathComponent)
                if copyFile(src, to: target, recursive: recursive, force: force, verbose: verbose) != 0 { exitCode = 1 }
            }
            return exitCode
        }
    }

    static func copyFile(_ src: String, to dest: String, recursive: Bool, force: Bool, verbose: Bool) -> Int32 {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: src, isDirectory: &isDir) && isDir.boolValue && !recursive {
            FileHandle.standardError.write("cp: '\(src)' is a directory (not copied)\n".data(using: .utf8)!)
            return 1
        }
        if force && fm.fileExists(atPath: dest) {
            try? fm.removeItem(atPath: dest)
        }
        do {
            try fm.copyItem(atPath: src, toPath: dest)
            if verbose { print("'\(src)' -> '\(dest)'") }
            return 0
        } catch {
            FileHandle.standardError.write("cp: cannot copy '\(src)' to '\(dest)': \(error.localizedDescription)\n".data(using: .utf8)!)
            return 1
        }
    }
}
