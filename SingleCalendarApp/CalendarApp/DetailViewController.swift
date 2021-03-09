//
//  DetailViewController.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/02/11.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    @IBOutlet var detailView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    let picker = UIImagePickerController()
    let contentHelper = ContentHelper()
    var myContent = MyContent(date: "", images: [UIImage(named: "기현")?.jpegData(compressionQuality: 0.1)], memos: [""],thumnail: UIImage())
    var now = ""
    var yearMonth = ""
    var date = ""
    var idx = 0
    var isAdd = false

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        myContent = contentHelper.fetchContent(date: now)
        if date.count == 1 {
            date = "0"+date
        }
        let yearIdx = yearMonth.index(yearMonth.startIndex, offsetBy: 4)
        dateLabel.text = yearMonth[yearMonth.startIndex..<yearIdx]+"."+yearMonth[yearIdx..<yearMonth.endIndex]+"."+self.date
        addButtonShadow()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        collectionView.addGestureRecognizer(gesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !myContent.images.isEmpty {
            print("B viewWillDisappear")
            myContent.thumnail = UIImage(data: myContent.images[0]!)!.getThumbnail()!
            contentHelper.updateContent(mycontent: myContent)
        }
        presentingViewController?.children[0].viewWillAppear(true)
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        isAdd = true
        openLibrary()
    }
    
    func addButtonShadow(){
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.masksToBounds = false
        addButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        addButton.layer.shadowRadius = 2
        addButton.layer.shadowOpacity = 0.2
    }
    
    //뒤로가기 버튼
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //이미지 삭제
    func deleteImg(_: UIAlertAction){
        if myContent.images.count == 1 {
            myContent.images.removeAll()
            myContent.memos.removeAll()
            contentHelper.deleteContent(mycontent: myContent)
            dismiss(animated: true, completion: nil)
        } else {
            myContent.images.remove(at: idx)
            myContent.memos.remove(at: idx)
            //첫번째 사진 지우면 썸네일 변경
            if idx == 0 {
                myContent.thumnail = UIImage(data:myContent.images[0]!)!.getThumbnail()!
            }
            collectionView.reloadData()
            print("delete result : \(myContent.images)")
            contentHelper.updateContent(mycontent: myContent)
        }
    }
    
    //이미지 변경
    func updateImg(_: UIAlertAction){
        isAdd = false
        openLibrary()
        contentHelper.updateContent(mycontent: myContent)
        contentHelper.fetchContentThumnail(date: now)
    }
    
    func openLibrary(){
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
    }
}

extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myContent.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailcell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        cell.memoLabel.clipsToBounds = true
        cell.memoLabel.layer.cornerRadius = 8
        cell.imgView.image = UIImage(data: myContent.images[indexPath.item]!)
        cell.imgView.layer.cornerRadius = 10
        cell.memoTextView.text = myContent.memos[indexPath.item]
        cell.memoTextView.tag = indexPath.item
        cell.button.tag = indexPath.item
        cell.button.addTarget(self, action: #selector(imgbtnClick(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func imgbtnClick(sender: UIButton){
        idx = sender.tag
        var alert: UIAlertController
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: "사진 수정", message: "", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "사진 수정", message: "", preferredStyle: .actionSheet)
        }
        let editAction = UIAlertAction(title: "사진 변경",
                                       style: .default,
                                       handler: updateImg(_:))
        let deleteAction = UIAlertAction(title: "사진 삭제",
                                         style: .default,
                                         handler: deleteImg(_:))
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let targetImage = myContent.images.remove(at: sourceIndexPath.item)
        let targetMemo = myContent.memos.remove(at: sourceIndexPath.item)
        myContent.images.insert(targetImage, at: destinationIndexPath.item)
        myContent.memos.insert(targetMemo, at: destinationIndexPath.item)
        print("move!")
    }
    
}

extension DetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt:\(indexPath)")
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 30
        let height = collectionView.frame.height - 30
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}

//ImagePicker
extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            //사진 추가
            if isAdd {
                self.myContent.images.append(image.jpegData(compressionQuality: 0.1))
                self.myContent.memos.append("")
            } else {
                //사진 변경
                self.myContent.images[idx] = image.jpegData(compressionQuality: 0.1)
                self.myContent.thumnail = UIImage(data: self.myContent.images[0]!)!.getThumbnail()!
            }
            contentHelper.updateContent(mycontent: myContent)
            contentHelper.fetchContentThumnail(date: now)
        }
        collectionView.reloadData()
        dismiss(animated: true, completion: self.viewDidLoad)
    }
}

extension DetailViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    @objc func keyBoardWillShow(_ sender: Notification){
        self.view.frame.origin.y = -150
    }
    
    @objc func keyBoardWillHide(_ sender: Notification){
        self.view.frame.origin.y = 0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textView:\(textView)")
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        myContent.memos[textView.tag] = textView.text
        contentHelper.updateContent(mycontent: myContent)
    }
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var button: UIButton!
}
