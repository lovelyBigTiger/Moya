//
//  Moya+RxSwift.swift
//  Moya
//
//  Created by Andre Carvalho on 2015-06-05
//  Copyright (c) 2015 Ash Furrow. All rights reserved.
//

import Foundation
import RxSwift

/// Subclass of MoyaProvider that returns Observable instances when requests are made. Much better than using completion closures.
public class RxMoyaProvider<T where T: MoyaTarget>: MoyaProvider<T> {

    /// Initializes a reactive provider.
    override public init(endpointsClosure: MoyaEndpointsClosure = MoyaProvider.DefaultEndpointMapping(), endpointResolver: MoyaEndpointResolution = MoyaProvider.DefaultEnpointResolution(), stubResponses: Bool = false, stubBehavior: MoyaStubbedBehavior = MoyaProvider.DefaultStubBehavior, networkActivityClosure: Moya.NetworkActivityClosure? = nil) {
        super.init(endpointsClosure: endpointsClosure, endpointResolver: endpointResolver, stubResponses: stubResponses, networkActivityClosure: networkActivityClosure)
    }

    /// Designated request-making method.
    public func request(token: T) -> Observable<MoyaResponse> {
        let endpoint = self.endpoint(token)

        return AnonymousObservable { [weak self] observer in
            let cancellableToken = self?.request(token) { (data, statusCode, response, error) -> () in
                if let error = error {
                    if let statusCode = statusCode {
                        observer.on(.Error(NSError(domain: error.domain, code: statusCode, userInfo: error.userInfo)))
                    } else {
                        observer.on(.Error(error))
                    }
                } else {
                    if let data = data {
                        observer.on(.Next(RxBox(MoyaResponse(statusCode: statusCode!, data: data, response: response))))
                    }
                    observer.on(.Completed)
                }
            }
            
            return AnonymousDisposable {
                cancellableToken?.cancel()
            }
        }
    }
}
