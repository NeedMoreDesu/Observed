//
//  LazyTransform.swift
//  Observed
//
//  Created by Oleksii Horishnii on 10/28/17.
//

import Foundation

public class LazyTransform<Type>: GeneratedTransform<Type>, Resetable0d {
    private var stored: Type?
    
    public override func value() -> Type {
        if let val = self.stored {
            return val
        }
        let val = super.value()
        self.stored = val
        return val
    }
    public func reset() {
        self.stored = nil
    }
}
