//: # 🙆‍♂️ Observing an Object
//: [Home](Start) |
//: [Previous](@previous) |
//: [Next](@next)
import Foundation
import RealmSwift
import PlaygroundSupport

Example.of("Observing an Object")
PlaygroundPage.current.needsIndefiniteExecution = true

//: **Setup Realm**
let configuration = Realm.Configuration(inMemoryIdentifier: "TemporaryRealm")
let realm = try! Realm(configuration: configuration)

let article = Article()
article.id = "new-article"

try! realm.write {
	realm.add(article)
}

let token = article.observe { change in
	switch change {
	case .change(let properties):
		
		for property in properties {
			switch property.name {
			case "title":
				print(" Article tittle changed from \(property.oldValue ?? "nil") to \(property.newValue ?? "nil")")
			case "author":
				print("Author changed to \(property.newValue ?? "nil")")
			default: break
			}
		}
		
		if properties.contains(where: { $0.name == "date"}) {
			print("date has changed to \(article.date)")
		}
		
		break
	case .error(let error):
		print("Error occurred: \(error)")
	case .deleted:
		print("Article was deleted")
	}
}

print("Subscription token: \(token)")

try! realm.write {
	article.title = "Work in progress"
}

DispatchQueue.global(qos: .background).async {
	let realm = try! Realm(configuration: configuration)
	
	if let article = realm.object(ofType: Article.self, forPrimaryKey: "new-article") {
		try! realm.write {
			article.title = "Actual title"
			article.author = Person()
		}
	}
}
//: [Next](@next)
/*:
 Copyright (c) 2018 Razeware LLC

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 distribute, sublicense, create a derivative work, and/or sell copies of the
 Software in any work that is designed, intended, or marketed for pedagogical or
 instructional purposes related to programming, coding, application development,
 or information technology.  Permission for such use, copying, modification,
 merger, publication, distribution, sublicensing, creation of derivative works,
 or sale is expressly withheld.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
