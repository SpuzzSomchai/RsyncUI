//
//  Readwritefiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ReadWriteDictionary: NamesandPaths {
    // Function for reading data from persistent store
    func readNSDictionaryFromPersistentStore() -> [NSDictionary]? {
        var data: [NSDictionary]?
        let dictionary = NSDictionary(contentsOfFile: filename ?? "")
        if let items = dictionary?.object(forKey: SharedReference.shared.userconfigkey) as? NSArray {
            data = [NSDictionary]()
            for i in 0 ..< items.count {
                if let item = items[i] as? NSDictionary {
                    data?.append(item)
                }
            }
        }
        return data
    }

    // Function for write data to persistent store
    @discardableResult
    func writeNSDictionaryToPersistentStorage(array: [NSDictionary]) -> Bool {
        let dictionary = NSDictionary(object: array, forKey: SharedReference.shared.userconfigkey as NSCopying)
        let write = dictionary.write(toFile: filename ?? "", atomically: true)
        if write && SharedReference.shared.menuappisrunning {
            Notifications().showNotification("Sending reload message to menu app")
            DistributedNotificationCenter.default().postNotificationName(NSNotification.Name(SharedReference.shared.reloadstring), object: nil, deliverImmediately: true)
        }
        return write
    }

    override init(_ profile: String?) {
        super.init(profile)
    }
}
