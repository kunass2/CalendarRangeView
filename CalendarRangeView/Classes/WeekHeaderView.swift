
import UIKit

class WeekHeaderView: UICollectionReusableView {

    @IBOutlet var labels: [UILabel]!
    var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }
    var font = UIFont.systemFont(ofSize: 12)
    var textColor: UIColor = UIColor.darkGray.withAlphaComponent(0.7)
    
    override func awakeFromNib() {
        self.backgroundColor = .white
        labels.forEach {
            $0.textColor = textColor
            $0.font = font.withSize(16)
        }
        if labels.count == calendar.shortWeekdaySymbols.count {
            var weekdaySymbols = calendar.shortWeekdaySymbols
            weekdaySymbols.append(weekdaySymbols.removeFirst())
            (0..<weekdaySymbols.count).forEach { index in
                labels[index].text = String(weekdaySymbols[index])
            }
        }
    }
    
}

extension WeekHeaderView {
    class func register(for collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: WeekHeaderView.nameOfClass,
                                      bundle: CalendarViewFrameworkBundle.main),
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: WeekHeaderView.nameOfClass)
    }
}
