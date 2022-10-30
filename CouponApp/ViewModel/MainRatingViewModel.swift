//  Created by Filip Kjamilov on 30.10.22.

import Foundation
import FirebaseDatabase
import FirebaseStorage
import SwiftUI
import Combine

public class MainRatingViewModel: ObservableObject {
    
    @Published(key: StorageKeys.displayingContent.rawValue) var displayingContent: [Content] = []
    @Published(key: StorageKeys.ratedContent.rawValue) var ratedContent: [Content] = []
    
    @AppStorage(StorageKeys.showPromoCode.rawValue) var showPromoCode = false
    @AppStorage(StorageKeys.endReached.rawValue) var endReached = false
    @AppStorage(StorageKeys.freshStart.rawValue) var freshStart = true
    @AppStorage(StorageKeys.coupon.rawValue) var coupon = 0
    @AppStorage(StorageKeys.start.rawValue) var start = 1
    @AppStorage(StorageKeys.limit.rawValue) var limit = 5
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - CP
    
    var numRated: Int { ratedContent.count }
    var numLiked: Int { ratedContent.filter({$0.rating == .liked}).count }
    var numDislike: Int { ratedContent.filter({$0.rating == .disliked}).count }
    var numDisplayed: Int { displayingContent.count }
    var isContentEmpty: Bool { displayingContent.isEmpty }
    var storageReference: StorageReference { Storage.storage().reference() }
    var databaseReference: DatabaseReference { Database.database().reference() }
    
    init() {
        if freshStart {
            fetchData()
            freshStart = false
        }
    }
    
    func fetchData() {
        
        let database = databaseReference
            .child("content")
            .queryOrdered(byChild: "id")
            .queryStarting(atValue: start)
            .queryLimited(toFirst: UInt(limit))
        
        print("Fetching started from: ", start)
        database.observeSingleEvent(of: .value) { snapshot in

            if snapshot.childrenCount < self.limit { self.endReached = true }
            
            guard let snapshot = snapshot.value as? [String: Any] else { return }

            snapshot.forEach { content in
                let card = content.value as? [String: Any]
                
                // TODO: FKJ - Try to parse it as Content directly!
                let id = card?["id"] as? Int ?? 0
                let name = card?["name"] as? String ?? ""
                let imageURL = card?["imageURL"] as? String ?? ""
                let imageName = card?["imageName"] as? String ?? ""
                
                print("Content Name: ", id)
                // Fetch the image from Storage.
                // Do not add `Content` if image is not retreived from Storage!
                
                // TODO: FKJ - Try having this in other function!
                self.storageReference.child("content/\(imageName)").downloadURL(completion: { url, error in
                    guard let url = url, error == nil else { return }
                    guard let imageLink = URL(string: url.absoluteString) else { return }
                    
                    URLSession.shared.dataTask(with: imageLink, completionHandler: { data, _, error in
                        guard let data = data, error == nil else { return }
                        
                        DispatchQueue.main.async {
                            // Append content to array!
                            self.displayingContent.append(Content(id: id,
                                                                  name: name,
                                                                  imageURL: imageURL,
                                                                  downloadedImage: data))
                        }
                        
                    }).resume()
                })
            }
        }
    }
    
    func getIndex(for content: Content) -> Int {
        return displayingContent.firstIndex(where: { return content.id == $0.id }) ?? 0
    }

    func saveRated(content: Content) {
        // TODO: FKJ - Workaround to not save the image in UserDefaults.
        var rated = content
        rated.downloadedImage = Data()
        ratedContent.append(rated)
        if ratedContent.count >= 30 {
            showPromoCode = true
            retreiveCoupon()
        }
    }
    
    func appReset() {
        // Reset properties
        UserDefaults.standard.reset()
        displayingContent = []
        ratedContent = []
        showPromoCode = false
        endReached = false
        // Fetch data
        fetchData()
    }
    
    func retreiveCoupon() {
        // TODO: FKJ - API call that will send the `ratedContent` to backend and receive the coupon for the user.
        coupon = Int.random(in: 379129832713..<99999999999999)
    }
    
}
