// swift-tools-version: 5.9

import PackageDescription

let package = Package(
	name: "FueledSyntax",
	platforms: [
		.macOS(.v13), .iOS(.v16), .tvOS(.v12), .watchOS(.v4),
	],
	products: [
		.library(
			name: "FueledSyntax",
			targets: [
				"FueledSyntax"
			]
		),
		.plugin(
			name: "AppDelegatePlugin",
			targets: [
				"AppDelegatePlugin",
			]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.2"),
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3"),
	],
	targets: [
		.target(
			name: "FueledSyntax",
			path: "FueledSyntax"
		),
		.executableTarget(
			name: "AppDelegateExec",
			dependencies: [
				.product(name: "SwiftSyntax", package: "swift-syntax"),
				.product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			path: "Executable/Sources"
		),
		.testTarget(
			name: "AppDelegateExecTests",
			dependencies: [
				"AppDelegateExec",
				.product(name: "SwiftSyntax", package: "swift-syntax"),
				.product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			path: "Executable/Tests"
		),
		.plugin(
			name: "AppDelegatePlugin",
			capability: .buildTool(),
			dependencies: [
				.target(name: "AppDelegateExec"),
			],
			packageAccess: true
		),
	]
)
