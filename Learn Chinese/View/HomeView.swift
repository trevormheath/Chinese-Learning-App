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
                    Text(topic.title)
                        .font(.headline)
                    NavigationLink(destination: LessonView(Topic: topic, languageViewModel: languageViewModel)) {
                        Button(action: {
                            languageViewModel.selectTopic(topic)
                            print("selected topic")
                        }) {
                            Text("Go to lesson")
                        }
                        
                    }
//                    Button {
//                        languageViewModel.toggleLessonRead(for: topic.title)
//                    } label: {
//                        Text("Lesson read: \(languageViewModel.progress(for: topic.title).lessonRead)")
//                            .font(.subheadline)
//                    }
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(.green.opacity(0.3))
                .cornerRadius(10)
            }
            .listStyle(.plain)
            .navigationTitle("Learn \(languageViewModel.languageName)")
        }
    }
}

#Preview {
    HomeView(languageViewModel: LanguageViewModel())
}
