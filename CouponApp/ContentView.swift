//  Created by Filip Kjamilov on 30.10.22.

import SwiftUI

struct ContentView: View {
    
    @AppStorage(StorageKeys.currentPage.rawValue) var currentPage = 1
    var totalPages = 3
    
    var body: some View {
        ZStack {
            TutorialWalkthrough(totalPages: totalPages)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
