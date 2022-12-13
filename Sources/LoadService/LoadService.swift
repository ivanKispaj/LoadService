//
//  LoadService.swift
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
    var method: VKApiMethods
    //MARK: - Init
    
    public init(userId: String, method: VKApiMethods) {
        self.token =  method.associatedType()
        self.userId = userId
        self.method = method
    }
    
    public func loadFromInternet<T: Decodable>(object: T.Type,completion: @escaping (T) -> Void) async  {
        
        await LoadFromInternet().load(for: T.self, apiMethod: self.method)
            .sink(receiveCompletion: { (completion) in
                if case let .failure(error) = completion {
                    print(error)
                }
            }, receiveValue: { friend in
                
                completion(friend)
            })
            .store(in: &self.subscriber) 
    }
}
