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

// XCTestCase 를 상속해야 테스트 러너가 test~ 메서드를 찾아 실행한다.
// XCTest 는 추상 베이스 클래스라 상속해도 컴파일만 될 뿐 아무것도 실행되지 않는다.
final class UserListViewModelTests: XCTestCase {

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
    // given: Mock 이 돌려줄 응답을 먼저 준비한다
    let userList = [
      UserListItem(id: 1, login: "user1", imageURL: ""),
      UserListItem(id: 2, login: "user2", imageURL: ""),
      UserListItem(id: 3, login: "user3", imageURL: "")
    ]
    mockUsecase.fetchUserResult = .success(UserListResult(totalCount: 3, incompleteResults: false, items: userList))

    // when: 구독을 "먼저" 걸어둔다.
    // transform 직후 combineLatest 가 초기값([])을 흘리므로 filter 로 걸러내고,
    // take(1) 로 의미 있는 첫 방출만 받은 뒤 expectation 을 채운다.
    let output = viewModel.transform(input: input)

    let exp = expectation(description: "API 유저 목록이 cellData 로 방출된다")
    var result: [UserListCellData] = []
    output.cellData
      .filter { !$0.isEmpty }
      .take(1)
      .subscribe(onNext: { cellData in
        result = cellData
        exp.fulfill()
      })
      .disposed(by: disposeBag)

    // 구독을 건 "다음에" 입력을 흘린다. fetchUser 는 Task 안에서 비동기로 돌기 때문에
    // wait 로 런루프를 돌려 결과가 도착할 때까지 기다려야 한다.
    query.accept("user")
    wait(for: [exp], timeout: 1.0)

