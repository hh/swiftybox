import Foundation
#if canImport(Musl)
import Musl
#elseif canImport(Glibc)
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
        #if canImport(Musl)
        Musl.sync()
        #elseif canImport(Glibc)
        Glibc.sync()
        #elseif canImport(Darwin)
        Darwin.sync()
        #endif

        return 0
    }
}
