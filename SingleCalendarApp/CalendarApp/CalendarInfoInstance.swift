//
//  CalendarInfoInstance.swift
//  CalendarApp
//
//  Created by 임수정 on 2021/03/07.
//

import UIKit

class CalendarInfoInstance {
    var title: String = "MY CALENDAR"
    var titleImage: Data?
    var id: String = "id"
    
    init(title: String, titleImage: Data, id: String) {
        self.title = title
        self.titleImage = titleImage
        self.id = id
    }
    init(titleImage: Data) {
        self.titleImage = titleImage
    }
}
