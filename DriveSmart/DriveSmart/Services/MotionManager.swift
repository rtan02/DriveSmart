//
//  MotionManager.swift
//  DriveSmart
//
//  Created by Michael Tan on 2024-11-27.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    private var motion = CMMotionManager()
    @Published var isHardBraking = false
    @Published var isHardAcceleration = false
    @Published var isHardTurning = false
    
    private let hardBrakeThreshold: Double = -2.5 // m/s^2
    private let hardAccelerationThreshold: Double = 2.5 // m/s^2
    private let hardTurnThreshold: Double = 4.0 // radians/second
    
    func startMotionTracking() {
        if motion.isAccelerometerAvailable && motion.isGyroAvailable {
            motion.accelerometerUpdateInterval = 0.1 // Update every 0.1 seconds
            motion.gyroUpdateInterval = 0.1
            
            // Accelerometer Updates
            motion.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                if let accelerometerData = data {
                    let accelerationZ = accelerometerData.acceleration.z
                    
                    // Detect hard braking (significant negative acceleration)
                    self?.isHardBraking = accelerationZ < self?.hardBrakeThreshold ?? -2.5
                    
                    // Detect hard acceleration (significant positive acceleration)
                    self?.isHardAcceleration = accelerationZ > self?.hardAccelerationThreshold ?? 2.5
                }
            }
            
            // Gyroscope Updates
            motion.startGyroUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                if let gyroData = data {
                    let rotationRateY = gyroData.rotationRate.y
                    
                    // Detect hard turning (high angular velocity)
                    self?.isHardTurning = abs(rotationRateY) > self?.hardTurnThreshold ?? 4.0
                }
            }
        }
    }
    
    func stopUpdates() {
        motion.stopAccelerometerUpdates()
        motion.stopGyroUpdates()
    }
}
