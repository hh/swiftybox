import Foundation
#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

/// Hostname command - Show or set the system hostname
/// Usage: hostname [-s|-d|-f|-i] [NAME]
/// Show or set the system's host name
struct HostnameCommand {
    static func main(_ args: [String]) -> Int32 {
        var shortOption = false
        var domainOption = false
        var fqdnOption = false
        var ipOption = false
        var newHostname: String? = nil

        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg.hasPrefix("-") && arg != "-" {
                for char in arg.dropFirst() {
                    switch char {
                    case "s":
                        shortOption = true
                    case "d":
                        domainOption = true
                    case "f":
                        fqdnOption = true
                    case "i":
                        ipOption = true
                    default:
                        FileHandle.standardError.write("hostname: invalid option -- '\(char)'\n".data(using: .utf8)!)
                        return 1
                    }
                }
            } else {
                newHostname = arg
            }
            i += 1
        }

        // Setting hostname
        if let newName = newHostname {
            return setHostname(newName)
        }

        // Getting hostname
        guard let hostname = getHostname() else {
            FileHandle.standardError.write("hostname: cannot determine hostname\n".data(using: .utf8)!)
            return 1
        }

        if shortOption {
            // Return short hostname (before first dot)
            let short = hostname.components(separatedBy: ".").first ?? hostname
            print(short)
        } else if domainOption {
            // Return domain part (after first dot)
            let parts = hostname.components(separatedBy: ".")
            if parts.count > 1 {
                print(parts[1...].joined(separator: "."))
            }
            // Empty output if no domain
        } else if fqdnOption {
            // Return FQDN - try to get from /etc/hosts or just return hostname
            print(getFQDN(hostname))
        } else if ipOption {
            // Return IP address(es)
            return getIPAddresses(hostname)
        } else {
            // Just return hostname
            print(hostname)
        }

        return 0
    }

    static func getHostname() -> String? {
        var buffer = [CChar](repeating: 0, count: 256)

        #if canImport(Glibc)
        guard Glibc.gethostname(&buffer, buffer.count) == 0 else {
            return nil
        }
        #elseif canImport(Darwin)
        guard Darwin.gethostname(&buffer, buffer.count) == 0 else {
            return nil
        }
        #else
        return nil
        #endif

        // Convert CChar to UInt8 and create string
        if let nullIndex = buffer.firstIndex(of: 0) {
            let bytes = buffer[..<nullIndex].map { UInt8(bitPattern: $0) }
            return String(decoding: bytes, as: UTF8.self)
        }
        let bytes = buffer.map { UInt8(bitPattern: $0) }
        return String(decoding: bytes, as: UTF8.self)
    }

    static func setHostname(_ newName: String) -> Int32 {
        #if canImport(Glibc)
        let result = Glibc.sethostname(newName, newName.utf8.count)
        if result != 0 {
            FileHandle.standardError.write("hostname: you must be root to change the hostname\n".data(using: .utf8)!)
            return 1
        }
        return 0
        #elseif canImport(Darwin)
        let result = Darwin.sethostname(newName, Int32(newName.utf8.count))
        if result != 0 {
            FileHandle.standardError.write("hostname: you must be root to change the hostname\n".data(using: .utf8)!)
            return 1
        }
        return 0
        #else
        FileHandle.standardError.write("hostname: setting hostname not supported on this platform\n".data(using: .utf8)!)
        return 1
        #endif
    }

    static func getFQDN(_ hostname: String) -> String {
        // If already contains a dot, it might be FQDN
        if hostname.contains(".") {
            return hostname
        }

        // Try to read from /etc/hosts
        if let hostsContent = try? String(contentsOfFile: "/etc/hosts", encoding: .utf8) {
            for line in hostsContent.components(separatedBy: "\n") {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty || trimmed.hasPrefix("#") {
                    continue
                }

                let parts = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                if parts.count >= 2 {
                    // Look for hostname in the hosts file
                    for i in 1..<parts.count {
                        if parts[i].hasPrefix(hostname) && parts[i].contains(".") {
                            return parts[i]
                        }
                    }
                }
            }
        }

        // Fallback: just return hostname (not truly FQDN but best effort)
        return hostname
    }

    static func getIPAddresses(_ hostname: String) -> Int32 {
        // Try to resolve hostname to IP
        var hints = addrinfo()
        hints.ai_family = AF_UNSPEC
        hints.ai_socktype = Int32(SOCK_STREAM.rawValue)

        var result: UnsafeMutablePointer<addrinfo>?

        #if canImport(Glibc)
        let status = Glibc.getaddrinfo(hostname, nil, &hints, &result)
        #elseif canImport(Darwin)
        let status = Darwin.getaddrinfo(hostname, nil, &hints, &result)
        #else
        FileHandle.standardError.write("hostname: IP lookup not supported on this platform\n".data(using: .utf8)!)
        return 1
        #endif

        guard status == 0, let addrList = result else {
            FileHandle.standardError.write("hostname: cannot resolve '\(hostname)'\n".data(using: .utf8)!)
            return 1
        }

        defer {
            #if canImport(Glibc)
            Glibc.freeaddrinfo(addrList)
            #elseif canImport(Darwin)
            Darwin.freeaddrinfo(addrList)
            #endif
        }

        var ipAddresses: [String] = []
        var currentAddr = addrList

        while true {
            let addr = currentAddr.pointee

            if addr.ai_family == AF_INET {
                // IPv4
                let sockaddr = addr.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
                var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))

                #if canImport(Glibc)
                var inAddr = sockaddr.sin_addr
                if let ipStr = Glibc.inet_ntop(AF_INET, &inAddr, &buffer, socklen_t(INET_ADDRSTRLEN)) {
                    ipAddresses.append(String(cString: ipStr))
                }
                #elseif canImport(Darwin)
                var inAddr = sockaddr.sin_addr
                if let ipStr = Darwin.inet_ntop(AF_INET, &inAddr, &buffer, socklen_t(INET_ADDRSTRLEN)) {
                    ipAddresses.append(String(cString: ipStr))
                }
                #endif
            } else if addr.ai_family == AF_INET6 {
                // IPv6
                let sockaddr = addr.ai_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { $0.pointee }
                var buffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))

                #if canImport(Glibc)
                var inAddr = sockaddr.sin6_addr
                if let ipStr = Glibc.inet_ntop(AF_INET6, &inAddr, &buffer, socklen_t(INET6_ADDRSTRLEN)) {
                    ipAddresses.append(String(cString: ipStr))
                }
                #elseif canImport(Darwin)
                var inAddr = sockaddr.sin6_addr
                if let ipStr = Darwin.inet_ntop(AF_INET6, &inAddr, &buffer, socklen_t(INET6_ADDRSTRLEN)) {
                    ipAddresses.append(String(cString: ipStr))
                }
                #endif
            }

            if let next = addr.ai_next {
                currentAddr = next
            } else {
                break
            }
        }

        if ipAddresses.isEmpty {
            FileHandle.standardError.write("hostname: cannot resolve '\(hostname)'\n".data(using: .utf8)!)
            return 1
        }

        print(ipAddresses.joined(separator: " "))
        return 0
    }
}
