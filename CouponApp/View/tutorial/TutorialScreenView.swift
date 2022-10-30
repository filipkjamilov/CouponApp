//  Created by Filip Kjamilov on 30.10.22.

import SwiftUI

struct TutorialScreenView: View {
    
    @AppStorage(StorageKeys.currentPage.rawValue) var currentPage = 1
    
    var image: String
    var title: String
    var description: String
    var bgColor: Color
        
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                if currentPage == 1 {
                    // Show it on first page
                    Text("Hello Member!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .kerning(1.4)
                } else {
                    // Back button
                    Button(action: { currentPage -= 1 }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
                
                Button(action: { currentPage = 4 }) {
                    Text("Skip")
                        .fontWeight(.semibold)
                        .kerning(1.2)
                }
                
            }
            .foregroundColor(.black)
            .padding()
            
            Spacer(minLength: 0)
            
            Image(image)
                .resizable()
                .scaledToFit()
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top)
            
            Text(description)
                .fontWeight(.semibold)
                .kerning(1.3)
                .multilineTextAlignment(.center)
            
            Spacer(minLength: 120)
        }
        .background(bgColor.cornerRadius(10).ignoresSafeArea())
    }
}

struct TutorialScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TutorialScreenView(image: "rebuy", title: "Title", description: "Description", bgColor: .purple)
        }
    }
}
