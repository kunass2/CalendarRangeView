import UIKit
import SnapKit
import RxSwift
import RxCocoa

public protocol CalendarViewDelegate: AnyObject {
    func didSelectDate(startDate: Date, endDate: Date?)
}

public final class CalendarViewFrameworkBundle {
    public static let main: Bundle = Bundle(for: CalendarViewFrameworkBundle.self)
}

public class CalendarView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var monthYearLabel: UILabel!
    @IBOutlet weak var headerBgView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    private let disposeBag = DisposeBag()
    private lazy var summaryButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = font.withSize(22)
        button.setTitleColor(highlightColor, for: .normal)
        return button
    }()
    private let summaryFormatter: DateFormatter
    public weak var delegate: CalendarViewDelegate?
    private var calendarItemList = [CalendarLogic]()
    
    public func reloadData() {
        collectionView.reloadData()
    }
    private var monthRange: Int = 13
    public var maxDate: Date = Date() {
        didSet {
            calcuteDays()
            updateHeader()
            collectionView.reloadData()
        }
    }
    
    public var selectedYear: Int = Date().year{
        didSet {
            let date = Date.from(year: selectedYear, month: 1, day: 1)
            setStartAndEnd(date: date)
            calcuteDays(year: selectedYear)
            updateHeader()
            collectionView.reloadData()
        }
    }
    
    public var startDate: Date? {
        didSet {
            DispatchQueue.main.async { [self] in
                self.moveToSelectedDate(selectedDate: startDate,animated: false)
            }
        }
    }
    
    public var endDate: Date? {
        didSet {
            DispatchQueue.main.async { [self] in
                self.moveToSelectedDate(selectedDate: endDate,animated: false)
                guard let start = startDate else { return }
                self.delegate?.didSelectDate(startDate: start, endDate : endDate)
                self.updateSummary()
            }
        }
    }
    
    private let highlightColor: UIColor
    
    public var highlightScale: CGFloat = 0.8 {
        didSet {
            collectionView.layoutSubviews()
        }
    }
    
    public var todayHighlightColor: UIColor = .red {
        didSet {
            collectionView.layoutSubviews()
        }
    }
    
    public var todayTextColor: UIColor = .white {
        didSet {
            collectionView.layoutSubviews()
        }
    }
    
    public var dayTextColor: UIColor = .gray {
        didSet {
            collectionView.layoutSubviews()
        }
    }
    
    private var font: UIFont = UIFont.systemFont(ofSize: 16)
    
    // MARK: - Initialization
    
    public init(tintColor: UIColor, font: UIFont, summaryFormat: DateFormatter, range: Int) {
        self.summaryFormatter = summaryFormat
        self.highlightColor = tintColor
        self.font = font
        self.monthRange = range
        super.init(frame: .zero)
        commonInit()
        registerCell()
        setupUI()
        setupCollectionView()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    func commonInit() {
        CalendarViewFrameworkBundle.main.loadNibNamed(CalendarView.nameOfClass, owner: self, options: nil)
        addSubview(summaryButton)
        summaryButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview()
        }
        addSubview(contentView)
        contentView.snp.makeConstraints { maker in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.top.equalTo(summaryButton.snp.bottom).offset(5)
        }
    }
    
    public override func awakeFromNib() {
        registerCell()
        setupUI()
        setupCollectionView()
    }
    
    func registerCell(){
        MonthCollectionCell.register(for: collectionView)
        selectedYear = Date().year
    }
    
    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupUI(){
        nextButton.setTitleColor(highlightColor, for: .normal)
        previousButton.setTitleColor(highlightColor, for: .normal)
    }
    
    func updateSummary() {
        guard let startDate = startDate else {
            summaryButton.setTitle(nil, for: .normal)
            return
        }
        guard let endDate = endDate else {
            summaryButton.setTitle(summaryFormatter.string(from: startDate), for: .normal)
            return
        }
        let start = summaryFormatter.string(from: startDate)
        let end = summaryFormatter.string(from: endDate)
        summaryButton.setTitle("\(start) - \(end)", for: .normal)
    }
    
    func calcuteDays(year: Int? = nil){
        calendarItemList = [CalendarLogic]()
        var date : Date = maxDate
        if let year = year {
            date = Date.from(year: year, month: 1, day: 1)
        }
        self.startDate = date
        self.endDate = date
        var dateIter1 = date
        var dateIter2 = date
        
        var set = Set<CalendarLogic>()
        set.insert(CalendarLogic(date: date))
        
        (0..<monthRange).forEach { _ in
            dateIter2 = dateIter2.firstDayOfPreviousMonth
            set.insert(CalendarLogic(date: dateIter2))
            
            if dateIter1.firstDayOfFollowingMonth < maxDate{
                dateIter1 = dateIter1.firstDayOfFollowingMonth
                set.insert(CalendarLogic(date: dateIter1))
            }else{
                return
            }
        }
        calendarItemList = Array(set).sorted(by: <)
    }
    
    func setStartAndEnd(date: Date?){
        startDate = date
        endDate = date
    }
    
    func updateHeader() {
        let pageNumber = Int(collectionView.contentOffset.x / collectionView.frame.width)
        updateHeader(pageNumber: pageNumber)
    }
    
    func updateHeader(pageNumber: Int) {
        if calendarItemList.count > pageNumber && pageNumber>=0{
            let logic = calendarItemList[pageNumber]
            monthYearLabel.text = logic.currentMonthAndYear
            monthYearLabel.font = font.withSize(20)
            monthYearLabel.textColor = .black
        }
    }
    
    @IBAction func retreatToPreviousMonth(button: UIButton) {
        advance(byIndex: -1, animate: false)
    }
    
    @IBAction func advanceToFollowingMonth(button: UIButton) {
        advance(byIndex: 1, animate: false)
    }
    
    func advance(byIndex: Int, animate: Bool) {
        var visibleIndexPath = self.collectionView.indexPathsForVisibleItems.first!
        let pageNumber = visibleIndexPath.item + byIndex
        
        if calendarItemList.count <= pageNumber || pageNumber < 0{
            return
        }
        visibleIndexPath = IndexPath(item: pageNumber,
                                     section: visibleIndexPath.section)
        updateHeader(pageNumber: pageNumber)
        collectionView.scrollToItem(at: visibleIndexPath,
                                    at: .centeredHorizontally,
                                    animated: animate)
    }
    
    func moveToSelectedDate(selectedDate: Date?, animated: Bool) {
        guard let selectedDate = selectedDate else { return }
        let index = (0..<calendarItemList.count).firstIndex { index -> Bool in
            let logic = calendarItemList[index]
            if logic.containsDate(date: selectedDate) {
                return true
            }
            return false
        }
        
        if let index = index {
            let indexPath = IndexPath(item: index, section: 0)
            updateHeader(pageNumber: indexPath.item)
            collectionView.scrollToItem(at: indexPath,
                                        at: .centeredHorizontally,
                                        animated: animated)
        }
    }
    
    // MARK: - Private
    
    private func setupActions() {
        summaryButton.rx.tap.bind { [weak self] in
            if let startDate = self?.startDate {
                self?.moveToSelectedDate(selectedDate: startDate, animated: true)
            }
        }.disposed(by: disposeBag)
    }
}

