//
//  LessonView.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/24/24.
//

import SwiftUI

struct LessonView: View {
    var Topic: Language.Topic
    var languageViewModel: LanguageViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(Topic.title)
                    .font(.largeTitle)
                Text(Topic.lesonText)
                    .font(.subheadline)
                
                Spacer()
                
                Text("Vocabulary Words")
                    .font(.headline)
                List(Topic.vocabulary) { term in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(term.targetWord)
                                .font(.headline)
                            Text("(\(term.pinyin))")
                        }
                        
                        Text(term.translation)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(10)
                    .background(.green.opacity(0.3))
                    .cornerRadius(10)
                }
                
                NavigationLink(destination: FlashcardView(languageViewModel: languageViewModel)) {
                    Text("Review Flashcards")
                        .foregroundStyle(.white)
                }.frame(maxWidth: .infinity)
                    .padding(10)
                    .background(.green)
                    .cornerRadius(10)
                    .simultaneousGesture(TapGesture().onEnded {
                        languageViewModel.createFlashCardDeck(Topic.vocabulary)
                    })
                Button {
                    
                } label: {
                    Text("Take Quiz")
                        .foregroundStyle(.white)
                }.frame(maxWidth: .infinity)
                    .padding(10)
                    .background(.green)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

#Preview {
    LessonView(Topic: LanguageViewModel().topics[0], languageViewModel: LanguageViewModel())
}
