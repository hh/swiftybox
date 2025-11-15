import Foundation

/// Pure Swift implementation of the pwd command
struct PwdCommand {
    static func main(args: [String]) -> Int32 {
        let currentDir = FileManager.default.currentDirectoryPath
        print(currentDir)
        return 0
    }
}
