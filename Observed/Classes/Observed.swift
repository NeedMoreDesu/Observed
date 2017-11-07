//  Created by Oleksii Horishnii on 1/23/17.
//  Copyright © 2017 Oleksii Horishnii. All rights reserved.
//

import Foundation
import LazySeq

public class Observed<ObjectType, CallbackType: Callback0d> {
    public private(set) var obj: ObjectType
    public private(set) var callback: CallbackType
    public init(obj: ObjectType, callback: CallbackType = CallbackType()) {
        callback.setObjectToReset(obj as AnyObject)
        self.obj = obj
        self.callback = callback
    }
}

