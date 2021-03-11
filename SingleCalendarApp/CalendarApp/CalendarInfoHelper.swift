//
//  CalendarInfoHelper.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/03/07.
//

import Foundation
import UIKit
import CoreData

class CalendarInfoHelper {
    let entity = NSEntityDescription.entity(forEntityName: "CalendarInfo", in: context)
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CalendarInfo")
    
    func insertCalendarInfo(calInst: CalendarInfoInstance){
        if let entity = self.entity {
            let calInfo = NSManagedObject(entity: entity, insertInto: context)
            calInfo.setValue(calInst.title, forKey: "title")
            calInfo.setValue(calInst.titleImage, forKey: "titleImage")
            calInfo.setValue(calInst.id, forKey: "id")
            do {
                try context.save()
                print("save!")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchCalendarInfo()->CalendarInfoInstance{
        var calendarInst: CalendarInfoInstance = CalendarInfoInstance(titleImage: (UIImage(named: "bluecloud")?.jpegData(compressionQuality: 1))!)
        var calendarInfo = [CalendarInfo]()
        do {
            calendarInfo = try context.fetch(self.fetchRequest) as! [CalendarInfo]
        } catch {
            print(error.localizedDescription)
        }
        print("fetch!")
        calendarInst = CalendarInfoInstance(title: calendarInfo[0].title!, titleImage: calendarInfo[0].titleImage!, id: calendarInfo[0].id!)
        return calendarInst
    }
    
    func updateCalendarInfo(calInst: CalendarInfoInstance){
        do {
            let calendarInfo = try context.fetch(fetchRequest)[0] as! NSManagedObject
            calendarInfo.setValue(calInst.id, forKey: "id")
            calendarInfo.setValue(calInst.title, forKey: "title")
            calendarInfo.setValue(calInst.titleImage, forKey: "titleImage")
            do {
                try context.save()
                print("update!\(calendarInfo)")
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteCalendarInfo(){
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(delete)
        } catch {
            print(error.localizedDescription)
        }
    }
}
