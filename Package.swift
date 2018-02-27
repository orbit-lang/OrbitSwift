import PackageDescription

let package = Package(
    name: "orbit",
    dependencies: [
    	.Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(1, 0, 0)..<Version(4, .max, .max)),
    	.Package(url: "https://github.com/jakeheis/SwiftCLI.git", majorVersion: 3),
    	.Package(url: "https://github.com/trill-lang/LLVMSwift", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/daviejaneway/OrbitCompilerUtils.git", majorVersion: 0),
        .Package(url: "https://github.com/daviejaneway/OrbitFrontend.git", majorVersion: 0),
        .Package(url: "https://github.com/daviejaneway/OrbitBackend.git", majorVersion: 0)
    ]
)
