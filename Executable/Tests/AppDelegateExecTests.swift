//
//  AppDelegateExecTests.swift
//  
//
//  Created by Hadi Dbouk on 27/11/2023.
//

@testable import AppDelegateExec

import ArgumentParser
import XCTest

/*
	The goal of this unit test is to make it easier to execute the Xcode Plugin Command Line,
	It's possible now to go through the debugger line by line and see the values coming from the SwiftSyntax framework.
*/
final class AppDelegateExecTests: XCTestCase {
	/*
	 In a String format, add below all the file paths that will be used by SwiftSyntax for grabbing all the classes conforming to the ApplicationService protocol.
	 Ex:
	 var files =
	 """
		[
			"/Users/hadi/Documents/Fueled/project-template-ios/FueledTemplate/Code/Helpers/Extensions/NSAttributedString+LocalizedFormat.swift",
			"/Users/hadi/Documents/Fueled/project-template-ios/FueledTemplate/Code/Application/Services/AppCenterApplicationService.swift",
			"/Users/hadi/Documents/Fueled/project-template-ios/FueledTemplate/Code/Helpers/Errors/ApplicationError.swift"
		]
	 """
	 */
	var files =
	"""
		[
		]
	"""

	func testTheGeneration() throws {
		try AppDelegateExec.run(files: files, outputPath: "")
	}
}
