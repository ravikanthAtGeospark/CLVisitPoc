import Foundation
import CoreLocation

internal class LoggerManager: NSObject {

    public static let sharedInstance = LoggerManager()

    private static var fileUrl = { () -> URL in 
        let dir: URL = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
            return dir.appendingPathComponent("geospark.log")
    }()
    
    func writeLocationToFile(_ messageStr:String) {
            let stringValue =  currentTimestamp() + "        " + messageStr + "\n"
            let data = stringValue.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            if FileManager.default.fileExists(atPath: LoggerManager.fileUrl.path) {
                let fileHandle = try! FileHandle(forWritingTo: LoggerManager.fileUrl)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                try! data.write(to: LoggerManager.fileUrl)
            }
    }
    
    func currentTimestamp() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        return dateFormatter.string(from: date)
    }

}
