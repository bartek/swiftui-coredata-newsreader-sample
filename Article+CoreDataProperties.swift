//
//  Article+CoreDataProperties.swift
//  NewsReader
//
//  Created by Bartek Ciszkowski on 2020-08-03.
//  Copyright © 2020 Bartek Ciszkowski. All rights reserved.
//
//

import Foundation
import CoreData


extension Article: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var title: String
    @NSManaged public var author: String
    @NSManaged public var publishedAt: Date
    @NSManaged public var url: String

}
