//
//  UserListViewModel.swift
//  study
//
//  Created by Park Kwonyong on 6/17/26.
//

import Foundation
import RxSwift
import RxCocoa

protocol UserListViewModelProtocol {
  
}

/***
 Publish: 내부적으로 값을 접근할 필요 없는 경우
 Behavior: 내부적으로 값을 접근해야 하는 경우
 
 Subject: 에러 타입 던저줄 경우 많이 사용
 Relay: 메인쓰레드에서 동작 VC에게 데이터 전달 용일 경우, 에러가 없는 경우
*/

public final class UserListViewModel: UserListViewModelProtocol {
  private let usecase: UserListUsecaseProtocol
  private let dispossBag = DisposeBag()
  private let error = PublishRelay<String>()
  private let fetchUserList = BehaviorSubject<[UserListItem]>(value: [])
  private let allFavoriteUserList = BehaviorSubject<[UserListItem]>(value: []) // 즐겨찾기 표시를 위해, fetchUser 즐겨찾기 포함 여부를 알기위해 전체목록 필요
  private let favoriteUserList = BehaviorSubject<[UserListItem]>(value: []) // 목록에 보여줄 리스트
  private var page: Int = 1
  
  public init(usecase: UserListUsecaseProtocol) {
    self.usecase = usecase
  }
  
  // 이벤트(VC) -> 가공 or 외부에서 데이터 호출 or 뷰 데이터를 전달 (VM) -> VC
  public struct Input { // VM에게 전달 되어야 할 이벤트
    // 탭, 텍스트필드, 즐겨찾기 추가 or 삭제, 페이지네이션, Observable
    let tabButtonTypes: Observable<TabButtonType>
    let query: Observable<String>
    let saveFavorite: Observable<UserListItem>
    let deleteFavorite: Observable<Int>
    let fetchMore: Observable<Void>
  }
  public struct Output { // VC 에게 전달될 뷰 데이터
    let cellData: Observable<[UserListCellData]>
    let error: Observable<String>
  }
  
  // 상단 텍스트필드
  // 하단 API명/ 즐겨찾기명
  
  public func transform(input: Input) -> Output {
    input.query.bind { [weak self] query in // 유저가 텍스트 필드에 입력
      //TODO: 상황에 맞춰서 user fetch and get favorite users
      guard let self, validateQuery(query: query) else {
        //FIXME: 빈 값일 경우 fetchUser는 처리 안해줘도 되나?
        self?.getFavoriteUsers(query: "")
        return
      }
      page = 1
      fetchUser(query: query, page: page)
      getFavoriteUsers(query: query)
    }.disposed(by: dispossBag)
    
    input.saveFavorite
      .withLatestFrom(input.query, resultSelector: { users, query in
        return (users, query)
      })
      .bind { [weak self] user, query in
      //TODO: 즐겨찾기 추가
      self?.saveFavoriteUser(user: user, query: query)
    }.disposed(by: dispossBag)
    
    input.deleteFavorite
      .withLatestFrom(input.query, resultSelector: { ($0, $1) })
      .bind { [weak self] userId, query in
      //TODO: 즐겨찾기 삭제
        self?.deleteFavoriteUser(userId: userId, query: query)
    }.disposed(by: dispossBag)
    
    input.fetchMore
      .withLatestFrom(input.query)
      .bind { [weak self] query in
      //TODO: 다음 페이지 검색
        guard let self else { return }
        page += 1
        fetchUser(query: query, page: page)
    }.disposed(by: dispossBag)
    
    // 탭 -> api 유저 or 즐겨찾기 유저
    let cellData: Observable<[UserListCellData]> = Observable.combineLatest(input.tabButtonTypes, fetchUserList, favoriteUserList, allFavoriteUserList).map { [weak self] tabButtonType, fetchUserList, favoriteUserList, allFavoriteUserList in
      var cellData: [UserListCellData] = []
      guard let self else { return cellData }
      //TODO: cellData 생성
      // Tab 타입에 따라 fetchUser List or favoriteUser List
      switch tabButtonType {
      case .api: // fetchUser List
        let tuple = usecase.checkFavoriteState(fetchUsers: fetchUserList, favoriteUsers: allFavoriteUserList)
        let userCellList = tuple.map { (user, isFavorite) in
          UserListCellData.user(user: user, isFavorite: isFavorite)
        }
        return userCellList
      case .favorite: // favoriteUser List
        let dict = usecase.convertListToDictionary(favoriteUsers: favoriteUserList)
        let keys = dict.keys.sorted()
        keys.forEach { key in
          cellData.append(.header(key))
          if let users = dict[key] {
            let userListCell = users.map { user in
              UserListCellData.user(user: user, isFavorite: true)
            }
            cellData += userListCell
          }
        }
      }
      return cellData
    }
    return Output(cellData: cellData, error: error.asObservable())
    
  }
  
  private func fetchUser(query: String, page: Int) {
    guard let urlAllowedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
    Task {
      let result = await usecase.fetchUser(query: urlAllowedQuery, page: page)
      switch result {
      case .success(let users):
        if page == 0 {
          // 첫번째 페이지
          fetchUserList.onNext(users.items)
        } else {
          // 두번째 그이상 페이지
          do {
            fetchUserList.onNext(try fetchUserList.value() + users.items)
          } catch {
            self.error.accept(error.localizedDescription)
          }
        }
      case .failure(let error):
        self.error.accept(error.description)
      }
    }
  }
  
  private func getFavoriteUsers(query: String) {
    let result = usecase.getFavoriteUsers()
    switch result {
    case .success(let users):
      if query.isEmpty {
        // 전체 리스트
        favoriteUserList.onNext(users)
      } else {
        // 검색했을 때 필터링
        let filteredUsers = users.filter { user in
          user.login.contains(query)
        }
        favoriteUserList.onNext(filteredUsers)
      }
      allFavoriteUserList.onNext(users)
    case .failure(let error):
      self.error.accept(error.description)
    }
  }
  
  private func saveFavoriteUser(user: UserListItem, query: String) {
    let result = usecase.saveFavorite(user: user)
    switch result {
    case .success:
      getFavoriteUsers(query: query)
    case .failure(let error):
      self.error.accept(error.description)
    }
  }
  
  private func deleteFavoriteUser(userId: Int, query: String) {
    let result = usecase.deleteFavoriteUser(userId: userId)
    switch result {
    case .success:
      getFavoriteUsers(query: query)
    case .failure(let error):
      self.error.accept(error.description)
    }
  }
  
  private func validateQuery(query: String) -> Bool {
    if query.isEmpty {
      return false
    } else {
      return true
    }
  }
  
}

public enum TabButtonType {
  case api
  case favorite
}

public enum UserListCellData {
  case user(user: UserListItem, isFavorite: Bool)
  case header(String)
}
