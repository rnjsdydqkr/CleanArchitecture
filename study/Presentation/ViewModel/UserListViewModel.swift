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
    input.query.bind { query in // 유저가 텍스트 필드에 입력
      //TODO: 상황에 맞춰서 user fetch and get favorite users
    }.disposed(by: dispossBag)
    
    input.saveFavorite.bind { user in
      //TODO: 즐겨찾기 추가
    }.disposed(by: dispossBag)
    
    input.deleteFavorite.bind { userId in
      //TODO: 즐겨찾기 삭제
    }.disposed(by: dispossBag)
    
    input.fetchMore.bind {
      //TODO: 다음 페이지 검색
    }.disposed(by: dispossBag)
    
    // 탭 -> api 유저 or 즐겨찾기 유저
    let cellData: Observable<[UserListCellData]> = Observable.combineLatest(input.tabButtonTypes, fetchUserList, favoriteUserList).map { tabButtonType, fetchUserList, favoriteUserList in
      let cellData: [UserListCellData] = []
      //TODO: cellData 생성
      return cellData
    }
    return Output(cellData: cellData, error: error.asObservable())
    
  }
  
//  private func fetchUser(query: String, page: Int) {
//    Task {
//      await usecase.fetchUser(query: query, page: page)
//    }
//  }
}

public enum TabButtonType {
  case api
  case favorite
}

public enum UserListCellData {
  case user(user: UserListItem, isFavorite: Bool)
  case header(String)
}
