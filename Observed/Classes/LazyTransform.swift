//
//  LazyTransform.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/28/17.
//

import Foundation

public class LazyTransform<Type>: Resetable0d {
    private var transform: (() -> Type)
    private var value: Type?
    
    public func get() -> Type {
        if let val = self.value {
            return val
        }
        let val = self.transform()
        self.value = val
        return val
    }
    public func reset() {
        self.value = nil
    }
    
    public init(_ transform: @escaping (() -> Type)) {
        self.transform = transform
    }
}
