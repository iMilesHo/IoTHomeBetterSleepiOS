//
//  SleepQualituyFeedbackModel.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-17.
//

import Foundation
import Firebase
import HealthKit


struct SleepQualituyFeedbackModel {
  var userID: String
  var created: Int64
  var sleepQuaility: Int

  var dictionary: [String: Any] {
    return [
      "userID": userID,
      "created": created,
      "sleepQuaility": sleepQuaility
    ]
  }

}

extension SleepQualituyFeedbackModel: DocumentSerializable {

  init?(dictionary: [String : Any]) {
    guard let userID = dictionary["userID"] as? String,
        let created = dictionary["created"] as? Int64,
        let sleepQuaility = dictionary["sleepQuaility"] as? Int else { return nil }

      self.init(userID: userID, created: created, sleepQuaility: sleepQuaility)
  }
}


struct TurnOnOffRecordModel {
  var userID: String
  var created: Int64
  var turnOrOff: Bool

  var dictionary: [String: Any] {
    return [
      "userID": userID,
      "created": created,
      "turnOrOff": turnOrOff
    ]
  }

}

extension TurnOnOffRecordModel: DocumentSerializable {

  init?(dictionary: [String : Any]) {
    guard let userID = dictionary["userID"] as? String,
        let created = dictionary["created"] as? Int64,
        let turnOrOff = dictionary["turnOrOff"] as? Bool else { return nil }

      self.init(userID: userID, created: created, turnOrOff: turnOrOff)
  }
}

struct HealthKitDataFirestoreModel {
    var userID: String
    var date: Int64
    var steps: Double?
    var activeEnergy: Double?
    var exerciseMinutes: Double?
    var bodyWeight: Double?
    var sleepHours: Double?
    var heartRate: Double?

    var dictionary: [String: Any] {
        return [
            "userID": userID,
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

extension HealthKitDataFirestoreModel: DocumentSerializable {

  init?(dictionary: [String : Any]) {
      let userID = dictionary["userID"] as? String ?? "anonymous"
      let date = dictionary["date"] as? Int64 ?? Int64(Date().timeIntervalSince1970)
      let steps = dictionary["steps"] as? Double ?? 0
      let activeEnergy = dictionary["activeEnergy"] as? Double ?? 0
      let exerciseMinutes = dictionary["exerciseMinutes"] as? Double ?? 0
      let bodyWeight = dictionary["bodyWeight"] as? Double ?? 0
      let sleepHours = dictionary["sleepHours"] as? Double ?? 0
      let heartRate = dictionary["heartRate"] as? Double ?? 0

      self.init(userID: userID, date: date, steps: steps, activeEnergy: activeEnergy, exerciseMinutes: exerciseMinutes, bodyWeight: bodyWeight,sleepHours: sleepHours, heartRate: heartRate)
  }
}

