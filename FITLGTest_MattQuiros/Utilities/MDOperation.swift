//
//  MDOperation.swift
//  Mold
//
//  Created by Matt Quiros on 19/07/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import Foundation

/// A necessary protocol to which all `MDOperation`s must internally conform so that
/// the `hasFailedDependencies` computed property can be implemented.
protocol MDOperationProtocol {
    
    /// Must be set to true if the operation's `result` property is set to `.error`.
    var failed: Bool { get set }
    
}

open class MDOperation<ResultType, ErrorType>: Operation, MDOperationProtocol {
    
    public indirect enum Result {
        case none
        case success(ResultType)
        case error(ErrorType)
    }
    
    public typealias MDOperationCompletionBlock = (MDOperation.Result) -> Void
    
    var failed = false
    fileprivate var internalExecuting = false
    fileprivate var internalFinished = false
    
    open override var isExecuting: Bool {
        return self.internalExecuting
    }
    
    open override var isFinished: Bool {
        return self.internalFinished
    }
    
    open var result = MDOperation.Result.none {
        didSet {
            switch result {
            case .error(_):
                self.failed = true
            default:
                self.failed = false
            }
        }
    }
    
    /**
     Checks whether the operation has any dependencies that inherit from `MDOperation` and whose `result` is `.error`.
     
     Returns `true` if at least one of the dependencies is a `MDOperation` and the `result` is `.error`.
     Returns `false` if none of the dependencies is a `MDOperation`, or none of the `MDOperation` dependencies
     have `.error` for a result.
     */
    public var hasFailedDependencies: Bool {
        let hasFailedDependencies = self.dependencies.contains(where: {
            if let operation = $0 as? MDOperationProtocol,
                operation.failed == true {
                return true
            }
            return false
        })
        return hasFailedDependencies
    }
    
    public init(completionBlock: MDOperationCompletionBlock?) {
        super.init()
        
        guard let completionBlock = completionBlock
            else {
                return
        }
        
        self.completionBlock = {[weak self] in
            guard let weakSelf = self
                else {
                    return
            }
            completionBlock(weakSelf.result)
        }
    }
    
    open func shouldExecute() -> Bool {
        return true
    }
    
    open override func start() {
        if self.hasFailedDependencies || self.shouldExecute() == false {
            self.setFinished(true)
            return
        }
        
        self.setExecuting(true)
        self.main()
        
        self.finish()
    }
    
    /**
     Sets the internal executing flag and makes the proper KVO calls.
     */
    public func setExecuting(_ executing: Bool) {
        self.willChangeValue(forKey: "isExecuting")
        self.internalExecuting = executing
        self.didChangeValue(forKey: "isExecuting")
    }
    
    /**
     Sets the internal finished flag and makes the proper KVO calls.
     */
    public func setFinished(_ finished: Bool) {
        self.willChangeValue(forKey: "isFinished")
        self.internalFinished = finished
        self.didChangeValue(forKey: "isFinished")
    }
    
    /**
     Sets `isExecuting` to `false` and `isFinished` to `true`.
     */
    public func finish() {
        self.setExecuting(false)
        self.setFinished(true)
    }
    
}
