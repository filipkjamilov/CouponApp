//  Created by Filip Kjamilov on 30.10.22.

import SwiftUI

public struct CardGradient: View {
    public var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            LinearGradient(colors: [Color.purple.opacity(0.3), Color.cyan.opacity(0.7)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            
        }.ignoresSafeArea(.all)
    }
}
