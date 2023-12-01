//
//  AppDelegateDeclSyntax.swift
//
//
//  Created by Hadi Dbouk on 01/12/2023.
//

import SwiftSyntax

enum AppDelegateDeclSyntax {
	static func generate(appServices: [ApplicationServiceData]) -> some DeclSyntaxProtocol {
		let functions = appServices.reduce(into: [String: [ApplicationServiceData]]()) { result, appService in
			appService.functions.forEach { function in
				result[function.key, default: []].append(appService)
			}
		}
			.sorted { $0.key < $1.key }

		let inheritanceClause = InheritanceClauseSyntax {
			InheritedTypeSyntax(type: TypeSyntax("UIResponder"))
			InheritedTypeSyntax(type: TypeSyntax("UIApplicationDelegate"))
		}

		return ClassDeclSyntax(
			name: "AppDelegate",
			inheritanceClause: inheritanceClause
		) {
			DeclSyntax("var window: UIWindow?")

			for (key, appServices) in functions {
				if let functionSyntax = appServices.first?.functions.first(where: { $0.key == key }) {
					FunctionDeclSyntax(
						name: functionSyntax.name,
						signature: functionSyntax.signature
					) {
						let returnType = functionSyntax.signature.returnClause?.type.trimmed.description
						switch returnType {
						case nil:
							// A void function
							let codeBlockItems = Self.callFunctions(functionSyntax: functionSyntax, appServices: appServices)
								.map {
									let item = CodeBlockItemSyntax.Item($0)
									return CodeBlockItemSyntax(item: item)
								}
							CodeBlockItemListSyntax(codeBlockItems)
						case "Bool":
							Self.arrayOfFunctionCalls(functionSyntax: functionSyntax, appServices: appServices)
							ExprSyntax(".reduce(false) { $0 || $1 }")
						case
							"UISceneConfiguration",
							"UIInterfaceOrientationMask",
							"UIBackgroundFetchResult":
							Self.arrayOfFunctionCalls(functionSyntax: functionSyntax, appServices: appServices)
							ExprSyntax(".first!")
						case let returnType where returnType!.hasSuffix("?"):
							Self.arrayOfFunctionCalls(functionSyntax: functionSyntax, appServices: appServices)
							ExprSyntax(".compactMap { $0 }.first")
						default:
							DeclSyntax("fatalError(\"Not Implemented Yet!\")")
						}
					}
					.with(\.leadingTrivia, .newlines(2))
				}
			}
		}
	}
}

private extension AppDelegateDeclSyntax {
	static func callFunctions(functionSyntax: FunctionDeclSyntax, appServices: [ApplicationServiceData]) -> [ExprSyntax] {
		let isAsync = functionSyntax.signature.effectSpecifiers?.asyncSpecifier != nil
		return appServices
			.map { appService in
				let callee = MemberAccessExprSyntax(
					base: ExprSyntax("\(raw: appService.className).shared"),
					period: .periodToken(),
					name: functionSyntax.name
				)
				let expression = ExprSyntax(
					FunctionCallExprSyntax(callee: callee) {
						LabeledExprListSyntax {
							for parameter in functionSyntax.signature.parameterClause.parameters {
								let isArgumentNameExist = parameter.firstName.trimmed.text != "_"
								LabeledExprSyntax(
									label:  isArgumentNameExist ? parameter.firstName.trimmed : nil,
									colon: isArgumentNameExist ? .colonToken() : nil,
									expression: DeclReferenceExprSyntax(
										baseName: parameter.secondName ?? parameter.firstName
									)
								)
							}
						}
					}
				)

				if isAsync {
					return ExprSyntax(AwaitExprSyntax(expression: expression))
				} else {
					return expression
				}
			}
	}

	static func arrayOfFunctionCalls(functionSyntax: FunctionDeclSyntax, appServices: [ApplicationServiceData]) -> ExprSyntax {
		let arrayElementList = ArrayElementListSyntax {
			for function in Self.callFunctions(functionSyntax: functionSyntax, appServices: appServices) {
				ArrayElementSyntax(leadingTrivia: .newline, expression: ExprSyntax(function))
			}
		}
		return ExprSyntax(
			ArrayExprSyntax(
				leftSquare: .leftSquareToken(),
				elements: arrayElementList,
				rightSquare: .rightSquareToken(leadingTrivia: .newline)
			)
		)
	}
}
