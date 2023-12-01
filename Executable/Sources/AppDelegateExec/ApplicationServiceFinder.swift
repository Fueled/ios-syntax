//
//  ApplicationServiceFinder.swift
//
//
//  Created by Hadi Dbouk on 27/11/2023.
//

import Foundation
import SwiftParser
import SwiftSyntax

struct ApplicationServiceData {
	let className: String
	let functions: [FunctionDeclSyntax]
}

extension FunctionDeclSyntax {
	var key: String {
		name.trimmed.text + signature.trimmed.description
	}
}

class ApplicationServiceFinder: SyntaxAnyVisitor {
	private var appServicesData: [ApplicationServiceData] = []

	init() {
		super.init(viewMode: .all)
	}

	override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
		if node.inheritanceClause?.inheritedTypes.contains(where: { $0.type.description.trimmingCharacters(in: .whitespaces) == "ApplicationService" }) ?? false {
			let className = node.name.text

			var classFunctions = [FunctionDeclSyntax]()

			for member in node.memberBlock.members {
				if let memberBlock = member.as(MemberBlockItemSyntax.self) {
					for memberChild in memberBlock.children(viewMode: .all) {
						if let function = memberChild.as(FunctionDeclSyntax.self) {
							classFunctions.append(function)
						}
					}
				}
			}

			let appServiceData = ApplicationServiceData(className: className, functions: classFunctions)
			appServicesData.append(appServiceData)
		}
		return .skipChildren
	}

	static func find(in filePath: String) throws -> [ApplicationServiceData] {
		let fileURL = URL(fileURLWithPath: filePath)
		let fileContent = try String(contentsOf: fileURL, encoding: .utf8)

		let sourceFile = Parser.parse(source: fileContent)
		let finder = ApplicationServiceFinder()
		finder.walk(sourceFile)
		return finder.appServicesData
	}
}
