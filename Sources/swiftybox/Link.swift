import Foundation

/// Link command - Create a hard link to a file
/// Usage: link FILE1 FILE2
/// Create a link named FILE2 to FILE1
struct LinkCommand {
    static func main(_ args: [String]) -> Int32 {
        if args.count != 3 {
            FileHandle.standardError.write("link: missing operand\nUsage: link FILE1 FILE2\nCreate a link to FILE1 named FILE2\n".data(using: .utf8)!)
            return 1
        }

        let source = args[1]
        let dest = args[2]

        let fm = FileManager.default
        do {
            try fm.linkItem(atPath: source, toPath: dest)
            return 0
        } catch {
            FileHandle.standardError.write("link: cannot create link '\(dest)' to '\(source)': \(error.localizedDescription)\n".data(using: .utf8)!)
            return 1
        }
    }
}
