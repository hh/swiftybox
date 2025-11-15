import Foundation

/// Logname command - Print user's login name
/// Usage: logname
/// Prints the name of the user who logged in (from controlling terminal)
struct LognameCommand {
    static func main(_ args: [String]) -> Int32 {
        // getlogin() returns the login name of the user associated with the current session
        guard let loginPtr = getlogin() else {
            FileHandle.standardError.write("logname: no login name\n".data(using: .utf8)!)
            return 1
        }

        // Convert C string to Swift String
        guard let loginName = String(validatingCString: loginPtr) else {
            FileHandle.standardError.write("logname: cannot read login name\n".data(using: .utf8)!)
            return 1
        }

        print(loginName)
        return 0
    }
}
