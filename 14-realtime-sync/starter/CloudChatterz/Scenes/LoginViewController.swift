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

class LoginViewController: UITableViewController {

  // MARK: - outlets

  @IBOutlet private var serverUrl: UITextField!
  @IBOutlet private var serverUser: UITextField!
  @IBOutlet private var serverPass: UITextField!

  @IBOutlet private var loginButton: UIButton!
  @IBOutlet private var spinner: UIActivityIndicatorView!
  @IBOutlet private var errorMessage: UILabel!

  // MARK: - properties

  private var isLoginInProgress = false

  // MARK: - view controller life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    serverUrl.text = RealmProvider.ServerConfig.host
    serverUser.text = RealmProvider.ServerConfig.user
    serverPass.text = RealmProvider.ServerConfig.password

    errorMessage.text = nil
    spinner.stopAnimating()
    view.backgroundColor = UIColor(patternImage: UIImage(named: "bg-pattern")!)
  }

  // MARK: - actions

  @IBAction func login(_ sender: Any) {
    guard !isLoginInProgress,
      let user = serverUser.text,
      let pass = serverPass.text,
      let url = serverUrl.text,
      let server = URL(string: "https://\(url)") else { return }

    view.endEditing(false)
    spinner.startAnimating()
		
		let credentials = SyncCredentials.usernamePassword(username: user, password: pass)
		
//		SyncUser.logIn(with: credentials,
//									 server: server,
//									 timeout: 5.0,
//									 callbackQueue: DispatchQueue.main) { [weak self](user, error) in
//										self?.serverDidRespond(user: user, error: error)
//		}
		
		SyncUser.logIn(with: credentials, server: server, timeout: 5.0) { [weak self] user, error in
			self?.serverDidRespond(user: user, error: error)
		}
		

  }

  private func serverDidRespond(user: SyncUser?, error: Error?) {
    spinner.stopAnimating()

    if let error = error {
      errorMessage.text = error.localizedDescription
      return
    }

    if user != nil {
      navigationController?.pushViewController(
        storyboard!.instantiateViewController(RoomsViewController.self), animated: true)
    }
  }
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}
