// Copyright 2020 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Szymon on 16/7/2023.
//

public struct _EndedGesture<Base: Gesture>: Gesture {
  public typealias Value = Base.Value

  private var gesture: Base
  private var onEnded: (Value) -> ()
  private var onChanged: ((Value) -> ())?

  public var body: Base.Body {
    var gesture = gesture._onEnded(perform: onEnded)
    if let onChanged {
      gesture = gesture._onChanged(perform: onChanged)
    }
    return gesture.body
  }

  init(_ gesture: Base, onEnded: @escaping (Value) -> ()) {
    self.gesture = gesture
    self.onEnded = onEnded
  }

  public mutating func _onPhaseChange(_ phase: _GesturePhase) -> Bool {
    fatalError(
      "\(String(reflecting: Self.self)) is a proxy `Gesture`, onPhaseChange should never be called."
    )
  }

  public func _onEnded(perform action: @escaping (Value) -> ()) -> Self {
    var gesture = self
    gesture.onEnded = action
    return gesture
  }

  public func _onChanged(perform action: @escaping (Value) -> ()) -> Self {
    var gesture = self
    gesture.onChanged = action
    return gesture
  }
}
