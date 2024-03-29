//
//  UsersListViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.02.2024.
//

import StackNinja

final class UsersListViewModel<Design: DSP>: VStackModel, Designable, ActivityViewModelProtocol {

   private(set) lazy var activityBlock = ActivityViewModel<Design>()

   private(set) lazy var usersTableModel = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         UserCellPresenter<Design>.presenter
      )
      .footerModel(Spacer(64))

   override func start() {
      super.start()

      arrangedModels([
         activityBlock,
         usersTableModel
      ])

      activityState(.loading)
   }
}

extension UsersListViewModel: SetupProtocol {
   func setup(_ data: [UserViewModelState]) {
      if data.isEmpty {
         activityState(.empty)
      } else {
         activityState(.hidden)
      }
      usersTableModel.items(data)
   }
}
