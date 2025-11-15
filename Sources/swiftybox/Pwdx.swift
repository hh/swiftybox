import Foundation

/// Pwdx command - Print working directory of a process
/// Usage: pwdx PID...
/// Print the current working directory of processes
struct PwdxCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count > 1 else {
            FileHandle.standardError.write("pwdx: missing process ID\n".data(using: .utf8)!)
            return 1
        }

        var exitCode: Int32 = 0

        for i in 1..<args.count {
            let pidString = args[i]

            guard let pid = Int(pidString) else {
                FileHandle.standardError.write("pwdx: invalid process id: \(pidString)\n".data(using: .utf8)!)
                exitCode = 1
                continue
            }

            // Read the /proc/PID/cwd symlink
            let cwdPath = "/proc/\(pid)/cwd"

            do {
                let cwd = try FileManager.default.destinationOfSymbolicLink(atPath: cwdPath)
                print("\(pid): \(cwd)")
            } catch {
                FileHandle.standardError.write("pwdx: \(pid): \(error.localizedDescription)\n".data(using: .utf8)!)
                exitCode = 1
            }
        }

        return exitCode
    }
}
