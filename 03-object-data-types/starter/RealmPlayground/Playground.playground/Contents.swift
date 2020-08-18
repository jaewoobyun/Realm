/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import PlaygroundSupport
import Foundation
import RealmSwift
import CoreLocation

// Setup
let realm = try! Realm(configuration:
  Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))

print("Ready to play...")

// Playground

class Car: Object {
	@objc dynamic var brand = ""
	@objc dynamic var year = 0
	
	convenience init(brand: String, year: Int) {
		self.init()
		self.brand = brand
		self.year = year
	}
	
	override var description: String {
		return "🚗 {\(brand), \(year)}"
	}
}

Example.of("Basic Model") {
	let car1 = Car(brand: "BMW", year: 1980)
	print(car1)
}

class Person: Object {
	//String
	@objc dynamic var firstName = ""
	@objc dynamic var lastName: String?
	//Date
	@objc dynamic var born = Date.distantPast
	@objc dynamic var deceased: Date?
	//Data
	@objc dynamic var photo: Data?
	//Bool
	@objc dynamic var isVIP: Bool = false
//	let allowsPublication = RealmOptional<Bool>()
	
	//Int, Int8, Int16, Int32, Int64
	@objc dynamic var id = 0 //Inferred as Int
	@objc dynamic var hairCount: Int64 = 0
	//Float, Double
	@objc dynamic var height: Float = 0.0
	@objc dynamic var weight = 0.0 //Inferred as Double
	
	//Compound property
//	private let lat = RealmOptional<Double>()
//	private let lng = RealmOptional<Double>()
	
//	var lastLocation: CLLocation? {
//		get {
//			guard let lat = lat.value, let lng = lng.value else {
//				return nil
//			}
//			return CLLocation(latitude: lat, longitude: lng)
//		}
//		set {
//			guard let location = newValue?.coordinate else {
//				lat.value = nil
//				lng.value = nil
//				return
//			}
//			lat.value = location.latitude
//			lng.value = location.longitude
//		}
//	}
	
	//Enumerations
	enum Department: String {
		case technology
		case politics
		case business
		case health
		case science
		case sports
		case travel
	}
	
	@objc dynamic private var _department = Department.technology.rawValue
	
	var department: Department {
		get { return Department(rawValue: _department)! }
		set { _department = newValue.rawValue}
	}
	
	//Computed properties
	var isDeceased: Bool {
		return deceased != nil
	}
	
	var fullName: String {
		guard let last = lastName else {
			return firstName
		}
		return "\(firstName) \(last)"
	}
	
	convenience init(firstName: String, born: Date, id: Int) {
		self.init()
		self.firstName = firstName
		self.born = born
		self.id = id
	}
	
	@objc dynamic var key = UUID().uuidString
	override static func primaryKey() -> String? {
		return "key"
	}
	
	let idPropertyName = "id"
	var temporaryId = 0
	
	@objc dynamic var temporaryUploadId = 0
	override static func ignoredProperties() -> [String] {
		return ["temporaryUploadId"]
	}
	
}


//let myPerson = Person()
//myPerson.allowsPublication.value = true
//myPerson.allowsPublication.value = false
//myPerson.allowsPublication.value = nil

Example.of("Complex Model") {
	let person = Person(firstName: "Marin", born: Date(timeIntervalSince1970: 0), id: 1035)
	person.hairCount = 12345689
	person.isVIP = true
	
	print(type(of: person))
	print(type(of: person).primaryKey() ?? "no primary key")
	print(type(of: person).className())
	
	print(person)
}

@objcMembers class Article: Object {
	dynamic var id = 0
	dynamic var title: String?
}

Example.of("Using @objcMembers") {
	let article = Article()
	article.title = "New article about a famous person"
	
	print(article)
}

/***************************************************
Challenge
***************************************************/

@objcMembers class Book: Object {
	dynamic var ISBN: String = ""
	dynamic var title: String = ""
	dynamic var author: String = ""
	dynamic var bestSeller: Bool = false
	dynamic var firstPublishDate = Date.distantPast
//	dynamic var lastPublishDate: Date?
	
	convenience init(ISBN: String, title: String, author: String, firstPublish: Date) {
		self.init()
		self.ISBN = ISBN
		self.title = title
		self.author = author
		self.firstPublishDate = firstPublish
	}

	
	enum Property: String {
		case ISBN, bestseller
	}
	
	override static func primaryKey() -> String? {
		return Book.Property.ISBN.rawValue
	}
	
	override static func indexedProperties() -> [String] {
		return [Book.Property.bestseller.rawValue]
	}
	
	enum Classifications: String {
		case fiction
		case nonfiction
		case selfhelp
	}
	
	@objc dynamic private var _type =
		Classifications.fiction.rawValue
	
	var type: Classifications {
		get { return Classifications(rawValue: _type)! }
		set { _type = newValue.rawValue }
	}
}

Example.of("Challenge1 Book") {
	let book = Book(ISBN: "1234567890", title: "Realm", author: "Marin Todorov", firstPublish: Date())
	book.bestSeller = true
	book.type = .nonfiction
	
	print(book)
}
