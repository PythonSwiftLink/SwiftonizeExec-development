// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let development = true
let local = true

var swiftonize_string: String {
	if development { return "Swiftonize-development" }
	return "Swiftonize"
}

func packageName(_ name: String) -> String {
	if development { return "\(name)-development" }
	return name
}

var packages: [Package.Dependency] = [
	//.package(path: "../PyCodable"),
	.package(url: "https://github.com/kylef/PathKit", from: .init(1, 0, 0) ),
	.package(url: "https://github.com/apple/swift-syntax", from: .init(509, 0, 0) ),
	.package(url: "https://github.com/apple/swift-argument-parser", from: .init(1, 2, 0)),
	
	//.package(url: "https://github.com/PythonSwiftLink/PyCodable", branch: "master"),
	.package(url: "https://github.com/PythonSwiftLink/PythonCore", from: .init(311, 0, 0)),
	
	//.package(path: "../PythonTestSuite")
]

if local {
	packages.append(contentsOf: [
		//.package(path: "../\(packageName("Swiftonize"))"),
		.package(path: "/Volumes/CodeSSD/GitHub/Swiftonize"),
		.package(path: "../\(packageName("PythonSwiftLink"))"),
	])
} else {
	if development {
		packages.append(contentsOf: [
//			.package(url: "https://github.com/PythonSwiftLink/\(packageName("Swiftonize"))",branch: "development"),
			.package(url: "https://github.com/PythonSwiftLink/Swiftonize",branch: "development"),
			.package(url: "https://github.com/PythonSwiftLink/\(packageName("PythonSwiftLink"))",branch: "master")
			
		])
	} else {
		packages.append(contentsOf: [
			.package(url: "https://github.com/PythonSwiftLink/\(packageName("Swiftonize"))",from: .init(311, 0, 0)),
			.package(url: "https://github.com/PythonSwiftLink/\(packageName("PythonSwiftLink"))",from: .init(311, 0, 0))
		])
	}
	
}

let package = Package(
    name: "SwiftonizeExecutable",
	platforms: [.macOS(.v13)],
//	dependencies: [
//		.package(url: "https://github.com/PythonSwiftLink/PythonSwiftLink-development", branch: "master"),
//		.package(url: "https://github.com/PythonSwiftLink/PythonCore", from: .init(311, 0, 0)),
//		//.package(path: "../PythonSwiftLink-development"),
//		//.package(path: "../Swiftonize"),
//		.package(url: "https://github.com/PythonSwiftLink/Swiftonize-development", branch: "master"),
//		
//		
//	],
	dependencies: packages,
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "SwiftonizeExecutable",
			dependencies: [
				.product(name: "SwiftSyntax", package: "swift-syntax"),
				.product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "PySwiftCore", package: packageName("PythonSwiftLink")),
				.product(name: "PyDecode", package: packageName("PythonSwiftLink")),
				.product(name: "PyEncode", package: packageName("PythonSwiftLink")),
				.product(name: "PyCallable", package: packageName("PythonSwiftLink")),
				//.product(name: "SwiftonizeNew", package: packageName("Swiftonize")),
				.product(name: "SwiftonizeNew", package: "Swiftonize"),
				.product(name: "ShadowPip", package: "Swiftonize"),
				.product(name: "PythonCore", package: "PythonCore"),
				"PathKit"
			],
			swiftSettings: [
				//.define("LOCAL")
			]
		),
    ]
)
