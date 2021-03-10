//
//  ViewController.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/02/08.
//

import UIKit
import CoreData

var thumnails = [String:UIImage]()

class ViewController: UIViewController {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var CalendarLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    var selectedDate = Date()
    var totalDates = [String]()
    let calendarHelper = CalendarHelper()
    let picker = UIImagePickerController()
    let contentHelper = ContentHelper()
    var calendarInfo = CalendarInfoInstance(title: "KIHYUN CALENDAR", titleImage: (UIImage(named: "유기현트로피뿌숨")?.jpegData(compressionQuality: 1))!, id: "id")
    let calendarInfoHelper = CalendarInfoHelper()
    var now = ""
    var yymm = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        print("viewDidLoad")
        backgroundView.layer.borderWidth = 0.3
        backgroundView.layer.borderColor = UIColor.lightGray.cgColor
        calendarInfoHelper.insertCalendarInfo(calInst: calendarInfo)
        calendarInfo = calendarInfoHelper.fetchCalendarInfo()
        CalendarLabel.text = calendarInfo.title
        titleImageView.image = UIImage(data: calendarInfo.titleImage!)
        setMonthView()
        contentHelper.fetchContentsAll()
//        contentHelper.deleteAllContent()
        addButtonShadow()
        collectionView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        contentHelper.fetchContentsAll()
        collectionView.reloadData()
        calendarInfo = calendarInfoHelper.fetchCalendarInfo()
        CalendarLabel.text = calendarInfo.title
        titleImageView.image = UIImage(data: calendarInfo.titleImage!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
    }
    
    func setMonthView() {
        totalDates.removeAll()
        let datesInMonth = calendarHelper.numOfDatesInMonth(date: selectedDate)
        let firstDayOfMonth = calendarHelper.firstDayOfMonth(date: selectedDate)
        let startingSpaces = calendarHelper.weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        
        while(count <= 42){
            if count <= startingSpaces || count - startingSpaces > datesInMonth {
                totalDates.append("")
            }else{
                totalDates.append("\(count-startingSpaces)")
            }
            count += 1
        }
 
        monthLabel.text = calendarHelper.monthString(date: selectedDate) + "월 " + calendarHelper.yearString(date: selectedDate)
        yymm = calendarHelper.yearString(date: selectedDate) + calendarHelper.monthString(date: selectedDate)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        selectedDate = calendarHelper.previousMonth(date: selectedDate)
        setMonthView()
//        fetchContents(yymm: yymm)
    }
    @IBAction func nextMonth(_ sender: Any) {
        selectedDate = calendarHelper.nextMonth(date: selectedDate)
        setMonthView()
//        fetchContents(yymm: yymm)
    }
    
    @IBAction func addBtn(_ sender: Any) {
        now = String(calendarHelper.yearString(date: Date())) + String(calendarHelper.monthString(date: Date())) + String(calendarHelper.dayOfMonth(date: Date()))
        openLibrary()
    }
    
    func addButtonShadow(){
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.masksToBounds = false
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButton.layer.shadowRadius = 2
        addButton.layer.shadowOpacity = 0.2
    }
    
    //화면 방향 전환 (landscape 지원안함)
    override open var shouldAutorotate: Bool {
        return false
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return totalDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        now = yymm + totalDates[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }
        cell.dayOfMonth.text = totalDates[indexPath.item]
        
        DispatchQueue.main.async {
            if cell.dayOfMonth.text != "" {
                cell.imgView.image = thumnails[self.yymm + self.totalDates[indexPath.item]]
                cell.imgView.layer.cornerRadius = 2
                cell.contentView.bringSubviewToFront(cell.imgView)
            }else{
                cell.imgView.image = nil
            }
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width)/8 + 5 // why not 7?
//        let height = width * 10/7
        let height = (collectionView.frame.size.height)/6
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: 2, left: 1, bottom: 1, right: 1)
        return inset
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        now = yymm + totalDates[indexPath.item]
        if totalDates[indexPath.item] != "" {
            if thumnails[now] == nil {
                openLibrary()
            } else {
                performSegue(withIdentifier: "showdetail", sender: now)
            }
        }
    }
    
    func openLibrary(){
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showdetail" {
            if let cell = sender as? CalendarCell {
                if cell.imgView.image == nil {
                    return false
                }
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showdetail" {
            if let vc = segue.destination as? DetailViewController {
                vc.yearMonth = yymm
                if let cell = sender as? CalendarCell {
                    vc.now = yymm + cell.dayOfMonth.text!
                    vc.date = cell.dayOfMonth.text!
                }
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            if thumnails[now] != nil {
                //오늘 이미지 있는데 추가할때
                print(now)
                var nowContent = contentHelper.fetchContent(date: now)
                nowContent.images.append(image.jpegData(compressionQuality: 1))
                nowContent.memos.append("")
                let newContent = MyContent(date: now, images: nowContent.images, memos: nowContent.memos, thumnail: nowContent.thumnail)
                contentHelper.updateContent(mycontent: newContent)
            } else {
                let mycontent = MyContent(date: now, images: [image.jpegData(compressionQuality: 1)], memos: [""], thumnail: image.getThumbnail()!)
                contentHelper.insertContent(mycontent: mycontent)
            }
            contentHelper.fetchContentThumnail(date: now)
            collectionView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
}
