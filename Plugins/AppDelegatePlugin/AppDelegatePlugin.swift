import Foundation
import PackagePlugin
import XcodeProjectPlugin

@main
struct AppDelegatePlugin: BuildToolPlugin {
	func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
		[]
	}
}

extension AppDelegatePlugin: XcodeBuildToolPlugin {
	func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
		let outputPath = context.pluginWorkDirectory.appending("AppDelegate.generated.swift")
		let generatorTool = try context.tool(named: "AppDelegateExec")
		let files = target
			.inputFiles
			.filter { $0.path.extension == "swift"}
			.map { $0.path.string }

		return [
			appDelegateBuildCommand(
				toolPath: generatorTool.path,
				files: files,
				outputPath: outputPath
			)
		]
	}
}

private func appDelegateBuildCommand(toolPath: Path, files: [String], outputPath: Path) -> Command {
	.buildCommand(
		displayName: "App Delegate Generator",
		executable: toolPath,
		arguments: [
			"--files",
			files,
			"--output-path",
			outputPath
		],
		outputFiles: [outputPath]
	)
}
