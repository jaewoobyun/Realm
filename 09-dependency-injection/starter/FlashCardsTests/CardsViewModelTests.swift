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

@testable import FlashCards

class CardsViewModelTests: XCTestCase {

  func test_storesSet_whenInitialized() {
//    XCTFail("Test not implemented")
		let setName = "testSet"
		let vm = CardsViewModel(set: testSet(setName))
		
		XCTAssertEqual(vm.set.name, setName)
		
  }

  func test_hasInitialCardState_whenInitialized() {
//    XCTFail("Test not implemented")
		let vm = CardsViewModel(set: testSet())
		
		XCTAssertEqual(vm.text, "face")
		XCTAssertEqual(vm.details, "1 of 1")
		
  }

  func test_updatesState_whenPositionChanges() {
//    XCTFail("Test not implemented")
		
		let testFlashCardSet = FlashCardSet("TestSet1", cards: [FlashCard("face1", "back1"), FlashCard("face2", "back2")])
		
		let vm = CardsViewModel(set: testFlashCardSet)
		
		XCTAssertEqual(vm.text, "face1")
		XCTAssertEqual(vm.details, "1 of 2")
		vm.advance(by: 1)
		XCTAssertEqual(vm.details, "2 of 2")
		vm.advance(by: 1)
		XCTAssertEqual(vm.details, "1 of 2")
		
  }

  func test_updatesState_whenToggled() {
//    XCTFail("Test not implemented")
		
		let vm = CardsViewModel(set: testSet())
		
		XCTAssertEqual(vm.text, "face")
		vm.toggle()
		XCTAssertEqual(vm.text, "back")
		vm.toggle()
		XCTAssertEqual(vm.text, "face")
		
		
  }
	
	private func testSet(_ setName: String = "") -> FlashCardSet {
		return FlashCardSet(setName, cards: [FlashCard("face", "back")])
	}
}
