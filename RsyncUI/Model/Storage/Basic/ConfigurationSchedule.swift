//
//  ConfigurationSchedule.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

struct Log: Identifiable, Codable {
    var id = UUID()
    var dateExecuted: String?
    var resultExecuted: String?
    var date: Date {
        return dateExecuted?.en_us_date_from_string() ?? Date()
    }
}

struct ConfigurationSchedule: Identifiable, Codable {
    var id = UUID()
    var hiddenID: Int
    var offsiteserver: String?
    var dateStart: String
    var dateStop: String?
    var schedule: String
    var logrecords: [Log]?
    var profilename: String?

    // Used when reading JSON data from store
    // see in ReadScheduleJSON
    init(_ data: DecodeSchedule) {
        dateStart = data.dateStart ?? ""
        dateStop = data.dateStop
        hiddenID = data.hiddenID ?? -1
        offsiteserver = data.offsiteserver
        schedule = data.schedule ?? ""
        for i in 0 ..< (data.logrecords?.count ?? 0) {
            if i == 0 { logrecords = [Log]() }
            var log = Log()
            log.dateExecuted = data.logrecords?[i].dateExecuted
            log.resultExecuted = data.logrecords?[i].resultExecuted
            logrecords?.append(log)
        }
    }

    // Used when reading PLIST data from store (as part of converting to JSON)
    // And also when creating new records.
    init(dictionary: NSDictionary, log: NSArray?) {
        hiddenID = dictionary.object(forKey: DictionaryStrings.hiddenID.rawValue) as? Int ?? -1
        dateStart = dictionary.object(forKey: DictionaryStrings.dateStart.rawValue) as? String ?? ""
        schedule = dictionary.object(forKey: DictionaryStrings.schedule.rawValue) as? String ?? ""
        offsiteserver = dictionary.object(forKey: DictionaryStrings.offsiteserver.rawValue) as? String ?? ""
        if let date = dictionary.object(forKey: DictionaryStrings.dateStop.rawValue) as? String { dateStop = date }
        if let log = log {
            for i in 0 ..< log.count {
                if i == 0 { logrecords = [Log]() }
                var logrecord = Log()
                if let dict = log[i] as? NSDictionary {
                    logrecord.dateExecuted = dict.object(forKey: DictionaryStrings.dateExecuted.rawValue) as? String
                    logrecord.resultExecuted = dict.object(forKey: DictionaryStrings.resultExecuted.rawValue) as? String
                }
                logrecords?.append(logrecord)
            }
        }
    }
}

extension ConfigurationSchedule: Hashable, Equatable {
    static func == (lhs: ConfigurationSchedule, rhs: ConfigurationSchedule) -> Bool {
        return lhs.hiddenID == rhs.hiddenID &&
            lhs.dateStart == rhs.dateStart &&
            lhs.schedule == rhs.schedule &&
            lhs.dateStop == rhs.dateStop &&
            lhs.offsiteserver == rhs.offsiteserver
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(hiddenID))
        hasher.combine(dateStart)
        hasher.combine(schedule)
        hasher.combine(dateStop)
        hasher.combine(offsiteserver)
    }
}

extension Log: Hashable, Equatable {
    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.dateExecuted == rhs.dateExecuted &&
            lhs.resultExecuted == rhs.resultExecuted &&
            lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(dateExecuted)
        hasher.combine(resultExecuted)
        hasher.combine(id)
    }
}
