//  Created by Filip Kjamilov on 30.10.22.

import SwiftUI

struct StackCardView: View {
    
    @EnvironmentObject var viewModel: MainRatingViewModel
    var content: Content
    
    @State var offset: CGFloat = 0
    @GestureState var isDragging: Bool = false
    @State var endSwipe: Bool = false
    
    @AppStorage(StorageKeys.start.rawValue) var start = 1
    @AppStorage(StorageKeys.limit.rawValue) var limit = 5
    
    var body: some View {
        GeometryReader { reader in
            let size = reader.size
            let index = CGFloat(viewModel.getIndexFromDisplaying(content))
            let topOffset = (index <= 2 ? index : 2) * 15
            
            ZStack {
                ZStack {
                    
                    CardGradient()
                    
                    VStack {
                        Text(content.name)
                            .font(.title2)
                        Image(uiImage: UIImage(data: content.downloadedImage) ?? UIImage(systemName: "x.square")!)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                            .shadow(color: Color.primary, radius: 10)
                            .padding(.trailing, 10)
                            .padding(.leading, 10)
                    }
                    
                }
                .frame(width: size.width - topOffset, height: size.height)
                .cornerRadius(15)
                .offset(y: -topOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
        }
        .offset(x: offset)
        .rotationEffect(.init(degrees: rotation(angle: 8)))
        .contentShape(Rectangle().trim(from: 0, to: endSwipe ? 0 : 1))
        .gesture(
            DragGesture()
                .updating($isDragging, body: { value, out, _ in
                    if viewModel.hasTimeElapsed {
                        out = true
                    }
                })
                .onChanged({ value in
                    if viewModel.hasTimeElapsed {
                        let translation = value.translation.width
                        offset = (isDragging ? translation : .zero)
                    }
                })
                .onEnded({ value in
                    if viewModel.hasTimeElapsed {
                        let width = UIScreen.main.bounds.width - 50
                        let translation = value.translation.width
                        let checkingStatus = (translation > 0 ? translation : -translation)
                        
                        withAnimation {
                            if checkingStatus > (width/2) {
                                // Remove content from screen
                                offset = (translation > 0 ? width : -width) * 2
                                endSwipe = true
                                endSwipeActions()
                                
                                if translation > 0 {
                                    rightSwipe()
                                } else {
                                    leftSwipe()
                                }
                            } else {
                                offset = .zero
                            }
                        }
                    }
                })
        )
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DOSWIPE"), object: nil)) { data in
            guard let info = data.userInfo else { return }
            
            let id = info["id"] as? Int ?? 0
            let rightSwipe = info["rightSwipe"] as? Bool ?? false
            let width = UIScreen.main.bounds.width - 50
            
            if content.id == id {
                withAnimation{
                    offset = (rightSwipe ? width : -width) * 2
                    endSwipeActions()
                    if rightSwipe {
                        self.rightSwipe()
                    } else {
                        leftSwipe()
                    }
                }
            }
        }
    }
    
    func rightSwipe() {
        viewModel.rightSwipe(content: content)
    }
    
    func leftSwipe() {
        viewModel.leftSwipe(content: content)
    }
    
    func rotation(angle: Double) -> Double {
        return (offset / (UIScreen.main.bounds.width - 50)) * angle
    }
    
    func endSwipeActions() {
        withAnimation(.none) { endSwipe = true }
    }
}
