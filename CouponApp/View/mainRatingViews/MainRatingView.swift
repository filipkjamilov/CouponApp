//  Created by Filip Kjamilov on 30.10.22.

import SwiftUI

struct MainRatingView: View {
    
    @StateObject var viewModel = MainRatingViewModel(remoteRepo: RemoteRepository())
    @State var showStatistics = false
    
    var body: some View {
        VStack {
            
            // Top navigation
            Button(action: {
                showStatistics.toggle()
            }) {
                Image(systemName: "chart.bar.xaxis")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                Text("Rate me!")
                    .font(.title.bold())
                    .foregroundColor(.primary)
            )
            .foregroundColor(.black)
            .padding()
            
            // Content Stack
            ZStack {
                
                if viewModel.showPromoCode {
                    
                    CouponView(viewModel: viewModel)
                    
                } else {
                    // Loading idicator for slow internet connection.
                    if viewModel.displayingContent.isEmpty && !viewModel.endReached {
                        VStack {
                            Text("The data is loading...")
                                .font(.title)
                            ProgressView()
                        }
                    }
                    
                    ForEach(viewModel.displayingContent.reversed(), id: \.id) { content in
                        StackCardView(content: content)
                            .environmentObject(viewModel)
                    }
                }
                
            }
            .padding()
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showStatistics) {
                StatisticsView(viewModel: viewModel)
            }
            
            // Actions
            VStack {
                
                ProgressView("", value: Double(viewModel.ratedContent.count), total: 30)
                    .frame(width: 300)
                
                Text("Take your time while rating!")
                    .foregroundColor(viewModel.hasTimeElapsed ? Color.clear : Color.primary)
                    .font(.caption2)
                
                HStack(spacing: 15) {
                    Button(action: {
                        doSwipe()
                    }) {
                        Image(systemName: "suit.heart.fill")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(18)
                            .background(.pink.opacity(0.8))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        skip()
                    }) {
                        Image(systemName: "arrowshape.bounce.right")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(13)
                            .background(.yellow.opacity(0.8))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        doSwipe(rightSwipe: true)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(18)
                            .background(.cyan.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom)
                .disabled(viewModel.isContentEmpty || viewModel.showPromoCode || !viewModel.hasTimeElapsed)
                .opacity((viewModel.isContentEmpty || viewModel.showPromoCode || !viewModel.hasTimeElapsed) ? 0.6 : 1)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    func skip() {
        guard let skipped = viewModel.displayingContent.first else { return }
        DispatchQueue.main.async {
            // Remove item from array
            viewModel.removeDisplayingContent(skipped)
            // Append item to back
            viewModel.appendDisplayingContent(skipped)
        }
    }
    
    func doSwipe(rightSwipe: Bool = false) {
        guard let firstContent = viewModel.displayingContent.first else { return }
        
        NotificationCenter.default.post(name: NSNotification.Name("DOSWIPE"), object: nil, userInfo: [
            "id": firstContent.id,
            "rightSwipe": rightSwipe
        ])
        
    }
}

struct MainRatingView_Previews: PreviewProvider {
    static var previews: some View {
        MainRatingView()
    }
}
