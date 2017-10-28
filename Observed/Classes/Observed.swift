//  Created by Oleksii Horishnii on 1/23/17.
//  Copyright © 2017 Oleksii Horishnii. All rights reserved.
//

import Foundation
import LazySeq

public class Observed<ObjectType, ObserverType> {
    public private(set) var obj: ObjectType
    public private(set) var observer: ObserverType
    public init(obj: ObjectType, observer: ObserverType) {
        self.obj = obj
        self.observer = observer
    }
}

