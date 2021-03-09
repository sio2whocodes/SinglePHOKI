//
//  ContentHelper.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/02/21.
//

import Foundation
import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

class ContentHelper {
    let entity = NSEntityDescription.entity(forEntityName: "Content", in: context)
    
    func fetchContentsAll(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        var contents = [Content]()
        do {
            contents = try context.fetch(fetchRequest) as! [Content]
        } catch {
            print(error.localizedDescription)
        }
        for content in contents {
            thumnails[content.date!] = UIImage(data: content.thumnail!)
        }
    }
    
    func fetchContent(date: String)->MyContent{
        var contentss = [Content]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        if date != "" {
            fetchRequest.predicate = NSPredicate(format: "date == %@", date)
        }
        do {
            contentss = try context.fetch(fetchRequest) as! [Content]
        } catch {
            print(error.localizedDescription)
        }
        let content = contentss[0] //error
        return MyContent(date: content.date!, images: content.images!, memos: content.memos!, thumnail: UIImage(data: content.thumnail!)!)
    }
    
    /* 월별 패치
    func fetchContents(yymm: String){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        if yymm != "" {
            fetchRequest.predicate = NSPredicate(format: "date LIKE '\(yymm)*'")
        }
        do {
            contents = try context.fetch(fetchRequest) as! [Content]
        } catch {
            print(error.localizedDescription)
        }
        for content in contents {
            DispatchQueue.global().async {
                images[content.date!] = UIImage(data: content.image!)
                memos[content.date!] = content.memo
            }
        }
    }
    */
    
    func updateContent(mycontent: MyContent){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.predicate = NSPredicate(format: "date == %@", mycontent.date)
        do {
            let contents = try context.fetch(fetchRequest) as! [Content]
            let updateContent = contents[0] as NSManagedObject
            updateContent.setValue(mycontent.date, forKey: "date")
            updateContent.setValue(mycontent.images, forKey: "images")
            updateContent.setValue(mycontent.memos, forKey: "memos")
            updateContent.setValue(mycontent.thumnail.jpegData(compressionQuality: 0.5), forKey: "thumnail")
            do {
                try context.save()
                print("update!")
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchContentThumnail(date: String){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.predicate = NSPredicate(format: "date == %@", date)
        do {
            let updateContents = try context.fetch(fetchRequest) as! [Content]
            let updateContent = updateContents[0]
            thumnails[updateContent.date!] = UIImage(data: updateContent.thumnail!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func insertContent(mycontent: MyContent){
        if let entity = self.entity {
            //managed object를 만든다
            let content = NSManagedObject(entity: entity, insertInto: context)
            content.setValue(mycontent.date, forKey: "date")
            content.setValue(mycontent.images, forKey: "images")
            content.setValue(mycontent.memos, forKey: "memos")
            content.setValue(mycontent.thumnail.jpegData(compressionQuality: 0.5), forKey: "thumnail")
            //context에 저장
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteAllContent(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(delete)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteContent(mycontent: MyContent){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Content")
        fetchRequest.predicate = NSPredicate(format: "date == %@", mycontent.date)
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(delete)
        } catch {
            print(error.localizedDescription)
        }
        thumnails.removeValue(forKey: mycontent.date)
    }
}

extension UIImage {

  func getThumbnail() -> UIImage? {

    guard let imageData = self.jpegData(compressionQuality: 0.1) else { return nil }

    let options = [
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: 200] as CFDictionary
    
    guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
    guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }

    return UIImage(cgImage: imageReference)
  }
}
