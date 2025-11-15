import Foundation

/// Basename command - Strip directory and suffix from filenames
/// Usage: basename NAME [SUFFIX]
/// Print NAME with any leading directory components removed
/// If specified, also remove a trailing SUFFIX
struct BasenameCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count > 1 else {
            FileHandle.standardError.write("usage: basename string [suffix]\n".data(using: .utf8)!)
            return 1
        }

        var result = (args[1] as NSString).lastPathComponent

        // Remove suffix if provided
        if args.count > 2 {
            let suffix = args[2]
            // Don't remove suffix if it's identical to the whole name
            if result.hasSuffix(suffix) && result != suffix {
                result = String(result.dropLast(suffix.count))
            }
        }

        print(result)
        return 0
    }
}
