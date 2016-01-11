//
//  CoOperation.swift
//  CoOperation
//
//  Created by Max Desiatov on 10/01/2016.
//  Copyright © 2016 Max Desiatov. All rights reserved.
//

import Foundation

protocol Operational {
  func start()

  var onCompletion: (() -> ())? { get set }
}

protocol Enqueueable: Operational {
  func enqueue(q: NSOperationQueue)

  var queue: NSOperationQueue? { get set }
}

extension NSOperation: Enqueueable {
  private struct AssociatedKey {
    static var operationQueue = "operationQueue"
  }

  func seq(op: NSOperation) -> NSOperation {
    op.addDependency(self)

    if let q = queue {
      op.enqueue(q)
    }

    return op
  }

  // FIXME: The exact execution context for your completion block is not 
  // guaranteed but is typically a secondary thread. Therefore, you should not 
  // use this block to do any work that requires a very specific execution 
  // context. Instead, you should shunt that work to your application’s main 
  // thread or to the specific thread that is capable of doing it. For example, 
  // if you have a custom thread for coordinating the completion of the 
  // operation, you could use the completion block to ping that thread.
  var onCompletion: (() -> ())? {
    get {
      return completionBlock
    }

    set {
      completionBlock = newValue
    }
  }

  var queue: NSOperationQueue? {
    get {
      return getWeakAssociatedObject(self,
        associativeKey: &AssociatedKey.operationQueue)
    }

    set {
      if let value = newValue {
        setWeakAssociatedObject(self, value: value,
          associativeKey: &AssociatedKey.operationQueue,
          policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }

  func enqueue(q: NSOperationQueue) {
    q.addOperation(self)

    queue = q
  }
}

protocol Failable: Operational {
  var onFailure: (ErrorType -> ()) { get set }
}

protocol Producer: Operational {
  typealias Result

  var onSuccess: (Result -> ())? { get set }
}

protocol Consumer: Operational {
  typealias Input

  init(value: Input)
}

extension Producer {
  mutating func then<C where C: Consumer,
  C.Input == Result>(handler: Result -> C) {
    onSuccess = { r in
      handler(r).start()
    }
  }
}

// op1.then(op2).then(OP3Constructor)
