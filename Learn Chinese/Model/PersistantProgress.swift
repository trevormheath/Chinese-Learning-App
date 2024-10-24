//
//  PersistantProgress.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/17/24.
//

//import SwiftUI
//
//typealias ItemProgress = [String: Bool]
//typealias TopicProgress = [String: ItemProgress]
//
////let myProgress: TopicProgress = [
////    "Numbers (1 to 10)": ["read": true, "studied":true, "passed":true],
////    "Months of the Year": ["read": true, "studied":true, "passed":true],
////]
//
//struct PersistentProgress {
//    private static func defaultProgress() -> TopicProgress {
//        //somewhere have an array of topics
//        var defaultProgress: TopicProgress = [:]
//        for topic in model.topics {
//            defaultProgress[topic.title] = [
//                "read": false,
//                "studied": false,
//                "passed": false
//            ]
//        }
//        return defaultProgress
//    }
//    
//    private static func readProgress() -> TopicProgress {
//        UserDefaults.standard.dictionary(forKey: Key.progress) as? TopicProgress ?? defaultProgress()
//    }
//    
//    var progress = PersistentProgress.readProgress() {
//        didSet {
//            UserDefaults.standard.set(progress, forKey: Key.progress)
//        }
//    }
//
//    private struct Key {
//        static let progress = "Progress"
//        static let highSchore = "HighScore"
//    }
//}
