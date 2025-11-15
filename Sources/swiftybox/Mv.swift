import Foundation

/// Mv command - Move (rename) files
/// Usage: mv [OPTIONS] SOURCE DEST or mv [OPTIONS] SOURCE... DIRECTORY
struct MvCommand {
    static func main(_ args: [String]) -> Int32 {
        var force = false
        var verbose = false
        var files: [String] = []

        for i in 1..<args.count {
            let arg = args[i]
            if arg == "-f" || arg == "--force" { force = true }
            else if arg == "-v" || arg == "--verbose" { verbose = true }
            else if arg.hasPrefix("-") && arg != "-" {
                for c in arg.dropFirst() {
                    if c == "f" { force = true }
                    else if c == "v" { verbose = true }
                }
            } else { files.append(arg) }
        }

        guard files.count >= 2 else {
            FileHandle.standardError.write("mv: missing file operand\n".data(using: .utf8)!)
            return 1
        }

        let fm = FileManager.default
        let dest = files.last!
        var isDir: ObjCBool = false
        let destIsDir = fm.fileExists(atPath: dest, isDirectory: &isDir) && isDir.boolValue

        if files.count == 2 && !destIsDir {
            return moveFile(files[0], to: dest, force: force, verbose: verbose)
        } else {
            guard destIsDir else {
                FileHandle.standardError.write("mv: target '\(dest)' is not a directory\n".data(using: .utf8)!)
                return 1
            }
            var exitCode: Int32 = 0
            for src in files.dropLast() {
                let target = (dest as NSString).appendingPathComponent((src as NSString).lastPathComponent)
                if moveFile(src, to: target, force: force, verbose: verbose) != 0 { exitCode = 1 }
            }
            return exitCode
        }
    }

    static func moveFile(_ src: String, to dest: String, force: Bool, verbose: Bool) -> Int32 {
        let fm = FileManager.default
        if force && fm.fileExists(atPath: dest) {
            try? fm.removeItem(atPath: dest)
        }
        do {
            try fm.moveItem(atPath: src, toPath: dest)
            if verbose { print("'\(src)' -> '\(dest)'") }
            return 0
        } catch {
            FileHandle.standardError.write("mv: cannot move '\(src)' to '\(dest)': \(error.localizedDescription)\n".data(using: .utf8)!)
            return 1
        }
    }
}
