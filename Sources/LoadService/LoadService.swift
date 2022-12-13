//
//  DBRealm.swift
//
//
//  Created by Ivan Konishchev on 13.12.2022.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public final class LoadService {
    var token: String
    var userId: String
    var subscriber: Set<AnyCancellable> = Set<AnyCancellable>()
    
    //MARK: - Init
    
   public init(token: String, userId: String) {
        self.token = token
        self.userId = userId
    }
    
    public func loadFromInternet<T: Decodable>(object: T.Type,completion: @escaping (T) -> Void) async  {
        
        await LoadFromInternet().load(for: T.self, apiMethod: .getCountFriends(token: token, userId: userId))
            .sink(receiveCompletion: { (completion) in
                          if case let .failure(error) = completion {
                              print(error)
                          }
                      }, receiveValue: { friend in
//                          DispatchQueue.main.async {
//                              self.database.updateData(object: friend.response)
//
//                          }
                          
//                          self.parseInterface.parse(from: friend.response) { frineds in
//                              self.setGroupedFriends(from: frineds)
//                          }
                      completion(friend)
                            })
            .store(in: &self.subscriber) 
    }
}