extension CalendarView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return calendarItemList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MonthCollectionCell.nameOfClass,
            for: indexPath) as! MonthCollectionCell
        cell.monthCellDelegate = self
        let calendarLogic = calendarItemList[indexPath.item]
        cell.setUserInterfaceProperties(highlightColor: highlightColor,
                                        highlightScale: highlightScale,
                                        todayHighlightColor: todayHighlightColor,
                                        todayTextColor: todayTextColor,
                                        dayTextColor: dayTextColor,
                                        dayFont: font)
        cell.logic = calendarLogic
        cell.maxDate = maxDate
        cell.setStartAndEndDate(start: startDate, end: endDate)
        return cell
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension CalendarView: UIScrollViewDelegate {
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            updateHeader()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateHeader()
    }
}

extension CalendarView : MonthCollectionCellDelegate {
    func startSelectedDate() -> Date? {
        return startDate
    }
    
    func endSelectedDate() -> Date? {
        return endDate
    }

    func didSelect(startDate: Date?, endDate: Date?) {
        self.startDate = startDate ?? nil
        self.endDate = endDate ?? nil
        collectionView.reloadData()
    }
    
    func isStartOrEnd(date: Date) -> Bool {
        let result = date.areSameDay(date: startDate) || date.areSameDay(date: endDate)
        return result
    }
    
    func isBetweenStartAndEnd(date: Date) -> Bool{
        guard let start = startDate, let end = endDate else { return false }
        return date >= start && date <= end && start != end
    }
}
