//
//  MainListViewModel.swift
//  DaliyTimeLine
//
//  Created by Chung Wussup on 2/5/24.
//

import Foundation
import Firebase
import RxSwift
import RxRelay
import Differentiator

enum PostSection: CaseIterable {
    case dailyPost
}

class MainListViewModel {
    var mainPost = PublishSubject<[Post]>()
    var dailyPost = PublishSubject<[Post]>()
//    var dailyPostCount = PublishSubject<Int>()
    
    var postUpdate = PublishSubject<Bool>()
    
    var service: PostService
    var disposeBag = DisposeBag()
    
    
    init(service: PostService) {
        self.service = service
        rxGetAllPost()
        
    }
    
    func rxGetAllPost() {
        service.getAllPosts {[weak self] posts in
            self?.mainPost.onNext(posts)
        }
    }
    
    func rxGetPost(date: Date) {
        service.rxGetPost(date: date)
            .subscribe {[weak self] post in
                if let posts = post.element {
                    self?.dailyPost.onNext(posts)
                }
            }
            .disposed(by: disposeBag)
        
        service.getPost(date: date) { [weak self] post in
            self?.dailyPost.onNext(post)
//            self?.dailyPostCount.onNext(post.count)
        }
    }
    
    func postUpdate(documentID: String, caption: String) {
        
        dailyPost.subscribe(onNext: { [weak self] posts in
              if let updateIndex = posts.firstIndex(where: { $0.documentId == documentID }) {
                  var updatedPosts = posts
                  updatedPosts[updateIndex].caption = caption
                  self?.dailyPost.onNext(updatedPosts)
              }
          }).disposed(by: disposeBag)
    }
    
    func rxGetPostImg(date: Date) -> Observable<URL?> {
        return service.rxGetAllPosts()
            .map { [weak self] posts in
                let filteredPosts = self?.filterFirstPostForUniqueTimestamps(posts: posts)
                let post = filteredPosts?.first { post in
                    let postDateComponents = self?.dateComponets(date: post.timestamp.dateValue())
                    let dateComponents = self?.dateComponets(date: date)
                    return dateComponents == postDateComponents
                }
                
                return URL(string: post?.imageUrl ?? "")
            }
    }
    
    func filterFirstPostForUniqueTimestamps(posts: [Post]) -> [Post] {
        // timestamp를 기준으로 중복 제거
        let uniqueTimestamps = Set(posts.map { $0.timestamp })
        
        var filteredPosts: [Post] = []
        
        // 중복 제거된 timestamp에 대해 첫 번째 Post를 찾아서 추가
        for timestamp in uniqueTimestamps {
            if let firstPost = posts.first(where: { $0.timestamp == timestamp }) {
                filteredPosts.append(firstPost)
            }
        }
        
        return filteredPosts
    }
    
    //년월일로 바꿔주는 메서드
    func dateComponets(date: Date) -> DateComponents {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        return dateComponents
    }
    
    
    let selectedDateSubject = BehaviorSubject<Date>(value: Date())

    // 선택된 날짜를 업데이트하는 메서드
    func updateSelectedDate(_ date: Date) {
        selectedDateSubject.onNext(date)
    }

    // 선택된 날짜를 확인하는 메서드
    func isCurrentSelected(_ date: Date) -> Observable<Bool> {
        return selectedDateSubject.map {[weak self] selectedDate in
            let selectDateComponent = self?.dateComponets(date: selectedDate)
            let nowDateComponent = self?.dateComponets(date: date)
            return selectDateComponent == nowDateComponent
        }
    }
    
}
