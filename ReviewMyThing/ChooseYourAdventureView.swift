//
//  ChooseYourAdventureView.swift
//  ReviewMyThing
//
//  Created by Kent Karlsson on 2024-11-23.
//

import SwiftUI

class  ChooseYourAdventureViewModel: ObservableObject {
    @Published var jpegData: Data?
    @Published var chosenAdventure: ChosenAdventure?
    @Published var nextAction: NextAction?
}

enum ChosenAdventure {
    case RateMyThingie
    case AreYouThere
}

enum NextAction {
    case ReviewPhoto
    case GetHelloText
}

struct ChooseYourAdventureView: View {
    @State var adventureModel = ChooseYourAdventureViewModel()
    @State private var isShowingCamera: Bool = false
    @State private var isTalkingToAI: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Choose your adventure")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Button(action: {
                    adventureModel.chosenAdventure = .RateMyThingie
                    adventureModel.nextAction = .ReviewPhoto
                    isShowingCamera = true
                }) {
                    Text("Rate my thingie")
                        .fontWeight(.bold)
                        .padding()
                }
                
                Button(action: {
                    adventureModel.chosenAdventure = .AreYouThere
                    adventureModel.nextAction = .GetHelloText
                    isTalkingToAI = true
                }) {
                    Text("Are you there?")
                        .fontWeight(.bold)
                        .padding()
                }
            }
            .navigationTitle("Adventure")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
            .sheet(isPresented: $isShowingCamera) {
                CameraView(isPresented: $isShowingCamera, jpegData: $adventureModel.jpegData)
                    .onDisappear {
                        guard adventureModel.jpegData != nil else { return }
                        isTalkingToAI = true
                    }
            }
            .sheet(isPresented: $isTalkingToAI) {
                AIView(isPresented: $isTalkingToAI, adventure: $adventureModel)
            }
        }
    }
}

//#Preview {
//    ChooseYourAdventureView()
//}
