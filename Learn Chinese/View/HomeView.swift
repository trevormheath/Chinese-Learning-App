//
//  HomeView.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/17/24.
//

import SwiftUI

struct HomeView: View {
    var languageViewModel: LanguageViewModel
    
    var body: some View {
        NavigationStack {
            List(languageViewModel.topics) { topic in
                VStack(alignment: .leading) {
                    HStack {
                        Text(topic.title)
                            .font(.headline)
                        
                        Spacer()
                        
                        //get lesson progress
                        let lessonRead = languageViewModel.progress(for: topic.title).lessonRead
                        let vocabStudied = languageViewModel.progress(for: topic.title).vocabStudied
                        let quizPassed = languageViewModel.progress(for: topic.title).quizPassed
                        
                        if (lessonRead && vocabStudied && quizPassed) {
                            Text("Complete")
                        } else if (!lessonRead && !vocabStudied && !quizPassed) {
                            Text("Not Started")
                        } else {
                            let countComplete = (lessonRead ? 1 : 0) + (vocabStudied ? 1 : 0) + (quizPassed ? 1 : 0)
                            Text("In Progress (\(countComplete)/3)")
                        }
                    }
                    NavigationLink(destination: LessonView(Topic: topic, languageViewModel: languageViewModel)) {
                            Text("Go to lesson")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(Constants.smallPadding)
                .background(.softGreen)
                .cornerRadius(Constants.cornerRadius)
            }
            .listStyle(.plain)
            .navigationTitle("Learn \(languageViewModel.languageName)")
        }
    }
    
    private struct Constants {
        static let smallPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 10
    }
}

#Preview {
    HomeView(languageViewModel: LanguageViewModel())
}
