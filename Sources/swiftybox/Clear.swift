import Foundation

/// Clear command - Clear the terminal screen
/// Usage: clear
/// Clear the terminal screen using ANSI escape codes
struct ClearCommand {
    static func main(_ args: [String]) -> Int32 {
        // Clear screen using ANSI escape sequences
        // ESC[2J clears the entire screen
        // ESC[H moves cursor to home position (0,0)
        print("\u{001B}[2J\u{001B}[H", terminator: "")
        // Flush output to ensure it's displayed immediately
        FileHandle.standardOutput.synchronizeFile()
        return 0
    }
}
