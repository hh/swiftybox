import Foundation

/// Pure Swift implementation of the true command
/// Always returns success (0)
struct TrueCommand {
    static func main(args: [String]) -> Int32 {
        return 0
    }
}

/// Pure Swift implementation of the false command
/// Always returns failure (1)
struct FalseCommand {
    static func main(args: [String]) -> Int32 {
        return 1
    }
}
