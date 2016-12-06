//
//  Tweets.swift
//  TweetsCounter
//
//  Created by Patrick Balestra on 12/1/15.
//  Copyright © 2015 Patrick Balestra. All rights reserved.
//

import UIKit
import TwitterKit
import AlamofireImage

enum TwitterError: Error {
    case notAuthenticated
    case unknown
    case invalidResponse
    case rateLimitExceeded
    case failedAnalysis
}

final class TwitterSession {

    typealias TimelineUpdate = (Timeline?, TwitterError?) -> Void
    
    private var client: TWTRAPIClient?
    private var timelineParser = TimelineParser()
    private var timelineUpdate: TimelineUpdate?
    private var timelineRequestsCount = 0

    init() {
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            client = TWTRAPIClient(userID: userID)
        }
    }
    
    ///  Check the session user ID to see if there is an user logged in.
    func isUserLoggedIn() -> Bool {
        return client != nil
    }

    func getProfilePicture(completion: @escaping (URL?) -> ()) {
        guard let client = client, let userID = client.userID else { return completion(nil) }
        client.loadUser(withID: userID) { user, error in
            if let stringURL = user?.profileImageLargeURL {
                return completion(URL(string: stringURL)!)
            }
        }
    }

    func getTimeline(before maxID: String?, completion: @escaping TimelineUpdate) {
        timelineUpdate = completion
        guard let client = client else { return completion(nil, .notAuthenticated) }
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        var parameters = ["count" : String(describing: 200), "include_entities" : "false", "exclude_replies" : "false"]
        if let maxID = maxID {
            parameters["max_id"] = maxID
        }

        let request = client.urlRequest(withMethod: "GET", url: url, parameters: parameters, error: nil)
        client.sendTwitterRequest(request) { response, data, error in
            if let error = error as? NSError {
                switch error.code {
                case 88: return completion(nil, .rateLimitExceeded)
                default: return completion(nil, .invalidResponse)
                }
            }
            guard let data = data else { return completion(nil, .invalidResponse) }
            do {
                let tweets: Any = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let timeline = tweets as? JSONArray else { return completion(nil, .invalidResponse) }

                self.timelineParser.parse(timeline)
//                self.timelineParser.analyze(timeline)
                

                self.timelineRequestsCount += 1
                if let update = self.timelineUpdate {
                    update(self.timelineParser.timeline, nil)
                    if self.timelineRequestsCount >= 4 {
                        return
                    }
                    self.getTimeline(before: self.timelineParser.timeline.maxID, completion: update)
                }
            } catch {
                return completion(nil, .invalidResponse)
            }
        }
    }
}
