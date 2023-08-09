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

import Foundation

public struct DragGesture: Gesture {
    private var startLocation: CGPoint? = nil
    private var previousTimestamp: Date?
    private var velocity: CGSize = .zero
    private var onEndedAction: ((Value) -> Void)? = nil
    private var onChangedAction: ((Value) -> Void)? = nil
    public var minimumDistance: Double
    public var body: DragGesture {
        self
    }
    
    /// Creates a dragging gesture with the minimum dragging distance before the gesture succeeds and the coordinate space of the gesture’s location.
    /// By default, the minimum distance needed to recognize a gesture is 10.
    /// - Parameters:
    ///   - minimumDistance: The minimum dragging distance before the gesture succeeds.
    ///   - coordinateSpace: The coordinate space in which to receive location values.
    public init(minimumDistance: Double = 10) {
        self.minimumDistance = minimumDistance
    }

    public mutating func _onPhaseChange(_ phase: _GesturePhase) {
        switch phase {
        case .began(let location):
            startLocation = location
            previousTimestamp = nil
            velocity = .zero
        case .changed(let location) where startLocation != nil:
            guard let startLocation else { return }
            let translation = calculateTranslation(from: startLocation, to: location)
            let distance = calculateDistance(xOffset: translation.width, yOffset: translation.height)
            
            // Do nothing if gesture has not met the criteria
            guard minimumDistance < distance else { return }
            let currentTimestamp = Date()
            let timeElapsed = Double(currentTimestamp.timeIntervalSince(previousTimestamp ?? currentTimestamp))
            let velocity = calculateVelocity(from: translation, timeElapsed: timeElapsed)
            self.velocity = velocity
            
            // Predict end location based on velocity
            let predictedEndLocation = calculatePredictedEndLocation(from: location, velocity: velocity)
            
            // Predict end translation based on velocity
            let predictedEndTranslation = calculatePredictedEndTranslation(from: translation, velocity: velocity)
            
            onChangedAction?(
                Value(
                    startLocation: startLocation,
                    location: location,
                    predictedEndLocation: predictedEndLocation,
                    translation: translation,
                    predictedEndTranslation: predictedEndTranslation
                )
            )
        case .changed:
            break
        case .ended(let location):
            if let startLocation {
                let translation = calculateTranslation(from: startLocation, to: location)
                let distance = calculateDistance(xOffset: translation.width, yOffset: translation.height)
                onEndedAction?(
                    Value(
                        startLocation: startLocation,
                        location: location,
                        predictedEndLocation: location,
                        translation: translation,
                        predictedEndTranslation: translation
                    )
                )
            }
            startLocation = nil
        case .cancelled:
            startLocation = nil
        }
    }
    
    public func _onEnded(perform action: @escaping (Value) -> Void) -> Self {
        var gesture = self
        gesture.onEndedAction = action
        return gesture
    }
    
    public func _onChanged(perform action: @escaping (Value) -> Void) -> Self {
        var gesture = self
        gesture.onChangedAction = action
        return gesture
    }
    
    // MARK: Types
    
    public struct Value: Equatable {
        /// The location of the drag gesture’s first event.
        public var startLocation: CGPoint = .zero
        
        /// The location of the drag gesture’s current event.
        public var location: CGPoint = .zero
        
        /// A prediction, based on the current drag velocity, of where the final location will be if dragging stopped now.
        public var predictedEndLocation: CGPoint = .zero
        
        /// The total translation from the start of the drag gesture to the current event of the drag gesture.
        public var translation: CGSize = .zero
        
        /// A prediction, based on the current drag velocity, of what the final translation will be if dragging stopped now.
        public var predictedEndTranslation: CGSize = .zero
    }
}