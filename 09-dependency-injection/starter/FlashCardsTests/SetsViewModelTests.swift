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

import XCTest
import RealmSwift

@testable import FlashCards

private func indicesToString(string: String, indices: [Int]) -> String {
  return "\(string)[" + indices.map(String.init)
    .joined(separator: ",") + "]"
}

class SetsViewModelTests: XCTestCase {

  func test_loadsSets_whenInitialized() {
//    XCTFail("Test not implemented")
		let testCards = RealmProvider.cards.copyForTesting()
		let setName = "testSet"
		
		testCards.realm.addForTesting(objects: [FlashCardSet(setName, cards: [FlashCard("face", "back")])])
		
		let vm = SetsViewModel(cards: testCards, api: CardsAPI())
		
		XCTAssertEqual(vm.sets.count, 1)
		XCTAssertEqual(vm.sets.first?.name, setName)
  }

  func test_propagatesChanges_whenSetsUpdated() {
//    XCTFail("Test not implemented")
		let testCards = RealmProvider.cards.copyForTesting()
		let setName = "testSet"
		testCards.realm.addForTesting(objects: [FlashCardSet(setName, cards: [FlashCard("face", "back")])])
		let vm = SetsViewModel(cards: testCards, api: CardsAPI())
		
		var results = [String]()
		let expectation = XCTestExpectation()
		expectation.expectedFulfillmentCount = 3
		
		vm.didUpdate = { del, ins, upd in
			let result = [del, ins, upd].reduce("", indicesToString)
			results.append(result)
			expectation.fulfill()
		}
		
		DispatchQueue.main.async {
			testCards.realm.addForTesting(objects: [FlashCardSet(setName + "New", cards: [FlashCard("face", "back")])])
			try! testCards.realm.write {
				testCards.realm.deleteAll()
			}
		}
		
		let waitResult = XCTWaiter().wait(for: [expectation], timeout: 1.0)
		
		XCTAssertNotEqual(waitResult, .timedOut)
		XCTAssertEqual(results[0], "[][][]")
		XCTAssertEqual(results[1], "[][1][]")
		XCTAssertEqual(results[2], "[0,1][][]")
		
  }
}
