// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import OSLog

public struct AppLogger {
    public static func print(tag: (any AppLogType)?, _ items: Any..., separator: String, file: String, function: String, line: Int) {
        print("custom")
    }
    
    private static var currentLogType: AppLogType.Type = DefaultLogType.self
    private static var logStrategy: LogStrategy = DefaultLogStrategy()
    
    private static let isLoggingEnabled: Bool = {
        if let logValue = ProcessInfo.processInfo.environment["ENABLE_APP_LOGGER"] {
            return logValue.lowercased() == "true"
        } else {
#if DEBUG
            Swift.print("[APP_LOGGER ⚠️]: Xcode Environment Variable `ENABLE_APP_LOGGER` is missing, logs are disabled")
#endif
            return false
        }
    }()
    
    // MARK: - Set Custom LogStrategy
    public static func setLogStrategy(_ strategy: LogStrategy) {
        logStrategy = strategy
    }
    
    // MARK: - Print
    public static func print(
        tag: DefaultLogType? = nil,
        _ items: Any...,
        separator: String = " ",
        file: String = #file,
        function: String = #function,
        line: Int = #line)
    {
#if DEBUG
        guard isLoggingEnabled else { return }
        
        let shortFileName = file.components(separatedBy: "/").last ?? "---"
        let locationInfo = "\(shortFileName) - \(function) - line \(line)"
        
        let output = items.map {
            if let item = $0 as? CustomStringConvertible {
                "\(item.description)"
            } else {
                "\($0)"
            }
        }
            .joined(separator: separator)
        
        let logTag = tag ?? logStrategy.defaultLogType
        
        var msg = "\(logTag.label)"
        
        // if there is a tag, append output in new line
        if !output.isEmpty { msg += "\n\(output)" }
        
        logStrategy.log(message: msg, tag: logTag, category: locationInfo)
#endif
    }
}
