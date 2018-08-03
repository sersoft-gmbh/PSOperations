//
//  CloudCapability.swift
//  PSOperations
//
//  Created by Dev Team on 10/4/15.
//  Copyright © 2015 Pluralsight. All rights reserved.
//

#if !os(watchOS)

import Foundation
import CloudKit

public struct iCloudContainer: CapabilityType {
    
    public static let name = "iCloudContainer"
    
    fileprivate let container: CKContainer
    fileprivate let permissions: CKContainer_Application_Permissions

    #if swift(>=4.2)
    public init(container: CKContainer, permissions: CKContainer_Application_Permissions = []) {
        self.container = container
        self.permissions = permissions
    }
    #else
    public init(container: CKContainer, permissions: CKApplicationPermissions = []) {
        self.container = container
        self.permissions = permissions
    }
    #endif
    
    public func requestStatus(_ completion: @escaping (CapabilityStatus) -> Void) {
        verifyAccountStatus(container, permission: permissions, shouldRequest: false, completion: completion)
    }
    
    public func authorize(_ completion: @escaping (CapabilityStatus) -> Void) {
        verifyAccountStatus(container, permission: permissions, shouldRequest: true, completion: completion)
    }
    
}

#if !swift(>=4.2)
fileprivate typealias CKContainer_Application_Permissions = CKApplicationPermissions
#endif

private func verifyAccountStatus(_ container: CKContainer, permission: CKContainer_Application_Permissions, shouldRequest: Bool, completion: @escaping (CapabilityStatus) -> Void) {
    container.accountStatus { accountStatus, accountError in
        switch accountStatus {
            case .noAccount: completion(.notAvailable)
            case .restricted: completion(.notAvailable)
            case .couldNotDetermine:
                let error = accountError ?? CKError(CKError.notAuthenticated)
                completion(.error(error))
            case .available:
                if permission != [] {
                    verifyPermission(container, permission: permission, shouldRequest: shouldRequest, completion: completion)
                } else {
                    completion(.authorized)
                }
        }
    }
}

private func verifyPermission(_ container: CKContainer, permission: CKContainer_Application_Permissions, shouldRequest: Bool, completion: @escaping (CapabilityStatus) -> Void) {
    container.status(forApplicationPermission: permission) { permissionStatus, permissionError in
        switch permissionStatus {
            case .initialState:
                if shouldRequest {
                    requestPermission(container, permission: permission, completion: completion)
                } else {
                    completion(.notDetermined)
                }
            case .denied: completion(.denied)
            case .granted: completion(.authorized)
            case .couldNotComplete:
                let error = permissionError ?? CKError(CKError.permissionFailure)
                completion(.error(error))
        }
    }
}

private func requestPermission(_ container: CKContainer, permission: CKContainer_Application_Permissions, completion: @escaping (CapabilityStatus) -> Void) {
    DispatchQueue.main.async {
        container.requestApplicationPermission(permission) { requestStatus, requestError in
            switch requestStatus {
                case .initialState: completion(.notDetermined)
                case .denied: completion(.denied)
                case .granted: completion(.authorized)
                case .couldNotComplete:
                    let error = requestError ?? CKError(CKError.permissionFailure)
                    completion(.error(error))
            }
        }
    }
}

#endif
