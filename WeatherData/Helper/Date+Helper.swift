//
//  Date+Helper.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/10/25.
//

import Foundation

public extension Date {
    var weekdayFullname: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Full weekday name
        let weekdayString = dateFormatter.string(from: self)
        return weekdayString
    }
    var hourMinute: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // Full weekday name
        return dateFormatter.string(from: self)
    }
    var hourMinuteSecond: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss" // Full weekday name
        return dateFormatter.string(from: self)
    }
    var isNight: Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        // 6 AM to 6 PM is considered day; otherwise, it's night
        return hour < 6 || hour >= 18
    }
    func percentInBeforeAfter(before: Double, after: Double) -> Double {
        guard before < after else {
            fatalError("before should smaller than after")
        }
        let cur = self.timeIntervalSince1970
        if cur > after { return 1.0}
        if cur < before { return 0.0}
        let res = (cur - before) / (after - before)
        return res
    }
}
