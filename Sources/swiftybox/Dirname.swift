import Foundation

/// Dirname command - Strip last component from file name
/// Usage: dirname NAME
/// Output NAME with its last non-slash component and trailing slashes removed
/// If NAME contains no /'s, output '.' (meaning the current directory)
struct DirnameCommand {
    static func main(_ args: [String]) -> Int32 {
        guard args.count > 1 else {
            FileHandle.standardError.write("usage: dirname string\n".data(using: .utf8)!)
            return 1
        }

        let path = args[1]

        // Special case: root directory
        if path == "/" {
            print("/")
            return 0
        }

        var result = (path as NSString).deletingLastPathComponent

        // If result is empty, it means the path had no directory component
        if result.isEmpty {
            result = "."
        }

        print(result)
        return 0
    }
}
