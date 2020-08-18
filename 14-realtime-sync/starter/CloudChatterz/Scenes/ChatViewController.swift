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

class ChatViewController: UIViewController {

  // MARK: - outlets

  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var leave: UIBarButtonItem!
  @IBOutlet private var message: UITextField!
  @IBOutlet var footerBottomSpace: NSLayoutConstraint!

  // MARK: - properties

  private var realm: Realm?

  private var roomSync: SyncSubscription<ChatRoom>?
  private var roomSubscription: NotificationToken?

  private var items: List<ChatItem>?
  private var itemsSubscription: NotificationToken?

  private var room: ChatRoom?
  private var roomName: String!
  private var name: String!

  // MARK: - view controller life cycle

  static func createWith(storyboard: UIStoryboard = UIStoryboard.main,
                         roomName: String, name: String) -> ChatViewController {
    let vc = storyboard.instantiateViewController(ChatViewController.self)
    vc.name = name
    vc.title = roomName
    vc.roomName = roomName
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-pattern")!)
    message.layer.borderColor = UIColor(red:0.38, green:0.33, blue:0.66, alpha:1.0).cgColor

    constrainToKeyboardTop(constraint: footerBottomSpace) { [weak self] in
      guard let count = self?.items?.count else { return }

      self?.tableView.scrollToRow(at: IndexPath(row: count-1, section: 0), at: .bottom, animated: true)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    RealmProvider.chat.realm { [weak self] realm, error in
      guard error == nil, let realm = realm else {
        return UIAlertController.message("Database error", message: error!.localizedDescription)
      }

      self?.realm = realm
      self?.fetchMessages(in: realm)
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(false)
		itemsSubscription?.invalidate()
		roomSubscription?.invalidate()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - actions

  private func fetchMessages(in realm: Realm) {
		roomSync = realm.objects(ChatRoom.self)
			.filter(NSPredicate(format: "%K = %@", ChatRoom.Property.name.rawValue, roomName))
			.subscribe()
		
		roomSubscription = roomSync?.observe(\.state) { [weak self] (state) in
			guard let this = self, state == .complete else { return }
			
			this.room = realm.object(ofType: ChatRoom.self, forPrimaryKey: this.roomName)
			this.items = this.room?.items
			
			this.itemsSubscription = this.items?.observe{ (changes) in
				guard let tableView = this.tableView else { return }
				tableView.applyRealmChanges(changes)
				
				guard !this.items!.isEmpty else { return }
				tableView.scrollToRow(at: IndexPath(row: this.items!.count-1, section: 0), at: .bottom, animated: true)
				
				this.leave.isEnabled = true
				
			}
		}
		
  }

  @IBAction func send(_ sender: Any) {
		guard let text = message.text, !text.isEmpty,
			let room = room else { return }
		
		ChatItem(sender: name, message: text).add(in: room)
		message.text = nil
  }

  @IBAction func leave(_ sender: Any) {
		guard let roomSync = roomSync else { return }
		roomSync.unsubscribe()
    navigationController!.popViewController(animated: true)
  }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! BubbleCell
    if let item = items?[indexPath.row] {
      cell.configure(with: item, isMe: name == item.sender)
    }
    return cell
  }
}

extension ChatViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}
