//
//  ApplicationService.swift
//  
//
//  Created by Hadi Dbouk on 01/12/2023.
//

import UIKit

public protocol ApplicationService: UIApplicationDelegate {
	associatedtype ApplicationServiceType
	static var shared: ApplicationServiceType { get }
}

public extension ApplicationService {
	var window: UIWindow? {
		UIApplication.shared.delegate?.window.flatMap { $0 }
	}
}
