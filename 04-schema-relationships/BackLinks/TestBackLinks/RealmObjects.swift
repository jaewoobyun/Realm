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

class RepairShop: Object {
	@objc dynamic var name = ""
	@objc dynamic var contact = ""
	let maintainedCars = LinkingObjects(fromType: Car.self, property: "shop")
	
	convenience init(_ name: String) {
		self.init()
		self.name = name
	}
}

class Car: Object {
	@objc dynamic var brand = ""
	@objc dynamic var year = 0
	
	@objc dynamic var shop: RepairShop?
	
	convenience init(brand: String, year: Int) {
		self.init()
		self.brand = brand
		self.year = year
	}
}

class Sale: Object {
	@objc dynamic var date = Date.distantPast
	@objc dynamic var value = 0.0
	@objc dynamic var person: Person?
	
}

class Person: Object {
	@objc dynamic var name: String = ""
	let listOfSales = LinkingObjects(fromType: Sale.self, property: "person")
	let bonuses = List<Double>()
	
}

class Store: Object {
	@objc dynamic var name: String = ""
	let cars = List<Car>()
	let employee = List<Person>()
}
