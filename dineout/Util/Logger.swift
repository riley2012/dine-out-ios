//
//  Logger.swift
//

import Foundation

public enum LogLevel: Int, CustomStringConvertible {
    case Fatal = 0
    case Error
    case Warning
    case Info
    case Verbose
    
    public var description: String {
        switch self {
        case .Fatal: return "FATAL"
        case .Error: return "ERROR"
        case .Warning: return "WARNING"
        case .Info: return "INFO"
        case .Verbose: return "VERBOSE"
        }
    }
}

public typealias LoggerCompletion = (_ level: LogLevel, _ message: String, _ file: String, _ function: String, _ line: Int) -> Void

public class Logger {
    
    public static var level = LogLevel.Info
    
    public static var loggerCompletion: LoggerCompletion? = nil
    
    public class func useLoggerCompletion(completion: @escaping LoggerCompletion) {
        loggerCompletion = completion
    }
    
    public class func logFatal<T>(_ object: T?,
                                  file: String = #file,
                                  function: String = #function,
                                  line: Int = #line) { logLevel(level: .Fatal, object: object, file: file, function: function, line: line) }
    
    public class func logError<T>(_ object: T?,
                                  file: String = #file,
                                  function: String = #function,
                                  line: Int = #line) { logLevel(level: .Error, object: object, file: file, function: function, line: line) }
    
    public class func logWarning<T>(_ object: T?,
                                    file: String = #file,
                                    function: String = #function,
                                    line: Int = #line) { logLevel(level: .Warning, object: object, file: file, function: function, line: line) }
    
    public class func logInfo<T>(_ object: T?,
                                 file: String = #file,
                                 function: String = #function,
                                 line: Int = #line) { logLevel(level: .Info, object: object, file: file, function: function, line: line) }
    
    public class func logVerbose<T>(_ object: T?,
                                    file: String = #file,
                                    function: String = #function,
                                    line: Int = #line) { logLevel(level: .Verbose, object: object, file: file, function: function, line: line) }
    
    private class func logLevel<T: CustomStringConvertible>(level: LogLevel, object: T?,
                                                            file: String = #file,
                                                            function: String = #function,
                                                            line: Int = #line)
    {
        log(level: level, String(describing: object), file, function, line)
    }
    
    private class func logLevel<T: CustomDebugStringConvertible>(level: LogLevel, object: T?,
                                                                 file: String = #file,
                                                                 function: String = #function,
                                                                 line: Int = #line)
    {
        log(level: level, String(reflecting: object), file, function, line)
    }
    
    private class func logLevel(level: LogLevel, object: NSObject?,
                                file: String = #file,
                                function: String = #function,
                                line: Int = #line)
    {
        if object != nil {
            log(level: level, object!.description, file, function, line)
        } else {
            log(level: level, "", file, function, line)
        }
    }
    
    private class func log(level: LogLevel,
                           _ message: String,
                           _ file: String = #file,
                           _ function: String = #function,
                           _ line: Int = #line)
    {
        if level.rawValue <= Logger.level.rawValue {
            if loggerCompletion != nil {
                loggerCompletion!(level, message, file, function, line)
            }
            let filename = (file as NSString).lastPathComponent
            let logMessage = "\(level.description): \(filename) \(function) LINE:\(line) \(message)"
            print(logMessage)
        }
    }
    
}
