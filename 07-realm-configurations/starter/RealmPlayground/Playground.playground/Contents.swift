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

import RealmSwift
import Foundation

print("Ready to play!")

// Default Configuration Options

Example.of("New Configuration") {
	let newConfig = Realm.Configuration()
	print(newConfig)
}

Example.of("Default Configuration") {
	let defaultConfig = Realm.Configuration.defaultConfiguration
	print(defaultConfig)
	
	//Opening Realm
//	let realm = try! Realm()
}

Example.of("Changing Schema Version?") {
	//When you release next version of your app, you want to change the default schema from 0 to 1
	
//	var config = Realm.Configuration.defaultConfiguration
//	config.schemaVersion = 1
//	Realm.Configuration.defaultConfiguration = config
	
//	let realm = try! Realm()
}

//In-memory Realms

Example.of("In-Memory Configuration") {
	let memoryConfig1 = Realm.Configuration(inMemoryIdentifier: "InMemoryRealm1")
	print(memoryConfig1)
	
	let memoryConfig2 = Realm.Configuration(inMemoryIdentifier: "InMemoryRealm2")
	print(memoryConfig2)
	
	let realm1 = try! Realm(configuration: memoryConfig1)
	let people1 = realm1.objects(Person.self)
	
	try! realm1.write {
		realm1.add(Person())
	}
	//When adding/modifying objects in a Realm, you always have to use a write transaction - whether it's an in-memory Realm or one persisted on disk
	print("People (1): \(people1.count)")
	
	let realm2 = try! Realm(configuration: memoryConfig2)
	let people2 = realm2.objects(Person.self)
	print("People (2): \(people2.count)")
	
}

//Realms in a custom location

Example.of("Documents Folder Configuration") {
	let documentsUrl = try! FileManager.default
		.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
		.appendingPathComponent("myRealm.realm")
	
	let documentsConfig = Realm.Configuration(fileURL: documentsUrl)
	print("Documents-folder Realm in: \(documentsConfig.fileURL!)")
}

Example.of("Library Folder Configuration") {
	let libraryUrl = try! FileManager.default
		.url(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
		.appendingPathComponent("myRealm.realm")
	
	let libraryConfig = Realm.Configuration(fileURL: libraryUrl)
	print("Realm in Library folder: \(libraryConfig.fileURL!)")
}

Example.of("App Bundle Folder") {
	//If you have a Realm file bundled with your app and want to open it and fetch some of its stored objects, you can use the Bundle class to access the app's resources folder. app's bundle is read-only!!!!!!!! You can't add new files to it or modify existing ones!
	
//	let bundledURL = Bundle.main.url(forResource: "bundledRealm", withExtension: "realm")
//	let bundleConfig = Realm.Configuration(fileURL: bundledURL)
}

Example.of("Shared container") {
	//can't try this in playground as well. common location for storing Realm files is a folder shared between your iOS app and one of its extensions.
	
//	let sharedURL = FileManager.default
//		.containerURL(forSecurityApplicationGroupIdentifier: "group.com.razeware.app")!
//		.appendingPathComponent("Library/shared.realm")
//	let sharedConfig = Realm.Configuration(fileURL: sharedURL)
}

Example.of("Encrypted realms") {
//	var cryptoConfig = Realm.Configuration()
//	do {
//		cryptoConfig.encryptionKey = Data()
//		let cryptoRealm = try Realm(configuration: cryptoConfig)
//		print(cryptoConfig)
//	} catch let error as NSError {
//		print("Opening file failed: \(error.localizedDescription)")
//	}
}

//Read-only Realms
Example.of("Read-only Realm") {
	let rwUrl = try! FileManager.default
		.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
		.appendingPathComponent("newFile.realm")
	
	let rwConfig = Realm.Configuration(fileURL: rwUrl)
	
	autoreleasepool {
		let rwRealm = try! Realm(configuration: rwConfig)
		try! rwRealm.write {
			rwRealm.add(Person())
		}
		print("Regular Realm, is Read Only?: \(rwRealm.configuration.readOnly)")
		print("Saved objects: \(rwRealm.objects(Person.self).count)\n")
	}
	
	autoreleasepool {
		let roConfig = Realm.Configuration(fileURL: rwUrl, readOnly: true)
		
		let roRealm = try! Realm(configuration: roConfig)
		print("Read-Only Realm, is Read Only?: \(roRealm.configuration.readOnly)")
		print("Read objects: \(roRealm.objects(Person.self).count)")
	}
	
}

//Object schema
Example.of("Object Schema - Entire Realm") {
	let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "Realm"))
	
	print(realm.schema.objectSchema)
}

Example.of("Object Schema - Specific Object") {
	let config = Realm.Configuration(inMemoryIdentifier: "Realm2", objectTypes: [Person.self])
	
	let realm = try! Realm(configuration: config)
	print(realm.schema.objectSchema)
}
