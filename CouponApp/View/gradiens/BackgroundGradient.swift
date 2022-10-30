//  Created by Filip Kjamilov on 30.10.22.

import SwiftUI

public struct BackgroundGradient: View {
    public var body: some View {
        ZStack {
            LinearGradient(colors: [Color.cyan.opacity(0.7), Color.purple.opacity(0.3)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            
        }.ignoresSafeArea(.all)
    }
}
