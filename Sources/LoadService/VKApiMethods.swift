//
//  ApiMethods.swift
//  
//
//  Created by Ivan Konishchev on 13.12.2022.
//

import Foundation

//MARK: - API Methods To get an absolute URL!
public enum VKApiMethods {
   public typealias token = String
   public typealias userId = String
   public typealias count = String
   public typealias searchText = String
   public typealias videos = String

    case none
    case getNews (token: token)
    case getVideo (token: token, ovnerId: userId, videoAccess: videos) //videos = String(id) + "_" + String(videoId) + "_" + accessKey
    case getAllFriends (token: token, userId: userId)
    case getCountFriends (token: token, userId: userId, count: String = "20")
    case getPhotos (token: token, ownerId: userId)
    case getWall (token: token, ownerId: userId)
    case getGroups (token: token, userId: userId)
    case leaveGroup (token: token, groupId: userId)
    case searchGroups (token: token, queryText: searchText)
    case joinGroups (token: token, groupId: userId)
    case getUserInfo (token: token, userId: userId)

    private var scheme: String {
        "https"
    }
    private var baseURL: String {
        "api.vk.com"
    }
    private var versionApi: String {
        "5.131"
    }

   public var absoluteURL: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = baseURL
        urlComponents.path = self.path()

        switch self {
        case .getNews(let token):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "filters", value: "post, photo, video"),
                URLQueryItem(name: "count", value: "20"),
                URLQueryItem(name: "v", value: "5.131"),
            ]

        case .getVideo(let token, let userId, let videos):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "owner_id", value: userId),
                URLQueryItem(name: "videos", value: videos),
                URLQueryItem(name: "count", value: "1"),
                URLQueryItem(name: "v", value: "5.131")
            ]

        case .getAllFriends(let token, let userId):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "user_id", value: userId),
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "order", value: "hints"),
                URLQueryItem(name: "count", value: "" ),
                URLQueryItem(name: "fields", value: "photo_50, city, last_seen, online, status "),
                URLQueryItem(name: "v", value: "5.131")
            ]
        case .getCountFriends(let token, let userId, let count):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "user_id", value: userId),
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "order", value: "hints"),
                URLQueryItem(name: "count", value: count ),
                URLQueryItem(name: "fields", value: "photo_50, city, last_seen, online, status "),
                URLQueryItem(name: "v", value: "5.131")
            ]
        case .getPhotos(let token, let ownerId):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "owner_id", value: ownerId),
                URLQueryItem(name: "extended", value: "1"),
                URLQueryItem(name: "no_service_albums", value: "0"),
                URLQueryItem(name: "count", value: "10"),
                URLQueryItem(name: "photo_sizes", value: "1"),
                URLQueryItem(name: "v", value: "5.131"),
                URLQueryItem(name: "skip_hidden", value: "0")
            ]

        case .getWall(let token, let ownerId):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "owner_id", value: ownerId),
                URLQueryItem(name: "filter", value: "owner"),
                URLQueryItem(name: "v", value: "5.131")
            ]

        case .getGroups(let token, let userId):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "user_id", value: userId),
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "extended", value: "1"),
                URLQueryItem(name: "fields", value: "activity, city, description, links, site, status "),
                URLQueryItem(name: "v", value: "5.131")
            ]
        case .leaveGroup(let token, let groupId):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "group_id", value: groupId),
                URLQueryItem(name: "v", value: "5.131")
            ]
        case .searchGroups(let token, let queryText):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "q", value: queryText),
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "sort", value: "6"),
                URLQueryItem(name: "type", value: "group, page, event"),
                URLQueryItem(name: "v", value: "5.131"),
                URLQueryItem(name: "count", value: "1000")
            ]
        case .joinGroups(let token, let groupId):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "group_id", value: groupId),
                URLQueryItem(name: "not_sure", value: "1"),
                URLQueryItem(name: "v", value: "5.131")
            ]
        case .getUserInfo(let token, let userId):
            urlComponents.queryItems =
            [
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "group_id", value: userId),
                URLQueryItem(name: "fields", value: "photo_50,screen_name, about, status"),
                URLQueryItem(name: "v", value: "5.131")
            ]
        default:
            urlComponents.queryItems = []
        }
        return urlComponents.url
    }

    func path() -> String {
        switch self {
        case .none:
            return ""
        case .getNews(_):
            return "/method/newsfeed.get"
        case .getVideo(_,_,_):
            return "/method/video.get"
        case .getAllFriends(_,_), .getCountFriends(_,_,_):
            return "/method/friends.get"
        case .getPhotos(_,_):
            return  "/method/photos.getAll"
        case .getWall(_,_):
            return "/method/wall.get"
        case .getGroups(_,_):
            return "/method/groups.get"
        case .leaveGroup(_,_):
            return "/method/groups.leave"
        case .searchGroups(_,_):
            return "/method/groups.search"
        case .joinGroups(_,_):
            return "/method/groups.join"
        case .getUserInfo(_, _):
            return "/method/users.get"
        }
    }
 // Для получения значения из енума ->  возвращает userId либо ownerId
   public func associatedType() -> String {
        switch self {
        case .none:
            return ("")
        case .getNews(_):
            return ("")
        case .getVideo(_, let ovnerId, _ ):
            return (ovnerId)
        case .getAllFriends( _ , let userId):
            return (userId)
        case .getCountFriends(_, let userId, _):
            return (userId)
        case .getPhotos(_, let ownerId):
            return ( ownerId)
        case .getWall(_, let ownerId):
            return ( ownerId)
        case .getGroups(_ , let userId):
            return (userId)
        case .leaveGroup(_ , let groupId):
            return (groupId)
        case .searchGroups( _,  let queryText):
            return (queryText)
        case .joinGroups( _ , let groupId):
            return (groupId)
        case .getUserInfo(_, userId: let userId):
            return (userId)
        }
    }
}
