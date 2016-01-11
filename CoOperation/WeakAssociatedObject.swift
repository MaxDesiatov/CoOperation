//
//  AssociatedObject.swift
//  CoOperation
//
//  Created by Max Desiatov on 10/01/2016.
//  Copyright © 2016 Max Desiatov. All rights reserved.
//

import Foundation
import ObjectiveC

final class Weak<T: AnyObject> {
  weak var value: T?
  init(_ x: T) {
    value = x
  }
}

func setWeakAssociatedObject<T: AnyObject>(object: AnyObject, value: T,
associativeKey: UnsafePointer<Void>, policy: objc_AssociationPolicy) {
  objc_setAssociatedObject(object, associativeKey, Weak(value),  policy)
}

func getWeakAssociatedObject<T: AnyObject>(object: AnyObject,
associativeKey: UnsafePointer<Void>) -> T? {
  if let v = objc_getAssociatedObject(object, associativeKey) as? Weak<T> {
    return v.value
  } else {
    return nil
  }
}
