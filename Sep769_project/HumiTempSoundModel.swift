//
//  HumiTempSoundModel.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-17.
//

import Foundation
import Firebase


struct HumiTempSoundModel {

  var edgeDeviceID: String
  var userID: String
  var created: Int64
  var humidity: Double
  var noiseLevel: Double
  var temperature: Double

  var dictionary: [String: Any] {
    return [
      "EdgeDeviceID": edgeDeviceID,
      "userID": userID,
      "created": created,
      "humidity": humidity,
      "noiseLevel": noiseLevel,
      "temperature": temperature,
    ]
  }

}

extension HumiTempSoundModel: DocumentSerializable {

  init?(dictionary: [String : Any]) {
    guard let edgeDeviceID = dictionary["EdgeDeviceID"] as? String,
        let userID = dictionary["userID"] as? String,
        let created = dictionary["created"] as? Int64,
        let humidity = dictionary["humidity"] as? Double,
        let noiseLevel = dictionary["noiseLevel"] as? Double,
        let temperature = dictionary["temperature"] as? Double else { return nil }

      self.init(edgeDeviceID: edgeDeviceID, userID: userID, created: created, humidity: humidity, noiseLevel: noiseLevel, temperature: temperature)
  }
}

struct Review {

  var rating: Int // Can also be enum
  var userID: String
  var username: String
  var text: String
  var date: Date

  var dictionary: [String: Any] {
    return [
      "rating": rating,
      "userId": userID,
      "userName": username,
      "text": text,
      "timestamp": Timestamp(date: date)
    ]
  }

}

extension Review: DocumentSerializable {

  init?(dictionary: [String : Any]) {
    guard let rating = dictionary["rating"] as? Int,
        let userID = dictionary["userId"] as? String,
        let username = dictionary["userName"] as? String,
        let text = dictionary["text"] as? String,
        let date = dictionary["timestamp"] as? Timestamp else { return nil }
    
    self.init(rating: rating, userID: userID, username: username, text: text, date: date.dateValue())
  }

}


