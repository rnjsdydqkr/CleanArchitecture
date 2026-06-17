//
//  studyTests.swift
//  studyTests
//
//  Created by Park Kwonyong on 6/15/26.
//

import XCTest
@testable import study

final class studyTests: XCTestCase {
  var usecase: UserListUsecaseProtocol!
  var repository: UserRepositoryProtocol!
  override func setUp() {
    super.setUp()
    repository = MockUserRepository()
    usecase = UserListUsecase(repository: repository)
  }
  
  func testCheckFavoriteState() {
    let fetchUsers: [UserListItem] = [
      UserListItem(id: 1, login: "user1", imageURL: ""),
      UserListItem(id: 2, login: "user2", imageURL: ""),
      UserListItem(id: 3, login: "user3", imageURL: ""),
      UserListItem(id: 4, login: "user4", imageURL: ""),
      UserListItem(id: 5, login: "user5", imageURL: ""),
      UserListItem(id: 6, login: "user6", imageURL: "")
    ]
    
    let favoriteUsers = [
      UserListItem(id: 2, login: "user2", imageURL: ""),
      UserListItem(id: 5, login: "user5", imageURL: ""),
      UserListItem(id: 6, login: "user6", imageURL: "")
    ]
    let result = usecase.checkFavoriteState(fetchUsers: fetchUsers, favoriteUsers: favoriteUsers)
    
    XCTAssertEqual(result[2].isFavorite, false)
    XCTAssertEqual(result[4].isFavorite, true)
    XCTAssertEqual(result[5].isFavorite, true)
  }
  
  func testConvertListToDictionary() {
    let favoriteUsers = [
      UserListItem(id: 1, login: "user1", imageURL: ""),
      UserListItem(id: 2, login: "Blue2", imageURL: ""),
      UserListItem(id: 3, login: "Blue3", imageURL: ""),
      UserListItem(id: 4, login: "player4", imageURL: ""),
      UserListItem(id: 5, login: "User5", imageURL: ""),
      UserListItem(id: 6, login: "player6", imageURL: "")
    ]
    
    let result = usecase.convertListToDictionary(favoriteUsers: favoriteUsers) // [String: [UserListItem]]
    XCTAssertEqual(result.keys.count, 3)
    XCTAssertEqual(result["B"]?.count, 2)
    XCTAssertEqual(result["P"]?.count, 2)
    XCTAssertEqual(result["U"]?.count, 2)
  }
  
  override func tearDown() {
    repository = nil
    usecase = nil
    super.tearDown()
  }

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//        // XCTest Documentation
//        // https://developer.apple.com/documentation/xctest
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
