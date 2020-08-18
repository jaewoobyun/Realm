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

import Foundation
import RealmSwift

// Setup
let realm = try! Realm(
  configuration: Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))

print("Ready to play!")

class Person: Object {
	@objc dynamic var name = ""
	
	convenience init(_ name: String) {
		self.init()
		self.name = name
	}
}

class RepairShop: Object {
	@objc dynamic var name = ""
	@objc dynamic var contact: Person?
}

let marin = Person("Marin")
let jack = Person("Jack")

let myLittleShop = RepairShop()
myLittleShop.name = "My Little Auto Shop"
myLittleShop.contact = jack
//myLittleShop.contact = nil

print(myLittleShop.contact?.name ?? "n/a")

guard let name = myLittleShop.contact?.name else { fatalError() }
print(name)

class Car: Object {
	@objc dynamic var brand = ""
	@objc dynamic var year = 0
	
	let repairs = List<Repair>()
	let plates = List<String>()
	let checkups = List<Date>()
	let stickers = List<String>()
	
	//Object relationships
	@objc dynamic var owner: Person?
	@objc dynamic var shop: RepairShop?
	
	convenience init(brand: String, year: Int) {
		self.init()
		self.brand = brand
		self.year = year
	}
	
	override var description: String {
		return "Car {\(brand), \(year)}"
	}
	
}

class Repair: Object {
	@objc dynamic var date = Date()
	@objc dynamic var person: Person?
	
	convenience init(by person: Person) {
		self.init()
		self.person = person
	}
}

let car = Car(brand: "BMW", year: 1980)

Example.of("Object relationships") {
	car.shop = myLittleShop
	car.owner = marin
	
	print(car.shop == myLittleShop)
	print(car.owner!.name)
}

//To-one relationships as object inheritance

class Vehicle: Object {
	@objc dynamic var year = Date.distantPast
	@objc dynamic var isDiesel = false
	
	convenience init(year: Date, isDiesel: Bool) {
		self.init()
		self.year = year
		self.isDiesel = isDiesel
	}
}

class Truck: Object {
	@objc dynamic var vehicle: Vehicle?
	@objc dynamic var nrOfGears = 12
	@objc dynamic var nrOfWheels = 16
	
	convenience init(year: Date, isDiesel: Bool, gears: Int, wheels: Int) {
		self.init()
		self.vehicle = Vehicle(year: year, isDiesel: isDiesel)
		self.nrOfGears = gears
		self.nrOfWheels = wheels
	}
}

Example.of("Adding Object to a different Object's List property") {
	car.repairs.append(Repair(by: jack))
	car.repairs.append(objectsIn: [
		Repair(by: jack),
		Repair(by: jack),
		Repair(by: jack)
		])
	
	print("\(car) has \(car.repairs.count)repairs")
}

Example.of("Adding Pointer to the Same Object") {
	let repair = Repair(by: jack)
	
	car.repairs.append(repair)
	car.repairs.append(repair)
	car.repairs.append(repair)
	car.repairs.append(repair)
	
	print(car.repairs)
	
//	let firstRepair: Date? = car.repairs.min(ofProperty: "date")
//	let lastRepair: Date? = car.repairs.max(ofProperty: "date")
}

Example.of("Adding Primitive types to Realm Lists(s)") {
	//String
	car.plates.append("WYZ 201 Q")
	car.plates.append("2MNYCODZ")
	
	print(car.plates)
	print("Current registration: \(car.plates.last!)")
	
	//Date
	car.checkups.append(Date(timeIntervalSinceNow: -31557600))
	car.checkups.append(Date())
	
	print(car.checkups)
	print(car.checkups.first!)
	print(car.checkups.max()!)
}

class Sticker: Object {
	@objc dynamic var id = UUID().uuidString
	@objc dynamic var text = ""
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	convenience init(_ text: String) {
		self.init()
		self.text = text
	}
	
}

Example.of("Referencing objects from a different REalm file") {
	//Let's say we're storing those in "stickers.realm"
	let sticker = Sticker("Swift is my life")
	
	car.stickers.append(sticker.id)
	print(car.stickers)
	
	try! realm.write {
		realm.add(car)
		realm.add(sticker)
	}
	
	print("Linked stickers:")
	print(realm.objects(Sticker.self).filter("id IN %@", car.stickers))
}
