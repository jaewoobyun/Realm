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

#if EXAMS_V2_0

let appVersion = 2.0

  //
  // Realm object schema and view models
  // used in version 2.0 of the Exams app
  //

  // MARK: - Object Schema 3

  @objcMembers final class Subject: Object {
    enum Property: String {
      case name, credits
    }

    dynamic var name = ""
    dynamic var credits = 1

    convenience init(name: String) {
      self.init()
      self.name = name
    }

    override static func primaryKey() -> String? {
      return Subject.Property.name.rawValue
    }

    override static func indexedProperties() -> [String] {
      return [Subject.Property.credits.rawValue]
    }
  }

  @objcMembers final class Exam: Object {
    enum Property: String {
      case id, date, subject, /*result*/ passed, isMultipleChoice
    }

    dynamic var id = UUID().uuidString
    dynamic var date: Date?
    dynamic var subject: Subject?
//    dynamic var result: String?
		dynamic var passed: Result?
    dynamic var isMultipleChoice = false

    convenience init(subject: Subject) {
      self.init()
      self.subject = subject
    }
  }

@objcMembers final class Result: Object {
	enum Property: String { case result }
	enum Value: String { case notSet = "Not Set", pass, fail }
	
	dynamic var result = ""
	
	override static func primaryKey() -> String? {
		return Result.Property.result.rawValue
	}
	
	static func initialData() -> [[String: String]] {
		return [Value.notSet, Value.pass, Value.fail]
			.map{ [Property.result.rawValue: $0.rawValue] }
	}
}


  @objcMembers class MigrationTask: Object {
    struct Task {
      let type: TaskType
      let priority: TaskPriority

      static let askForExamResults = Task(type: .askForExamResults, priority: .askForExamResults)
    }

    enum TaskType: String {
      case askForExamResults
    }

    enum TaskPriority: Int {
      case askForExamResults = 100
    }

    enum Property: String { case name, priority }

    dynamic var name = ""
    dynamic var priority = 0

    @discardableResult
    static func create(task: Task, in migration: Migration) -> MigrationObject {
      return migration.create(
        String(describing: MigrationTask.self),
        value: [
          Property.name.rawValue: task.type.rawValue,
          Property.priority.rawValue: task.priority.rawValue
        ])
    }

    static func first(in realm: Realm) -> MigrationTask? {
      return realm.objects(MigrationTask.self).first
    }

    func complete() {
      guard let realm = realm else { return }
      try? realm.write {
        realm.delete(self)
      }
    }

    override static func primaryKey() -> String? {
      return MigrationTask.Property.name.rawValue
    }
  }



  // MARK: - Realm Provider exams
  extension RealmProvider {
    public static var exams: RealmProvider = {
      // Configuration
      let provider = RealmProvider(config: Realm.Configuration(
        fileURL: try! Path.inLibary("default.realm"),
        schemaVersion: 3,
        migrationBlock: Migrator.migrate,
        objectTypes: [Subject.self, Exam.self, Result.self, MigrationTask.self]))
      return provider
    }()
  }

#endif


