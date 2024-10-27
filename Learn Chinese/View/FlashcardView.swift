//
//  FlashcardView.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/25/24.
//

import SwiftUI

struct FlashcardView: View {
    var languageViewModel: LanguageViewModel
    
    @State private var counter = 0
    @State private var isNext: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var vocab: [Language.Term] {
        languageViewModel.currentFlashcards
    }
    var title: String {
        languageViewModel.currentTopic.title
    }
    
    var body: some View {
        if vocab.isEmpty {
            Text("No vocab in this lesson!")
        } else {
            VStack {
                if vocab[counter].isTargetUp {
                    HStack {
                        Text(vocab[counter].targetWord)
                            .font(.title)
                        Text("(\(vocab[counter].pinyin))")
                            .font(.title)
                    }
                } else {
                    Text(vocab[counter].translation)
                        .font(.title)
                }
            }
            .cardify(isFaceUp: vocab[counter].isTargetUp)
            .onTapGesture {
                languageViewModel.flip(vocab[counter])
            }
            .animation(.easeInOut(duration: Constants.animationDuration), value: vocab[counter].isTargetUp)
            .transition(counterChangeTransition())
            .id(counter)
            
            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        if counter > 0 {
                            isNext = false
                            counter -= 1
                        }
                    }
                } label: {
                    Text("Previous")
                }
                .padding(Constants.smallPadding)
                .background(.defaultButton)
                .cornerRadius(Constants.cornerRadius)
                .disabled(counter <= 0)
                
                Button {
                    withAnimation(.easeInOut) {
                        if counter < vocab.count - 1 {
                            isNext = true
                            counter += 1
                        } else {
                            if !languageViewModel.progress(for: title).vocabStudied {
                                languageViewModel.toggleFlashCardsComplete(for: title)
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    if counter < vocab.count - 1 {
                        Text("Next")
                    }
                    else {
                        Text("Finish")
                    }
                }
                .padding(Constants.smallPadding)
                .background(.defaultButton)
                .cornerRadius(Constants.cornerRadius)
            }
            .padding(Constants.largePadding)
        }
    }
    
    private func counterChangeTransition() -> AnyTransition {
        if (isNext) {
            return AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .scale)
        } else {
            return AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .scale)
        }
    }
    
    private struct Constants {
        static let smallPadding: CGFloat = 10
        static let largePadding: CGFloat = 50
        static let cornerRadius: CGFloat = 10
        static let animationDuration: TimeInterval = 0.5
    }
}

#Preview {
    FlashcardView(languageViewModel: LanguageViewModel())
}
