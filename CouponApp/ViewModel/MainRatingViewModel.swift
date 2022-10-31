//  Created by Filip Kjamilov on 30.10.22.

import Foundation
import SwiftUI
import Combine

typealias ImageData = Data

public class MainRatingViewModel: ObservableObject {
    
    var remoteRepo: RemoteRepository
    
    @Published private(set) var displayingContent: [Content] = []
    @Published private(set) var ratedContent: [Content] = []
    
    @AppStorage(StorageKeys.showPromoCode.rawValue) var showPromoCode = false
    @AppStorage(StorageKeys.freshStart.rawValue) var freshStart = true
    @AppStorage(StorageKeys.coupon.rawValue) var coupon = ""
    @AppStorage(StorageKeys.endReached.rawValue) var endReached = false
    @AppStorage(StorageKeys.hasTimeElapsed.rawValue) var hasTimeElapsed = true
    
    // MARK: - CP
    
    var numRated: Int { remoteRepo.ratedContent.count }
    var numLiked: Int { remoteRepo.ratedContent.filter({$0.rating == .liked}).count }
    var numDislike: Int { remoteRepo.ratedContent.filter({$0.rating == .disliked}).count }
    var numDisplayed: Int { remoteRepo.displayingContent.count }
    var isContentEmpty: Bool { remoteRepo.displayingContent.isEmpty }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(remoteRepo: RemoteRepository) {
        self.remoteRepo = remoteRepo
        
        remoteRepo.$displayingContent.sink { [weak self] newValue in
            self?.displayingContent = newValue
        }.store(in: &cancellables)
        
        remoteRepo.$ratedContent.sink { [weak self] newValue in
            self?.ratedContent = newValue
        }.store(in: &cancellables)
        
        if freshStart {
            remoteRepo.fetchContent()
            freshStart = false
        }
    }
    
    func fetchContent() {
        remoteRepo.fetchContent()
    }
    
    func rightSwipe(content: Content) {
        delayUser()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Remove items from array
            var contentToAppend = content
            contentToAppend.rating = .disliked
            self.saveRated(content: contentToAppend)
            if !(self.displayingContent.isEmpty) {
                self.removeDisplayingContent(content)
            }
            if self.numDisplayed == 4 {
                self.remoteRepo.start = self.remoteRepo.start + self.remoteRepo.limit
                self.fetchContent()
            }
        }
    }
    
    func leftSwipe(content: Content) {
        delayUser()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Remove items from array
            var contentToAppend = content
            contentToAppend.rating = .liked
            self.saveRated(content: contentToAppend)
            if !(self.displayingContent.isEmpty) {
                self.removeDisplayingContent(content)
            }
            if self.numDisplayed == 4 {
                self.remoteRepo.start = self.remoteRepo.start + self.remoteRepo.limit
                self.fetchContent()
            }
        }
    }
    
    func saveRated(content: Content) {
        // Change this
        var rated = content
        rated.downloadedImage = Data()
        remoteRepo.appendRated(rated)
        if remoteRepo.ratedContent.count >= 30 {
            showPromoCode = true
            retreiveCoupon()
        }
    }
    
    func appReset() {
        // Reset properties
        remoteRepo.resetData()
        showPromoCode = false
        
        // Fetch data
        remoteRepo.fetchContent()
    }
    
    func retreiveCoupon() {
        // TODO: FKJ - API call that will send the `ratedContent` to backend and receive the coupon for the user.
        coupon = "111-222-333"
    }
    
    func delayUser() {
        self.hasTimeElapsed = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.hasTimeElapsed = true
        }
    }
    
    func appendDisplayingContent(_ content: Content) {
        remoteRepo.appendDisplaying(content)
    }
    
    func appendRatedContent(_ content: Content) {
        remoteRepo.appendRated(content)
    }
    
    func removeDisplayingContent(_ content: Content) {
        remoteRepo.removeDisplaying(content)
    }
    
    func removeRatedContent(_ content: Content) {
        remoteRepo.removeRated(content)
    }
    
    func getIndexFromDisplaying(_ content: Content) -> Int {
        return remoteRepo.getIndexFromDisplaying(content)
    }
    
    func getIndexFromRated(_ content: Content) -> Int {
        return remoteRepo.getIndexFromRated(content)
    }
    
}
