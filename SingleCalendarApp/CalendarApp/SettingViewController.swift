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
    @IBOutlet weak var saveButton: UIButton!
    var calendarInfo = CalendarInfoInstance(titleImage: UIImage(named: "유기현트로피뿌숨")!.jpegData(compressionQuality: 1)!)
    let calendarInfoHelper = CalendarInfoHelper()
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        calendarInfo = calendarInfoHelper.fetchCalendarInfo()
        saveButton.layer.cornerRadius = 5
        titleLabel.text = calendarInfo.title
        titleImageView.image = UIImage(data: calendarInfo.titleImage!)
//        calendarInfoHelper.deleteCalendarInfo()
//        calendarInfoHelper.insertCalendarInfo(calInst: calendarInfo)
    }
    @IBAction func imgSelect(_ sender: Any) {
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
    }
    @IBAction func saveButton(_ sender: Any) {
        calendarInfo.title = titleLabel.text!
        calendarInfo.titleImage = titleImageView.image?.jpegData(compressionQuality: 1)
        calendarInfoHelper.updateCalendarInfo(calInst: calendarInfo)
    }
    
}

extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            calendarInfo.titleImage = image.jpegData(compressionQuality: 1)
            calendarInfoHelper.updateCalendarInfo(calInst: calendarInfo)
        }
        dismiss(animated: true, completion: self.viewDidLoad)
    }
}

extension SettingViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print("end")
        calendarInfo.title = textField.text!
    }
}
