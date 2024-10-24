//
//  LanguageViewModel.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/24/24.
//

import Foundation

@Observable class LanguageViewModel {
    // MARK: - Properties
    private var lessonPlan: LessonPlan = ChineseLessonPlan()
    
    // MARK: - Model access
    var languageName: String {
        lessonPlan.languageName
    }
    
    var topics: [Language.Topic] {
        lessonPlan.topics
    }
    
    func progress(for title: String) -> Language.Progress {
        if let progressRecord = lessonPlan.progress.first(where: { $0.topicTitle == title}) {
            return progressRecord
        }
        
        let progressRecord = Language.Progress(topicTitle: title)
        lessonPlan.progress.append(progressRecord)
        return progressRecord
    }
    
    // MARK: - User intents
    func toggleLessonRead(for title: String) {
        lessonPlan.toggleLessonRead(for: title)
    }
    
    // MARK: - Private helpers
}
