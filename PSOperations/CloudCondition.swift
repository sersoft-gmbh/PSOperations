/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if !os(watchOS)

import CloudKit

#if swift(>=3.1)
public extension ErrorInformation.Key {
    public static var cloudKitContainer: ErrorInformation.Key<CKContainer> {
        return .init(rawValue: "CKContainer")
    }

    public static var cloudKitError: ErrorInformation.Key<Error> {
        return .init(rawValue: "CKError")
    }
}
#else
public extension ErrorInformationKey {
    public static var cloudKitContainer: ErrorInformationKey<CKContainer> {
        return .init(rawValue: "CKContainer")
    }

    public static var cloudKitError: ErrorInformationKey<Error> {
        return .init(rawValue: "CKError")
    }
}
#endif

/// A condition describing that the operation requires access to a specific CloudKit container.
@available(*, deprecated, message: "use Capability(iCloudContainer(...)) instead")
    
public struct CloudContainerCondition: OperationCondition {
    
    public static let name = "CloudContainer"
    
    /*
        CloudKit has no problem handling multiple operations at the same time
        so we will allow operations that use CloudKit to be concurrent with each
        other.
    */
    public static let isMutuallyExclusive = false
    
    let container: CKContainer // this is the container to which you need access.

    let permission: CKApplicationPermissions
    
    /**
        - parameter container: the `CKContainer` to which you need access.
        - parameter permission: the `CKApplicationPermissions` you need for the
            container. This parameter has a default value of `[]`, which would get
            you anonymized read/write access.
    */
    public init(container: CKContainer, permission: CKApplicationPermissions = []) {
        self.container = container
        self.permission = permission
    }
    
    public func dependencyForOperation(_ operation: Operation) -> Foundation.Operation? {
        return CloudKitPermissionOperation(container: container, permission: permission)
    }
    
    public func evaluateForOperation(_ operation: Operation, completion: @escaping (OperationConditionResult) -> Void) {
        container.verifyPermission(permission, requestingIfNecessary: false) { error in
            if let error = error {
                var info = ErrorInformation(key: .cloudKitContainer, value: self.container)
                info.set(value: error, for: .cloudKitError)
                let conditionError = ConditionError(condition: self, errorInformation: info)

                completion(.failed(conditionError))
            }
            else {
                completion(.satisfied)
            }
        }
    }
}

/**
    This operation asks the user for permission to use CloudKit, if necessary.
    If permission has already been granted, this operation will quickly finish.
*/
class CloudKitPermissionOperation: Operation {
    let container: CKContainer
    let permission: CKApplicationPermissions
    
    init(container: CKContainer, permission: CKApplicationPermissions) {
        self.container = container
        self.permission = permission
        super.init()
        
        if permission != [] {
            /*
                Requesting non-zero permissions means that this potentially presents
                an alert, so it should not run at the same time as anything else
                that presents an alert.
            */
            addCondition(AlertPresentation())
        }
    }
    
    override func execute() {
        container.verifyPermission(permission, requestingIfNecessary: true) { error in
            self.finishWithError(error)
        }
    }
    
}

#endif
