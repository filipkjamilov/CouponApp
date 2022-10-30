//  Created by Filip Kjamilov on 30.10.22.

import SwiftUI

struct CouponView: View {
    
    @StateObject var viewModel: MainRatingViewModel
    @State var onFinish: Bool = false
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {

            VStack(spacing: 25) {
                Text("Hooray!")
                    .font(.largeTitle)

                Text("You earned a discount coupon!")
   
                ScratchView(onFinish: $onFinish) {
                    VStack {
                        Text("Discount Code!")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        Text("\(viewModel.coupon)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                } overlayView: {
                    Image("discount")
                        .resizable()
                        .scaledToFit()
                }
                
                Text("Scratch the image above to reveal the code!")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                Button(action: {
                    viewModel.appReset()
                }) {
                    Text("Start rating again!")
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background(.secondary)
                        .clipShape(Capsule())
                }
            
            }
            .shadow(color: Color(uiColor: UIColor.systemBackground),radius: 15)
            .padding(.vertical, 25)
            .padding(.horizontal, 30)
            .cornerRadius(25)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primary.opacity(0.35))
        .cornerRadius(30)

    }

}

struct CouponView_Previews: PreviewProvider {
    static var previews: some View {
        CouponView(viewModel: MainRatingViewModel())
    }
}
