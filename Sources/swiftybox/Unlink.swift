import Foundation

/// Unlink command - Remove a file
/// Usage: unlink FILE
/// Call the unlink function to remove the specified FILE
struct UnlinkCommand {
    static func main(_ args: [String]) -> Int32 {
        if args.count != 2 {
            FileHandle.standardError.write("unlink: missing operand\nUsage: unlink FILE\nRemove the specified FILE using the unlink function.\n".data(using: .utf8)!)
            return 1
        }

        let file = args[1]

        let fm = FileManager.default
        do {
            try fm.removeItem(atPath: file)
            return 0
        } catch {
            FileHandle.standardError.write("unlink: cannot unlink '\(file)': \(error.localizedDescription)\n".data(using: .utf8)!)
            return 1
        }
    }
}
