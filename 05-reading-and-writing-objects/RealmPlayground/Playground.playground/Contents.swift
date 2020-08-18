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

// setup
let realm = try! Realm(configuration:
  Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))
try! TestDataSet.create(in: realm)

print("Ready to play!")

Example.of("Getting All Objects") {
	let people = realm.objects(Person.self)
	let articles = realm.objects(Article.self)
	
	print("\(people.count) people and \(articles.count) articles")
}

Example.of("Getting an Object by Primary Key") {
	let person = realm.object(ofType: Person.self, forPrimaryKey: "test-key")
	
	if let person = person {
		print("Prson with Primary Key 'test-key': \(person.firstName)")
	} else {
		print("Not found")
	}
}

Example.of("Accessing Results") {
	let people = realm.objects(Person.self)
	
	print("Realm contains \(people.count) people")
	print("First person is: \(people.first!.fullName)")
	print("Second person is: \(people[1].fullName)")
	print("Last person is: \(people.last!.fullName)")
	
	let firstNames = people.map { $0.firstName }.joined(separator: ", ")
	print("First names of all people are: \(firstNames)")
	
	let namesAndIds = people.enumerated()
		.map { "\($0.offset): \($0.element.firstName)"}
		.joined(separator: ", ")
	print("People and indexes: \(namesAndIds)")
}

Example.of("Results Indexes") {
	let people = realm.objects(Person.self)
	let person = people[1]
	
	if let index1 = people.index(of: person) {
		print("\(person.fullName) is at index \(index1)")
	}
	
	if let index2 = people.firstIndex(where: { $0.firstName.starts(with: "J") }) {
		print("Name starts with J at index \(index2)")
	}
	
	if let index3 = people.index(matching: "hairCount < %d", 10000) {
		print("Person with less than 10,000 hairs at index \(index3)")
	}
	
}

extension Person {
	static let fieldHairCount = "hairCount"
	static let fieldDeceased = "deceased"
	
	static func allAliveLikelyBalding(`in` realm: Realm, hairThreshold: Int = 1000) -> Results<Person> {
		
		let predicate = NSPredicate(format: "%K < %d AND %K = nil", Person.fieldHairCount, hairThreshold, Person.fieldDeceased)
		return realm.objects(Person.self).filter(predicate)
	}
}

Example.of("Filtering") {
	let people = realm.objects(Person.self)
	print("All People: \(people.count)")
	
	let living = realm.objects(Person.self).filter("deceased = nil")
	print("Living People: \(living.count)")
	
	let predicate = NSPredicate(format: "hairCount < %d AND deceased = nil", 1000)
	let balding = realm.objects(Person.self).filter(predicate)
	print("Likely balding living people: \(balding.count)")
	
	let baldingStatic = Person.allAliveLikelyBalding(in: realm)
	print("Likely balding people (via static method): \(baldingStatic.count)")
	
}

Example.of("More Advanced Predicates") {
	let janesAndFranks = realm.objects(Person.self)
		.filter("firstName IN %@", ["Jane", "Frank"])
	
	print("There are \(janesAndFranks.count) people named Jane or Frank")
	
	let balding = realm.objects(Person.self)
		.filter("hairCount BETWEEN {%d, %d}", 10, 10000)
	print("There are \(balding.count) people likely balding")
	
	let search = realm.objects(Person.self)
	.filter("""
				firstName BEGINSWITH %@ OR
				(lastName CONTAINS %@ AND hairCount > %d)
			""", "J", "er", 10000)
	print(" There are \(search.count) people matching our search")
}

Example.of("Subqueries") {
	let articlesAboutFrank = realm.objects(Article.self).filter(
		"""
		title != nil AND
		people.@count > 0 AND
		SUBQUERY(people, $person,
		$person.firstName BEGINSWITH %@ AND
			$person.born > %@).@count > 0
		"""
		, "Frank", Date.distantPast)
	print("There are \(articlesAboutFrank.count) articles about frank")
}

