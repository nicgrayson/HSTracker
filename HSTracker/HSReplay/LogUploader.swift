//
//  LogUploader.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 12/08/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import CleanroomLogger
import Wrap
import Alamofire

class LogUploader {
    private static var inProgress: [UploaderItem] = []
    
    static func upload(logLines: [String], game: Game?, statistic: Statistic?,
                       completion: UploadResult -> ()) {
        guard let token = Settings.instance.hsReplayUploadToken else {
            Log.error?.message("Authorization token not set yet")
            completion(.failed(error: "Authorization token not set yet"))
            return
        }
        
        let log = logLines.joinWithSeparator("\n")
        let item = UploaderItem(hash: log.hash)
        if inProgress.contains(item) {
            inProgress.append(item)
            Log.info?.message("\(item.hash) already in progress. Waiting for it to complete...")
            completion(.failed(error:
                "\(item.hash) already in progress. Waiting for it to complete..."))
            return // what?
        }
        
        inProgress.append(item)
        Log.info?.message("Uploading \(item.hash)")
        
        do {
            let uploadMetaData = UploadMetaData.generate(logLines, game: game, statistic: statistic)
            let metaData: [String : AnyObject] = try Wrap(uploadMetaData)
            
            let headers = [
                "X-Api-Key": HSReplayAPI.apiKey,
                "Authorization": "Token \(token)"
            ]
            
            Alamofire.request(.POST, HSReplay.uploadRequestUrl,
                parameters: metaData, encoding: .JSON, headers: headers)
                .responseJSON { response in
                    if response.result.isSuccess {
                        if let json = response.result.value as? [String: AnyObject],
                            putUrl = json["put_url"] as? String,
                            uploadShortId = json["shortid"] as? String {
                            
                            if let data = log.dataUsingEncoding(NSUTF8StringEncoding) {
                                do {
                                    let gzip = try data.gzippedData()
                                    
                                    Alamofire.upload(.PUT, putUrl,
                                        headers: [
                                            "Content-Type": "text/plain",
                                            "Content-Encoding": "gzip"
                                        ], data: gzip)
                                } catch {
                                    Log.error?.message("can not gzip")
                                }
                            }
                            
                            if let statistic = statistic {
                                statistic.hsReplayId = uploadShortId
                                if let deck = statistic.deck {
                                    Decks.instance.update(deck)
                                }
                            }

                            let result = UploadResult.successful(replayId: uploadShortId)
                            
                            Log.info?.message("\(item.hash) upload done: Success")
                            inProgress = inProgress.filter({ $0.hash == item.hash })
                            
                            completion(result)
                            return
                        }
                    }
            }
        } catch {
            Log.error?.message("\(error)")
            completion(.failed(error: "\(error)"))
        }
    }
    
    struct UploaderItem: Equatable {
        let hash: Int
    }
}
func == (lhs: LogUploader.UploaderItem, rhs: LogUploader.UploaderItem) -> Bool {
    return lhs.hash == rhs.hash
}