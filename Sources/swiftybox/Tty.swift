import Foundation

/// Tty command - Print the file name of the terminal connected to standard input
/// Usage: tty [-s]
/// Prints the file name of the terminal connected to stdin
/// With -s: silent mode, only return exit status
struct TtyCommand {
    static func main(_ args: [String]) -> Int32 {
        // Check for -s (silent) flag
        let silent = args.contains("-s")

        // ttyname() returns the pathname of the terminal device
        guard let ttyPtr = ttyname(STDIN_FILENO) else {
            if !silent {
                print("not a tty")
            }
            return 1
        }

        // Convert C string to Swift String
        guard let ttyPath = String(validatingCString: ttyPtr) else {
            if !silent {
                FileHandle.standardError.write("tty: cannot read terminal name\n".data(using: .utf8)!)
            }
            return 1
        }

        if !silent {
            print(ttyPath)
        }
        return 0
    }
}