Example.of("Sorting") {
	let sortedPeople = realm.objects(Person.self)
		.filter("firstName BEGINSWITH %@", "J")
		.sorted(byKeyPath: "firstName")
	
	let names = sortedPeople.map { $0.firstName }.joined(separator: ", ")
	print("Sorted people: \(names)")
	
	let sortedPeopleDesc = realm.objects(Person.self)
		.filter("firstName BEGINSWITH %@", "J")
		.sorted(byKeyPath: "firstName", ascending: false)
	
	let revNames = sortedPeopleDesc.map { $0.firstName }.joined(separator: ", ")
	print("Reverse-sorted People: \(revNames)")
	
	let sortedArticles = realm.objects(Article.self).sorted(byKeyPath: "author.firstName")
	print("Sorted articles by author: \n\(sortedArticles.map { "-\($0.author!.fullName): \($0.title!) "}.joined(separator: "\n") )")
	
	let sortedPeopleMultiple = realm.objects(Person.self).sorted(by: [
		SortDescriptor(keyPath: "firstName", ascending: true),
		SortDescriptor(keyPath: "born", ascending: false)
		])
	print(sortedPeopleMultiple.map { "\($0.firstName) @ \($0.born)" }.joined(separator: ", "))
	
}

Example.of("Live Results") {
	let people = realm.objects(Person.self)
		.filter("key == key")
	
	print("Found \(people.count) people for key \"key\"")
	
	let newPerson1 = Person()
	newPerson1.key = "key"
	
	try! realm.write {
		realm.add(newPerson1)
	}
	
	let newPerson2 = Person()
	newPerson2.key = "key"
	newPerson2.firstName = "Sher"
	//does not persist because it is not added to try! realm.write{ realm.add(newperson2)}
	
	print("Found \(people.count) people for key \"key\"")
	
}

Example.of("Cascading Inserts") {
	let newAuthor = Person()
	newAuthor.firstName = "New"
	newAuthor.lastName = "Author"
	
	let newArticle = Article()
	newArticle.author = newAuthor
	
	try! realm.write {
		realm.add(newArticle)
	}
	
	let author = realm.objects(Person.self).filter("firstName == 'New'").first!
	
	print("Author \"\(author.fullName)\" persisted with article")
	
}

Example.of("Updating") {
	let person = realm.objects(Person.self).first!
	print("\(person.fullName) initially - isVIP: \(person.isVIP), allowedPubliciation: \(person.allowedPublicationOn != nil ? "yes": "no")")
	
	try! realm.write {
		person.isVIP = true
		person.allowedPublicationOn = Date()
	}
	
	print("\(person.fullName) after update - isVIP: \(person.isVIP), allowedPubliciation: \(person.allowedPublicationOn != nil ? "yes": "no")")
}

Example.of("Deleting") {
	let people = realm.objects(Person.self)
	
	print("There are \(people.count) people before deletion: \(people.map { $0.firstName }.joined(separator: ", "))")
	
	try! realm.write {
		realm.delete(people[0])
		realm.delete([people[1], people[5]])
		realm.delete(realm.objects(Person.self).filter("firstName BEGINSWITH 'J'"))
	}
	
	print("There are \(people.count) people after deletion: \(people.map { $0.firstName }.joined(separator: ", "))")
	
	print("Empty before deleteAll? \(realm.isEmpty)")
	
//	try! realm.write {
//		realm.deleteAll()
//	}
//
//	print("Empty after deleteAll? \(realm.isEmpty)")
}

// MARK: - Callenge 1

Example.of("Challenge1") {

	//1
	print("Task1")
	let people = realm.objects(Person.self)
	let articles = realm.objects(Article.self)
	
	let author = Person(firstName: "Jaewoo", born: Date())
	let somePerson = Person(firstName: "Jim", born: Date())
	let article = Article()
	article.author = author
	article.people.append(somePerson)
	
	try! realm.write {
		realm.add(article)
	}
	print("peoples: \(people.count), articles: \(articles.count)")
	
	//2
	print("Task2")
	print(realm.objects(Article.self).filter("ANY people.firstName == 'Jim'"))
	
	//3
	print("Task3")
	print(realm.objects(Article.self).filter("NONE people.firstName == 'Jim'"))
	
	//4
	print("Task4")
	print(realm.objects(Article.self).filter("people.@count > 0"))
	
	//5
	print("Task5")
	print(realm.objects(Person.self).sorted(by: [
		SortDescriptor(keyPath: "hairCount", ascending: true),
		SortDescriptor(keyPath: "firstName", ascending: true)
		]))
	
	//6
	print("Task6")
	try! realm.write {
		for person in realm.objects(Person.self).filter("firstName == 'Jim'") {
			person.firstName = "John"
		}
	}
	
	print("Johns: \(realm.objects(Person.self).filter("firstName == 'John'").count)")
}
