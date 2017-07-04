import PackageDescription

let package = Package(
    name: "orb",
    dependencies: [
        .Package(url: "https://github.com/daviejaneway/OrbitCompilerUtils.git", majorVersion: 0),
        .Package(url: "https://github.com/daviejaneway/OrbitFrontend.git", majorVersion: 0)
    ]
)
