//: # ✋ Avoid notifications for given tokens
//: [Home](Start) |
//: [Previous](@previous) |
//: [Next](@next)

import RealmSwift
import PlaygroundSupport

Example.of("Avoid notifications for given tokens")
PlaygroundPage.current.needsIndefiniteExecution = true

//: **Setup Realm and preload some data**
let configuration = Realm.Configuration(inMemoryIdentifier: "TemporaryRealm")
let realm = try! Realm(configuration: configuration)

try! TestDataSet.create(in: realm)

let people = realm.objects(Person.self)
let token1 = people.observe { (changes) in
	switch changes {
	case .initial:
		print("Initial notification for token1")
	case .update:
		print("Change notification for token1")
	default: break
	}
}

let token2 = people.observe { (changes) in
	switch changes {
	case .initial:
		print("Initial notification for token2")
	case .update:
		print("Change notification for token2")
	default: break
	}
}

realm.beginWrite()
realm.add(Person())
try! realm.commitWrite(withoutNotifying: [token2])

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
