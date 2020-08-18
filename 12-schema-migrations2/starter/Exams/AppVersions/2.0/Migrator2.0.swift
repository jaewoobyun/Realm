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

struct Migrator {

  static func schema(_ schema: Schema, includesProperty name: String, for className: String) -> Bool {
    return schema.objectSchema.reduce(false, { result, object in
      return result || (object.className == className && object.properties.first(where: { $0.name == name}) != nil)
    })
  }

  static func migrate(migration: Migration, oldVersion: UInt64) {
    if oldVersion < 2 {
      print("Migrate to Realm Schema 2")

      let multipleChoiceText = " (multiple choice)"
      enum Key: String { case isMultipleChoice, subject, name }

      var migratedExamCount = 0

      migration.enumerateObjects(ofType: String(describing: Exam.self)) { _, newExam in
        guard let newExam = newExam,
          let subject = newExam[Key.subject.rawValue] as? MigrationObject,
          let subjectName = subject[Key.name.rawValue] as? String else { return }

        if subjectName.contains(multipleChoiceText) {
          newExam[Key.isMultipleChoice.rawValue] = true
          subject[Key.name.rawValue] = subjectName.replacingOccurrences(of: multipleChoiceText, with: "")
        }

        migratedExamCount += 1
      }

      print("Schema 2: Migrated \(migratedExamCount) exams")
    }
		
		if oldVersion < 3 {
			enum Key: String { case result, passed }
			var isInteractiveMigrationNeeded = false
			
			let results = Result.initialData().map {
				return migration.create(String(describing: Result.self), value: $0)
			}
			let noResult = results[0]
			let passed = results[1]
			let fail = results[2]
			
			let examClassName = String(describing: Exam.self)
			
			migration.enumerateObjects(ofType: examClassName) { oldExam, newExam in
				guard let oldExam = oldExam, let newExam = newExam else { return }
				
//				if schema(migration.oldSchema, includesProperty: Key.result.rawValue, for: examClassName), oldExam[Key.result.rawValue] as? String != nil {
//					isInteractiveMigrationNeeded = true
//				} else {
//					newExam[Key.passed.rawValue] = noResult
//				}
				
				// Challenge 1!!!!!!!!!
				
				if schema(migration.oldSchema, includesProperty: Key.result.rawValue, for: examClassName),
					let oldResult = oldExam[Key.result.rawValue] as? String {
					if oldResult.contains("pass") {
						newExam[Key.passed.rawValue] = passed
					} else if oldResult.contains("fail") {
						newExam[Key.passed.rawValue] = fail
					} else {
						//fallback to user interaction
						isInteractiveMigrationNeeded = true
					}
				} else {
					newExam[Key.passed.rawValue] = noResult
				}

			}
			
			if isInteractiveMigrationNeeded {
				MigrationTask.create(task: .askForExamResults, in: migration)
			}
			
		}

  }
}

#endif
