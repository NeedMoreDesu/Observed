//
//  GeneratedTransform.swift
//  Observed
//
//  Created by Oleksii Horishnii on 11/4/17.
//

import Foundation

public class GeneratedTransform<Type> {
    private var transform: (() -> Type)
    
    public func value() -> Type {
        return self.transform()
    }
    
    public init(_ transform: @escaping (() -> Type)) {
        self.transform = transform
    }
}
