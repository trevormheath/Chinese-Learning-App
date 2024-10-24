//
//  Model.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/17/24.
//

import Foundation

protocol LessonPlan {
    var languageName: String {get}
    var topics: [Language.Topic] {get}
    var progress: [Language.Progress] {get set}
    
    mutating func toggleLessonRead(for title: String)
}

struct Language {
    
    struct Topic: Identifiable {
        var id = UUID()
        var title: String
        var lesonText: String
        var vocabulary: [Term]
        var quiz: [QuizItem]
    }
    
    struct Term {
        var targetWord: String
        var translation: String
    }
    
//    enum QuestionType {
//        case trueFalse
//        case multipleChoice
//        case fillInTheBlank
//    }

    struct QuizItem {
        var question: String
        var answers: [String]? //if array is empty then correctAnswer is fill in the blank
        var correctAnswer: String
//        var questionType: QuestionType
    }
    
    //progress for each lesson
    struct Progress {
        let topicTitle: String
        var lessonRead = false
        var vocabStudied = false
        var quizPassed = false
        var quizHighScore: Int?
    }
}

extension Language.Progress: Identifiable {
    var id: String {topicTitle}
}

private func key(for title: String, type: String) -> String {
    "\(title).\(type)"
}

struct ChineseLessonPlan: LessonPlan {
    // MARK: -  Properties
    let languageName = "Chinese"
    let topics = Data.chineseTopics
    
    var progress: [Language.Progress] = ChineseLessonPlan.readProgressRecords()
    
    // MARK: - Helpers
    mutating func toggleLessonRead(for title: String) {
        if let index = progress.firstIndex(where: {$0.topicTitle == title}) {
            progress[index].lessonRead.toggle()
            UserDefaults.standard
                .set(
                    progress[index].lessonRead,
                    forKey: key(for: title, type: Key.lessonRead)
                )
        } else {
            progress.append(Language.Progress(topicTitle: title))
            toggleLessonRead(for: title)
        }
    }
    //helpers to update progress
    
    private static func readProgressRecords() -> [Language.Progress] {
        var progressRecords = [Language.Progress]()
        
        Data.chineseTopics.forEach { topic in
            var progressRecord = Language.Progress(topicTitle: topic.title)
            
            progressRecord.lessonRead = UserDefaults.standard.bool(forKey: key(for: topic.title, type: Key.lessonRead))
            
            //implement this for the other three progress items
            progressRecords.append(progressRecord)
        }
        return progressRecords
    }
    
    // MARK: - Constants
    private struct Key {
        static let lessonRead = "lessonRead"
        static let vocabStudied = "vocabStudied"
        static let quizPassed = "quizPassed"
        static let highScore = "highScore"
    }
    
    private struct Data {
        static let chineseTopics = [
            Language.Topic (
                title: "Basic Greetings",
                lesonText: """
                    This is a test
                """,
                vocabulary: [
                    Language.Term(targetWord: "你好", translation: "Hello")
                ],
                quiz: [
                    Language.QuizItem(
                        question: "How would you say 'Hello'?",
                        answers: ["Hello", "你好"],
                        correctAnswer: "你好")
                ]),
        ]
    }
}
