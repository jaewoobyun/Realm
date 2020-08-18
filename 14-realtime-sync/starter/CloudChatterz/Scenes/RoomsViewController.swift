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

class RoomsViewController: UIViewController {

  // MARK: - outlets

  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var name: UITextField!
  @IBOutlet private var spinner: UIActivityIndicatorView!

  // MARK: - properties

  private var realm: Realm?

  private var roomNames: List<String>?
  private var roomNamesSubscription: NotificationToken?

  private var roomsSubscription: NotificationToken?
	
	private var chatSync: SyncSubscription<Chat>?
	private var chatSubscription: NotificationToken?

  // MARK: - view controller life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-pattern")!)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard realm == nil else { return }

    RealmProvider.chat.realm { [weak self] realm, error in
      guard error == nil, let realm = realm else {
        return UIAlertController.message("Database error", message: error!.localizedDescription)
      }
      self?.realm = realm
      self?.fetchRooms(in: realm)
    }
  }

  deinit {
		roomNamesSubscription?.invalidate()
		roomsSubscription?.invalidate()
  }

  // MARK: - actions

  private func fetchRooms(in realm: Realm) {
    spinner.startAnimating()
		
		chatSync = realm.objects(Chat.self).subscribe()
		chatSubscription = chatSync?.observe(\.state, options: .initial, { [weak self] (state) in
			guard let this = self, state == .complete else { return }
			this.spinner.stopAnimating()
			
			this.roomNames = Chat.default(in: realm).rooms
			this.roomNamesSubscription = this.roomNames?.observe { (changes) in
				this.tableView.applyRealmChanges(changes)
			}
			
			this.roomsSubscription = realm.objects(ChatRoom.self).observe { (_) in
				this.tableView.reloadData()
			}

		})

  }

  @IBAction func add(_ sender: Any) {
    UIAlertController.input("Create Room") { [weak self] name in
      self?.createRoomAndEnter(withName: name)
    }
  }

  private func createRoomAndEnter(withName roomName: String) {
		guard !roomName.isEmpty, let realm = realm, let myName = name.text else { return }
		
		let newRoom = ChatRoom(roomName).add(to: realm)
		
		let chatVC = ChatViewController.createWith(roomName: newRoom.name, name: myName)
		navigationController!.pushViewController(chatVC, animated: true)
  }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension RoomsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return roomNames?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let roomName = roomNames?[indexPath.row] else {
      fatalError()
    }

//    let isSynced = false
		let isSynced = realm?.object(ofType: ChatRoom.self, forPrimaryKey: roomName) != nil

    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RoomCell
    cell.configure(with: roomName, isSynced: isSynced)
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let room = roomNames?[indexPath.row], let myName = name.text else { return }

    tableView.deselectRow(at: indexPath, animated: true)
    view.endEditing(false)
    navigationController?.pushViewController(
      ChatViewController.createWith(roomName: room, name: myName), animated: true)
  }
}

extension RoomsViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}
