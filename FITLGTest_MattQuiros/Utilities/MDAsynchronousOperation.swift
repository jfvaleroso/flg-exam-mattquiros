//
//  MDAsynchronousOperation.swift
//  Mold
//
//  Created by Matt Quiros on 19/07/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import Foundation

open class MDAsynchronousOperation<ResultType, ErrorType>: MDOperation<ResultType, ErrorType> {
    
    open override var isConcurrent: Bool {
        return true
    }
    
    open override var isAsynchronous: Bool {
        return true
    }
    
    open override func start() {
        guard self.isCancelled == false &&
            self.hasFailedDependencies == false &&
            self.shouldExecute()
            else {
                self.setFinished(true)
                return
        }
        
        self.setExecuting(true)
        Thread.detachNewThreadSelector(#selector(main), toTarget: self, with: nil)
    }
    
}
