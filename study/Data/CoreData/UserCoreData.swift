//
//  CoreData.swift
//  study
//
//  Created by Park Kwonyong on 6/16/26.
//

import Foundation
import CoreData

public protocol UserCoreDataProtocol {
  func getFavoriteUsers() -> Result<[UserListItem], CoreDataError> // 전체 즐겨찾기 리스트 불러오기
  func saveFavorite(user: UserListItem) -> Result<Bool, CoreDataError>
  func deleteFavoriteUser(userId: Int) -> Result<Bool, CoreDataError>
}

public struct UserCoreData: UserCoreDataProtocol {
  private let viewContext: NSManagedObjectContext
  init(viewContext: NSManagedObjectContext) {
    self.viewContext = viewContext
  }
  public func getFavoriteUsers() -> Result<[UserListItem], CoreDataError> {
    let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
    do {
      let result = try viewContext.fetch(fetchRequest)
      let userList: [UserListItem] = result.compactMap { favoriteUser in
        guard let login = favoriteUser.login, let imageURL = favoriteUser.imageURL else { return nil }
        return UserListItem(id: Int(favoriteUser.id), login: login, imageURL: imageURL)
      }
      return .success(userList)
    } catch {
      return .failure(.readError(error.localizedDescription))
    }
  }
  
  public func saveFavorite(user: UserListItem) -> Result<Bool, CoreDataError> {
    let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %d", user.id)
    fetchRequest.fetchLimit = 1
    do {
      let favoriteUser = try viewContext.fetch(fetchRequest).first
        ?? FavoriteUser(context: viewContext)
      favoriteUser.id = Int64(user.id)
      favoriteUser.login = user.login
      favoriteUser.imageURL = user.imageURL
      try viewContext.save()
      return .success(true)
    } catch {
      return .failure(.saveError(error.localizedDescription))
    }
  }
  
  public func deleteFavoriteUser(userId: Int) -> Result<Bool, CoreDataError> {
    let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %d", userId)
    do {
      let result = try viewContext.fetch(fetchRequest)
      result.forEach { favoriteUser in
        viewContext.delete(favoriteUser)
      }
      try viewContext.save()
      return .success(true)
    } catch {
      return .failure(.deleteError(error.localizedDescription))
    }
  }
  
  
}
