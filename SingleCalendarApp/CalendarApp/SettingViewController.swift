//
//  SettingViewController.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/03/07.
//

import UIKit
import CoreData

class SettingViewController: UIViewController {

    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var titleImageView: UIImageView!
    var calendarInfo = CalendarInfoInstance(titleImage: UIImage(named: "유기현트로피뿌숨")!.jpegData(compressionQuality: 1)!)
//    let calendarInfoHelper = CalendarInfoHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarInfo = CalendarInfoInstance(title: "Calendar", titleImage: UIImage(named: "유기현트로피뿌숨")!.jpegData(compressionQuality: 1)!, id: "id")
//        calendarInfo = calendarInfoHelper.fetchCalendarInfo()
        titleLabel.text = calendarInfo.title
        titleImageView.image = UIImage(data: calendarInfo.titleImage!)
    }
    @IBAction func saveButton(_ sender: Any) {
    }
    
}
