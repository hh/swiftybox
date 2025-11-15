// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swiftybox",
    targets: [
        .systemLibrary(
            name: "BusyBox",
            path: "BusyBox"
        ),

        .executableTarget(
            name: "swiftybox",
            dependencies: ["BusyBox"],
            swiftSettings: [
                .unsafeFlags(["-I", "../../busybox/include"])
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-L../../busybox",
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
