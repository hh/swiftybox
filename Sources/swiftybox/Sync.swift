import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Sync command - Flush filesystem buffers
/// Usage: sync
/// Force changed blocks to disk, update the super block
struct SyncCommand {
    static func main(_ args: [String]) -> Int32 {
        // Call POSIX sync() to flush all filesystem buffers to disk
        #if os(Linux)
        Glibc.sync()
        #else
        Darwin.sync()
        #endif

        return 0
    }
}
