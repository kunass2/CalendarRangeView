//
//  ViewController.swift
//  CalendarRangeView
//
//  Created by Bartłomiej Semańczyk on 07/05/2022.
//  Copyright (c) 2022 Bartłomiej Semańczyk. All rights reserved.
//

import UIKit
import SnapKit
import CalendarRangeView

class ViewController: UIViewController {
    private var calendarView: CalendarView = {
        let font = UIFont.systemFont(ofSize: 12)
        let format = DateFormatter()
        format.dateFormat = "dd MMM yyyy"
        return CalendarView(tintColor: .orange, font: font, summaryFormat: format, range: 600)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(20)
            maker.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            maker.height.equalTo(400)
        }
        let date = Date()
        calendarView.maxDate = date.addingTimeInterval(24 * 60 * 60 * 50)
        calendarView.startDate = date.addingTimeInterval(24 * 60 * 60 * 2)
        calendarView.endDate = date.addingTimeInterval(24 * 60 * 60 * 8)
        calendarView.reloadData()
    }
}
