//
//  RxTwitter.swift
//  TweetsCounter
//
//  Created by Patrick Balestra on 12/20/15.
//  Copyright © 2015 Patrick Balestra. All rights reserved.
//

import Foundation
import TwitterKit
import RxSwift

extension Twitter {
    
    /// Load user information.
    ///
    /// - parameter userID:  ID of the user account to be fetched.
    /// - parameter client:  Client to which load the request.
    ///
    /// - returns: An Observable of the user.
    func rx_loadUserWithID(userID: String, client: TWTRAPIClient) -> Observable<TWTRUser> {
        return create { (observer: AnyObserver<TWTRUser>) -> Disposable in
            client.loadUserWithID(userID) { user, error in
                if let e = error {
                    observer.onError(e)
                } else {
                    observer.onNext(user!)
                    observer.onCompleted()
                }
            }
            return AnonymousDisposable { }
        }
    }
    
    /// Load a specific tweet.
    ///
    /// - parameter tweetID: ID of the tweet to be retrieved.
    /// - parameter client:  Client to which load the request.
    ///
    /// - returns: An Observable of the tweet.
    func rx_loadTweetWithID(tweetID: String, client: TWTRAPIClient) -> Observable<TWTRTweet> {
        return create { (observer: AnyObserver<TWTRTweet>) -> Disposable in
            client.loadTweetWithID(tweetID, completion: { tweet, error in
                if let e = error {
                    observer.onError(e)
                } else {
                    observer.onNext(tweet!)
                    observer.onCompleted()
                }
            })
            return AnonymousDisposable { }
        }
    }
    
    /// Load tweets for the given array of IDs.
    ///
    /// - parameter ids:    IDs of the tweets to be retrieved.
    /// - parameter client: Client to which load the request.
    ///
    /// - returns: An Observable of the array of tweets.
    func rx_loadTweetsWithIDs(ids: Array<String>, client: TWTRAPIClient) -> Observable<Array<AnyObject>> {
        return create { (observer: AnyObserver<Array<AnyObject>>) -> Disposable in
            client.loadTweetsWithIDs(ids, completion: { tweets, error in
                if let e = error {
                    observer.onError(e)
                } else {
                    observer.onNext(tweets!)
                    observer.onCompleted()
                }
            })
            return AnonymousDisposable { }
        }
    }
    
    /// Load the user timeline.
    ///
    /// - parameter count:  The number of tweets to retrieve contained in the timeline.
    /// - parameter client: Client to which load the request.
    ///
    /// - returns: An Observable of the Timeline.
    // TODO: Use zip and check rate limit of the twitter API to request as many tweets as possible
    func rx_loadTimeline(count: Int, client: TWTRAPIClient) -> Observable<AnyObject> {
        return create { (observer: AnyObserver<AnyObject>) -> Disposable in
            let params = ["count": "\(count)"]
            
            let request = client.URLRequestWithMethod("GET", URL: TwitterEndpoints().timelineURL, parameters: params, error: nil)
            client.sendTwitterRequest(request) { response, data, connectionError in
                if let e = connectionError {
                    // An error occured
                    print("Error: \(e)")
                    observer.onError(e)
                } else {
                    do {
                        let JSON: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                        print("Received \(JSON)")
                        // TODO: Should convert to Timeline object
                        observer.onNext(JSON)
                        observer.onCompleted()
                    } catch {
                        print(error)
                        observer.onError(error)
                    }
                }
            }
            return AnonymousDisposable { }
        }
    }
}