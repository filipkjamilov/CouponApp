//  Created by Filip Kjamilov on 30.10.22.

import SwiftUI

struct TutorialWalkthrough: View {
    
    @AppStorage(StorageKeys.currentPage.rawValue) var currentPage = 1
    var totalPages: Int
    
    var body: some View {
        ZStack {
            
            if currentPage == 1 {
                TutorialScreenView(image: "tutorial_page_1",
                                   title: "You love the content?",
                                   description: "Swipe left or use the heart button to rate the content!",
                                   bgColor: .cyan)
            }
            
            if currentPage == 2 {
                TutorialScreenView(image: "tutorial_page_2",
                                   title: "You don't like?",
                                   description: "Swipe right or use the X mark button to rate the content!",
                                   bgColor: .pink)
            }
            
            if currentPage == 3 {
                TutorialScreenView(image: "tutorial_page_3",
                                   title: "Skip & Statistics",
                                   description: "For skipping the content press the middle button, and for statistics press the top left button.",
                                   bgColor: .purple)
            }
            
        }
        .overlay(alignment: .bottom) {
            
            Button(action: { currentPage += 1 } ){
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay {
                        ZStack {
                            Circle()
                                .stroke(Color.black.opacity(0.04), lineWidth: 4)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(currentPage) / CGFloat(totalPages))
                                .stroke(Color.white, lineWidth: 4)
                                .rotationEffect(.init(degrees: -90))
                        }.padding(-10)
                    }
            }
            .padding(.bottom, 15)
        }
    }
}

struct TutorialScreen_Previews: PreviewProvider {
    static var previews: some View {
        TutorialWalkthrough(totalPages: 3)
    }
}