    // then
    XCTAssertEqual(result.count, 3)
    guard case let .user(userItem, isFavorite) = result.first else {
      return XCTFail("Cell Data user cell 아님")
    }
    XCTAssertEqual(userItem.login, "user1")
    XCTAssertFalse(isFavorite, "즐겨찾기 목록이 비어 있으므로 false 여야 한다")
  }

  // 즐겨찾기 결과 Cell data로 잘 나오는지 테스트
  func testFavoriteUserCelldata() {
    // given
    let userList = [
      UserListItem(id: 1, login: "Ash", imageURL: ""),
      UserListItem(id: 2, login: "Brown", imageURL: ""),
      UserListItem(id: 3, login: "Brad", imageURL: "")
    ]
    mockUsecase.favoriteUserResult = .success(userList)

    // when
    let output = viewModel.transform(input: input)

    let exp = expectation(description: "즐겨찾기 목록이 헤더 + 유저 cellData 로 방출된다")
    var result: [UserListCellData] = []
    output.cellData
      .filter { !$0.isEmpty }
      .take(1)
      .subscribe(onNext: { cellData in
        result = cellData
        exp.fulfill()
      })
      .disposed(by: disposeBag)

    tabButtonType.accept(.favorite)
    wait(for: [exp], timeout: 1.0)

    // then: [헤더 A, Ash, 헤더 B, Brown, Brad] 순서여야 한다
    XCTAssertEqual(result.count, 5)

    guard case let .header(key) = result.first else {
      return XCTFail("Cell data header cell 아님")
    }
    XCTAssertEqual(key, "A")

    guard case let .user(userItem, isFavorite) = result[1] else {
      return XCTFail("Cell data user cell 아님")
    }
    XCTAssertEqual(userItem.login, "Ash")
    XCTAssertTrue(isFavorite)
  }

  // MARK: - 검색어 인코딩

  // VM 은 검색어를 "그대로" usecase 에 넘겨야 한다.
  // 퍼센트 인코딩은 Alamofire(URLEncoding.queryString) 가 담당하므로,
  // VM 에서 미리 인코딩하면 "%" 가 다시 "%25" 로 인코딩되는 이중 인코딩이 발생한다.
  func testQueryIsPassedToUsecaseWithoutPreEncoding() {
    // given
    mockUsecase.fetchUserResult = .success(UserListResult(totalCount: 0, incompleteResults: false, items: []))

    // fetchUser 는 Task 안에서 비동기로 호출되므로 Spy 훅으로 호출 시점을 기다린다
    let exp = expectation(description: "usecase.fetchUser 가 호출된다")
    mockUsecase.onFetchUser = { _, _ in exp.fulfill() }

    // when
    _ = viewModel.transform(input: input)
    query.accept("kwon yong")
    wait(for: [exp], timeout: 1.0)

    // then
    XCTAssertEqual(
      mockUsecase.receivedQueries.last, "kwon yong",
      "VM 이 미리 퍼센트 인코딩하면 Alamofire 가 다시 인코딩해 'kwon%2520yong' 이 전송된다"
    )
  }

  // MARK: - 즐겨찾기 검색 필터

  // 즐겨찾기 검색은 대소문자를 구분하지 않아야 한다.
  // 즐겨찾기 경로(usecase.getFavoriteUsers)는 전부 동기라 expectation 없이
  // 최신 방출값만 붙잡아 두면 된다.
  func testFavoriteSearchIsCaseInsensitive() {
    // given
    mockUsecase.favoriteUserResult = .success([
      UserListItem(id: 1, login: "Ash", imageURL: ""),
      UserListItem(id: 2, login: "Brown", imageURL: "")
    ])
    tabButtonType.accept(.favorite)

    // when
    let output = viewModel.transform(input: input)
    var latest: [UserListCellData] = []
    output.cellData
      .subscribe(onNext: { latest = $0 })
      .disposed(by: disposeBag)

    query.accept("Ash")   // 저장된 login 과 대소문자가 같지만, 코드가 query 만 소문자로 바꾼다

    // then
    let logins: [String] = latest.compactMap {
      if case let .user(user, _) = $0 { return user.login }
      return nil
    }
    XCTAssertEqual(logins, ["Ash"], "대문자로 검색해도 login 'Ash' 가 매칭되어야 한다")
  }

  // MARK: - 페이지네이션 가드
  //
  // 여기서는 "요청이 일어나지 않아야 한다"를 검증해야 한다.
  // expectation.isInverted = true 로 두면 채워지는 순간 테스트가 실패하므로,
  // 가드가 잘못 뚫렸을 때 정확히 잡아낼 수 있다.
  // (Task 가 늦게 호출할 수도 있으므로 짧게 기다려 줄 시간도 필요하다)

  /// 첫 페이지를 받아 놓은 상태까지 진행시키는 공통 준비 단계
  private func loadFirstPage(totalCount: Int, itemCount: Int) {
    let items = (1...itemCount).map {
      UserListItem(id: $0, login: "user\($0)", imageURL: "")
    }
    mockUsecase.fetchUserResult = .success(
      UserListResult(totalCount: totalCount, incompleteResults: false, items: items)
    )
    mockUsecase.favoriteUserResult = .success([])

    let firstPage = expectation(description: "첫 페이지 요청 완료")
    mockUsecase.onFetchUser = { _, _ in firstPage.fulfill() }

    _ = viewModel.transform(input: input)
    query.accept("user")
    wait(for: [firstPage], timeout: 1.0)
  }

  // Favorite 탭은 로컬 목록이라 페이징 대상이 아니다
  func testFetchMoreIsIgnoredOnFavoriteTab() {
    // given: 아직 받을 게 남아 있는 상태(전체 100건 중 1건만 로드)
    loadFirstPage(totalCount: 100, itemCount: 1)

    // when
    let noMoreCall = expectation(description: "Favorite 탭에서는 추가 요청이 없어야 한다")
    noMoreCall.isInverted = true
    mockUsecase.onFetchUser = { _, _ in noMoreCall.fulfill() }

    tabButtonType.accept(.favorite)
    fetchMore.accept(())

    // then
    wait(for: [noMoreCall], timeout: 0.3)
  }

  // 빈 쿼리로 요청하면 GitHub 가 422 를 응답한다
  func testFetchMoreIsIgnoredWhenQueryIsEmpty() {
    // given: query 는 초기값 "" 그대로 둔다
    mockUsecase.favoriteUserResult = .success([])

    let noCall = expectation(description: "빈 쿼리에서는 요청이 없어야 한다")
    noCall.isInverted = true
    mockUsecase.onFetchUser = { _, _ in noCall.fulfill() }

    // when
    _ = viewModel.transform(input: input)
    fetchMore.accept(())

    // then
    wait(for: [noCall], timeout: 0.3)
  }

  // totalCount 만큼 다 받았으면 더 요청하지 않는다
  func testFetchMoreStopsWhenAllResultsAreLoaded() {
    // given: 전체가 1건이고 그 1건을 이미 받은 상태
    loadFirstPage(totalCount: 1, itemCount: 1)

    // when
    let noMoreCall = expectation(description: "끝에 도달하면 추가 요청이 없어야 한다")
    noMoreCall.isInverted = true
    mockUsecase.onFetchUser = { _, _ in noMoreCall.fulfill() }

    fetchMore.accept(())

    // then
    wait(for: [noMoreCall], timeout: 0.3)
  }

  override func tearDown() {
    viewModel = nil
    mockUsecase = nil
    disposeBag = nil
    tabButtonType = nil
    query = nil
    saveFavorite = nil
    deleteFavorite = nil
    fetchMore = nil
    input = nil
    super.tearDown()
  }
}
