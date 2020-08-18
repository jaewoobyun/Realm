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

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Tools.runIfNeeded()
    setupRealm()
    return true
  }

  private func setupRealm() {
    let cardsRealm = RealmProvider.cards.realm
    let bundledSetsRealm = RealmProvider.bundled.realm

    var setsToCopy = [FlashCardSet]()
    for bundledSet in bundledSetsRealm.objects(FlashCardSet.self)
      where cardsRealm.object(
        ofType: FlashCardSet.self,
        forPrimaryKey: bundledSet.name) == nil {

          setsToCopy.append(bundledSet)
    }

    guard setsToCopy.count > 0 else { return }

    try! cardsRealm.write {
      for cardSet in setsToCopy {
        cardsRealm.create(FlashCardSet.self, value: cardSet, update: false)
      }
    }
  }
}

// MARK: - Constants

let primaryColor = UIColor(red: 33/255.0, green: 61/255.0, blue: 78/255.0, alpha: 1)
let secondaryColor = UIColor(red: 103/255.0, green: 176/255.0, blue: 239/255.0, alpha: 1)
