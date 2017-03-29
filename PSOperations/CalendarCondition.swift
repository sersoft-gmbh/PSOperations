/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if !os(tvOS)
    
    import EventKit
    
    #if swift(>=3.1)
    public extension ErrorInformation.Key {
        public static var eventKitEntityType: ErrorInformation.Key<EKEntityType> {
            return .init(rawValue: "EKEntityType")
        }
    }
    #else
    public extension ErrorInformationKey {
        public static var eventKitEntityType: ErrorInformationKey<EKEntityType> {
            return .init(rawValue: "EKEntityType")
        }
    }
    #endif
    
    /// A condition for verifying access to the user's calendar.
    
    @available(*, deprecated, message: "use Capability(EKEntityType....) instead")
    
    public struct CalendarCondition: OperationCondition {
        
        public static let name = "Calendar"
        public static let isMutuallyExclusive = false
        
        public let entityType: EKEntityType
        
        public init(entityType: EKEntityType) {
            self.entityType = entityType
        }
        
        public func dependencyForOperation(_ operation: Operation) -> Foundation.Operation? {
            return CalendarPermissionOperation(entityType: entityType)
        }
        
        public func evaluateForOperation(_ operation: Operation, completion: @escaping (OperationConditionResult) -> Void) {
            switch EKEventStore.authorizationStatus(for: entityType) {
            case .authorized:
                completion(.satisfied)
                
            default:
                // We are not authorized to access entities of this type.
                let info = ErrorInformation(key: .eventKitEntityType, value: entityType)
                let error = ConditionError(condition: self, errorInformation: info)
                
                completion(.failed(error))
            }
        }
    }
    
    /**
    `EKEventStore` takes a while to initialize, so we should create
    one and then keep it around for future use, instead of creating
    a new one every time a `CalendarPermissionOperation` runs.
    */
    private let SharedEventStore = EKEventStore()
    
    /**
     A private `Operation` that will request access to the user's Calendar/Reminders,
     if it has not already been granted.
     */
    class CalendarPermissionOperation: Operation {
        let entityType: EKEntityType
        
        init(entityType: EKEntityType) {
            self.entityType = entityType
            super.init()
            addCondition(AlertPresentation())
        }
        
        override func execute() {
            let status = EKEventStore.authorizationStatus(for: entityType)
            
            switch status {
            case .notDetermined:
                DispatchQueue.main.async {
                    SharedEventStore.requestAccess(to: self.entityType) { granted, error in
                        self.finish()
                    }
                }
                
            default:
                finish()
            }
        }
        
    }
    
#endif
