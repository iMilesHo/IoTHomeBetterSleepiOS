//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//
// SPDX-License-Identifier: MIT
//


import Foundation
import FirebaseAuth


struct HealthData: Codable {
    var date: String
    var steps: Double?
    var activeEnergy: Double?
    var exerciseMinutes: Double?
    var bodyWeight: Double?
    var sleepHours: Double?
    var heartRate: Double?
    var userID: String? = Auth.auth().currentUser?.uid ?? "anonymous"
    
    var dictionary: [String: Any] {
        return [
            "userID": userID ?? "anonymous",
            "date": date,
            "steps": steps ?? 0,
            "activeEnergy": activeEnergy ?? 0,
            "exerciseMinutes": exerciseMinutes ?? 0,
            "bodyWeight": bodyWeight ?? 0,
            "sleepHours": sleepHours ?? 0,
            "heartRate": heartRate ?? 0
        ]
    }
}
