//
//  DBRealm.swift
//  
//
//  Created by Ivan Konishchev on 13.12.2022.
//

import Foundation
import Combine
import Realm
import RealmSwift

@available(iOS 13.0, *)
final class DBRealm {

    private(set) var verifyConnection = ConnectionDB()
    private(set) var subscriber: Set<AnyCancellable> = Set<AnyCancellable>()
    lazy var decoder = JSONDecoder()
    
    @MainActor
    func load<T: Decodable>(for objectType: T.Type, apiMethod: VKApiMethods) async -> Future<T, ServiceError> where T : Decodable {
        return Future<T, ServiceError> { [unowned self] promise in
            guard let object = T.self as? RealmSwiftObject.Type else {
                return promise( .failure(.notRealmSwiftObject))
            }
            guard self.verifyConnection.isConnected() else {
                return promise( .failure(.DBConnectionFailure))
            }
            let realm = try! Realm()
            realm.objects(object).collectionPublisher
                .receive(on: RunLoop.main)
                .threadSafeReference()
                .sink(receiveCompletion: { result in
                    if case let .failure(error) = result {
                        print(error)
                        promise(. failure(.DBConnectionFailure))
                    }
                }, receiveValue: { realm in
                    if let result = realm.first as? T {
                        promise(.success(result))
                    }
                })
                .store(in: &self.subscriber)
        }
    }
    @MainActor
    func updateData(object: Object) {
        guard self.verifyConnection.isConnected() else {
            return
        }
        
        do {
            let realm = try  Realm()
            realm.writeAsync {
                realm.add(object, update: .modified)
            }
        } catch {
            print("Error update DB")
        }
        
    }
    @MainActor
    func updateData(object: [Object]) {
        do {
            let realm = try  Realm()
            realm.writeAsync {
                realm.add(object, update: .modified)
            }
        }catch {
                print("Error update DB")
        }
    }
    
    
    func deleteData(object: Object, cascading: Bool) {
        do {
            let realm = try  Realm()
            realm.writeAsync{
                realm.delete(object, cascading: true)
            }
        }catch {
            print("Error delite DB")
        }
    }
    
    func saveData(object: Object) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(object)
            try realm.commitWrite()
        }catch {
           print("Error save DB")
        }
    }
    func printConfiguration() {
        do {
            let realm = try Realm()
            print(realm.configuration.fileURL!)
        }catch {
            print("error print configuration")
        }
    }
    
}


final class ConnectionDB {
    
    func isConnected() -> Bool {
        do {
            _  = try Realm()
            return true
        } catch {
            return false
        }
    }
    

}

//MARK: - Extension Realm Cascade Delite Objects
protocol CascadeDeleting {
    func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object
    func delete<Entity: Object>(_ entity: Entity, cascading: Bool)
}

extension Realm: CascadeDeleting {
    func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object {
        for obj in objects {
            delete(obj, cascading: cascading)
        }
    }
    
    func delete<Entity: Object>(_ entity: Entity, cascading: Bool) {
        if cascading {
            cascadeDelete(entity)
        } else {
            delete(entity)
        }
    }
}


//MARK: - каскадное удаление объектов в базе данных
private extension Realm {
    private func cascadeDelete(_ entity: RLMObjectBase) {
        guard let entity = entity as? Object else { return }
        var toBeDeleted = Set<RLMObjectBase>()
        toBeDeleted.insert(entity)
        while !toBeDeleted.isEmpty {
            guard let element = toBeDeleted.removeFirst() as? Object,
                  !element.isInvalidated else { continue }
            resolve(element: element, toBeDeleted: &toBeDeleted)
        }
    }
    
    private func resolve(element: Object, toBeDeleted: inout Set<RLMObjectBase>) {
        element.objectSchema.properties.forEach {
            guard let value = element.value(forKey: $0.name) else { return }
            if let entity = value as? RLMObjectBase {
                toBeDeleted.insert(entity)
            } else if let list = value as? RLMSwiftCollectionBase {
                for index in 0..<list._rlmCollection.count {
                    if let entity = list._rlmCollection.object(at: index) as? RLMObjectBase {
                        toBeDeleted.insert(entity)
                    }
                }
            }
        }
        
        delete(element)
    }
}
