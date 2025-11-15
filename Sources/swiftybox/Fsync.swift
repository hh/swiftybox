import Foundation

/// Fsync command - Synchronize a file's in-core state with storage
/// Usage: fsync FILE...
/// Force changed blocks to disk, update the super block
struct FsyncCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count > 1 else {
            FileHandle.standardError.write("fsync: missing file operand\n".data(using: .utf8)!)
            return 1
        }

        var exitCode: Int32 = 0

        for i in 1..<args.count {
            let file = args[i]

            do {
                // Open file for reading (fsync doesn't modify content)
                let fileHandle = try FileHandle(forUpdating: URL(fileURLWithPath: file))

                // Synchronize file to disk
                try fileHandle.synchronize()
                try fileHandle.close()
            } catch {
                FileHandle.standardError.write("fsync: \(file): \(error.localizedDescription)\n".data(using: .utf8)!)
                exitCode = 1
            }
        }

        return exitCode
    }
}
