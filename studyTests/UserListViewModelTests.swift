//
//  UserListViewModelTests.swift
//  studyTests
//
//  Created by Park Kwonyong on 6/23/26.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
@testable import study

final class UserListViewModelTests: XCTest {
  
  private var viewModel: UserListViewModel!
  private var mockUsecase: MockUserUsecase!
  private var disposeBag: DisposeBag!
  private var tabButtonType: BehaviorRelay<TabButtonType>!
  private var query: BehaviorRelay<String>!
  private var saveFavorite: PublishRelay<UserListItem>!
  private var deleteFavorite: PublishRelay<Int>!
  private var fetchMore: PublishRelay<Void>!
  private var input: UserListViewModel.Input!
  
  override func setUp() {
    super.setUp()
    mockUsecase = MockUserUsecase()
    viewModel = UserListViewModel(usecase: mockUsecase)
    disposeBag = DisposeBag()
    tabButtonType = BehaviorRelay<TabButtonType>(value: .api)
    query = BehaviorRelay<String>(value: "")
    saveFavorite = PublishRelay<UserListItem>()
    deleteFavorite = PublishRelay<Int>()
    fetchMore = PublishRelay<Void>()
    
    input = UserListViewModel.Input(
      tabButtonTypes: tabButtonType.asObservable(),
      query: query.asObservable(),
      saveFavorite: saveFavorite.asObservable(),
      deleteFavorite: deleteFavorite.asObservable(),
      fetchMore: fetchMore.asObservable()
    )
    
  }
  
  // 쿼리 결과 cell data로 잘 나오는지 테스트
  func testFetchUserCellData() {
    let userList = [
      UserListItem(id: 1, login: "user1", imageURL: ""),
      UserListItem(id: 2, login: "user2", imageURL: ""),
      UserListItem(id: 3, login: "user3", imageURL: "")
    ]
    mockUsecase.fetchUserResult = .success(UserListResult(totalCount: 3, incompleteResults: false, items: userList))
    
    let output = viewModel.transform(input: input)
    query.accept("user")
    
    var result: [UserListCellData] = []
    output.cellData.bind { cellData in
      result = cellData
    }.disposed(by: disposeBag)
    
    if case .user(let userItem, _) = result.first {
      XCTAssertEqual(userItem.login, "user1")
    } else {
      XCTFail("Cell Data user cell 아님")
    }
  }
  
  // 즐겨찾기 결과 Cell data로 잘 나오는지 테스트
  func testFavoriteUserCelldata() {
    let userList = [
      UserListItem(id: 1, login: "Ash", imageURL: ""),
      UserListItem(id: 2, login: "Brown", imageURL: ""),
      UserListItem(id: 3, login: "Brad", imageURL: "")
    ]
    mockUsecase.favoriteUserResult = .success(userList)
    
    let output = viewModel.transform(input: input)
    tabButtonType.accept(.favorite)
    
    var result: [UserListCellData] = []
    output.cellData.bind { cellData in
      result = cellData
    }.disposed(by: disposeBag)
    
    if case let .header(key) = result.first {
      XCTAssertEqual(key, "A")
    } else {
      XCTFail("Cell data header cell 아님")
    }
    
    if case .user(let userItem, let isFavorite) = result[1] {
      XCTAssertEqual(userItem.login, "Ash")
      XCTAssertTrue(isFavorite)
    } else {
      XCTFail("Cell data user cell 아님")
    }
  }
  
  override func tearDown() {
    viewModel = nil
    mockUsecase = nil
    disposeBag = nil
    super.tearDown()
  }
}
