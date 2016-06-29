import Foundation

let test = NSDate()

let formatter = NSDateFormatter()

formatter.dateFormat = "YYYY.MM.dd HH:mm"

let blub = formatter.stringFromDate(test)

print("\(blub)")