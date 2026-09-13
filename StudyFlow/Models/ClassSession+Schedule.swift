import Foundation

extension ClassSession {
    func occurs(on date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)

        let matchesWeekday =
            calendar.component(.weekday, from: targetDate)
            == weekday

        guard matchesWeekday else {
            return false
        }

        if let semesterStart {
            let start = calendar.startOfDay(for: semesterStart)

            if targetDate < start {
                return false
            }
        }

        if let semesterEnd {
            let end = calendar.startOfDay(for: semesterEnd)

            if targetDate > end {
                return false
            }
        }

        return true
    }
}
