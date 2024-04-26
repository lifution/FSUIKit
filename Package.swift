// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "FSUIKitSwift",
                      platforms: [.iOS(.v12)],
                      products: [
                          .library(name: "FSUIKitSwift", targets: ["FSUIKitSwift"])
                      ],
	                    targets: [
	                        .target(name: "FSUIKitSwift", 
	                                path: "Sources/Classes",
	                                resources: [.process("Sources/Assets")])
                    	],
                      swiftLanguageVersions: [.v5]
)
