//
//  SleepQualituyFeedbackModel.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-17.
//

import Foundation
import Firebase


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




