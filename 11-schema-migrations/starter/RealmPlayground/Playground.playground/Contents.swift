
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

// MARK: - Realm entities

@objcMembers class Exam: Object {
  enum Property: String { case name }
  dynamic var name = ""
  override var description: String {
    return "Exam {name: \"\(name)\"}"
  }
}

@objcMembers class Mark: Object {
  enum Property: String { case mark }
  dynamic var mark = ""
  override var description: String {
    return "Mark {mark: \"\(mark)\"}"
  }
}

func migrateFrom1To2(_ migration: Migration) {
	print("Migration from 1 to version 2")
	
	migration.enumerateObjects(ofType: String(describing: Exam.self)) { (from, to) in
		guard let from = from,
				let to = to,
				let name = from[Exam.Property.name.rawValue] as? String,
				name.isEmpty else { return }
		
		to[Exam.Property.name.rawValue] = "n/a"
	}
}

func migrateFrom2To3(_ migration: Migration) {
	print("Migration from 2 to version 3")
	
	migration.enumerateObjects(ofType: String(describing: Mark.self)) { (from, to) in
		guard let from = from,
				let to = to,
				let mark = from[Mark.Property.mark.rawValue] as? String,
				mark.isEmpty else { return }
		
		to[Mark.Property.mark.rawValue] = "F"
	}
}

func migrateFrom3To4(_ migration: Migration) {
	print("Migration from 3 to version 4")
	
	migration.deleteData(forType: "Mark")
	
	
}

// MARK: - Migrations code
print("Ready to play...")


// Initially install & run the 1.0 version app
Example.of("Run app ver. 1.0") {
	let conf = Realm.Configuration(
		schemaVersion: 1,
		deleteRealmIfMigrationNeeded: true,
		objectTypes: [Exam.self])
	
	let realm = try! Realm(configuration: conf)
	try! realm.write {
		realm.add(Exam())
		print("Exams: \(Array(realm.objects(Exam.self)))")
	}
}

// Simulate running the 1.5 version of the app,
// comment this one to simulate non-linear migration
Example.of("Run app ver. 1.5") {
	func migrationBlock(migration: Migration, oldVersion: UInt64) {
		//
		if oldVersion < 2 {
			migrateFrom1To2(migration)
		}
	}

	let conf = Realm.Configuration(
		schemaVersion: 2,
		migrationBlock: migrationBlock,
		objectTypes: [Exam.self, Mark.self]
	)
	let realm = try! Realm(configuration: conf)
	print("Exams: \(Array(realm.objects(Exam.self)))")
	print("Marks: \(Array(realm.objects(Mark.self)))")

	try! realm.write {
		realm.add(Mark())
	}

}

Example.of("Run app ver. 2.0") {
	func migrationBlock(migration: Migration, oldVersion: UInt64) {
		if oldVersion < 2 {
			migrateFrom1To2(migration)
		}
		
		if oldVersion < 3 {
			migrateFrom2To3(migration)
		}
	}
	
	let conf = Realm.Configuration(
		schemaVersion: 3,
		migrationBlock: migrationBlock,
		objectTypes: [Exam.self, Mark.self]
	)
	
	let realm = try! Realm(configuration: conf)
	
	print("Exams: \(Array(realm.objects(Exam.self)))")
	print("Marks: \(Array(realm.objects(Mark.self)))")
	
}

//Challenge (Adding another app version, remove Mark object from schema)
Example.of("Run app ver. 2.5") {
	func migrationBlock(migration: Migration, oldVersion: UInt64) {
		if oldVersion < 2 {
			migrateFrom1To2(migration)
		}
		
		if oldVersion < 3 {
			migrateFrom2To3(migration)
		}
		
		if oldVersion < 4 {
			migrateFrom3To4(migration)
		}
	}
	
	let conf = Realm.Configuration(
		schemaVersion: 4,
		migrationBlock: migrationBlock,
		objectTypes: [Exam.self, Mark.self]
	)
	
	let realm = try! Realm(configuration: conf)
	
	print("Exams: \(Array(realm.objects(Exam.self)))")
}
