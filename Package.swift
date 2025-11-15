// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swiftybox",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
    ],
    targets: [
        .systemLibrary(
            name: "BusyBox",
            path: "BusyBox"
        ),

        .executableTarget(
            name: "swiftybox",
            dependencies: [
                "BusyBox",
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            swiftSettings: [
                .unsafeFlags(["-I", "../busybox/include"])
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-L../busybox",
                    "-lbusybox"
                ])
            ]
        ),

        .testTarget(
            name: "SwiftyBoxTests",
            dependencies: ["swiftybox"]
        ),
    ]
)
