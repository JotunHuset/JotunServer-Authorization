
import PackageDescription

let package = Package(
    name: "JotunServer-Authorization",
    targets: [
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git",                majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/BlueCryptor.git", majorVersion: 0, minor: 8),
        .Package(url: "https://github.com/davidungar/miniPromiseKit",           majorVersion: 4),
    ]
)
