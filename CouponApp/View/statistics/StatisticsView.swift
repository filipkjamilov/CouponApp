//  Created by Filip Kjamilov on 30.10.22.

import SwiftUI

public struct StatisticsView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var viewModel: MainRatingViewModel
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("Rating statistics")) {
                    Label("Total rated content", systemImage: "sum")
                        .badge(Text("\(viewModel.numRated)"))
                    
                    Label("Positive rating", systemImage: "heart")
                        .badge(Text("\(viewModel.numLiked)"))
                    
                    Label("Negative rating:", systemImage: "hand.thumbsdown")
                        .badge(Text("\(viewModel.numDislike)"))
                    
                    Label("Current loaded data", systemImage: "arrow.triangle.2.circlepath")
                        .badge(Text("\(viewModel.numDisplayed)"))
                }
                
                Section(header: Text("About the app"), footer: Text("For more info please reach out!")) {
                    Label("Developed by:", systemImage: "signature")
                        .badge("Filip Kjamilov")
                }
                
            }
            .navigationBarTitle("Details", displayMode: .large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(viewModel: MainRatingViewModel(remoteRepo: RemoteRepository()))
    }
}

