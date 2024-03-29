//
//  FeedCommentsBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.10.2022.
//

import StackNinja

enum FeedCommentsState {
   case presentComments([Comment])
   case sendButtonDisabled
   case sendButtonEnabled
}

final class CommentsViewModel<Design: DSP>: BodyFooterStackModel, Designable, ActivityViewModelProtocol {
   
   private(set) lazy var activityBlock = ActivityViewModel<Design>()
   
   lazy var presenter = CommentPresenters<Design>()
   
   private(set) lazy var commentTableModel = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         presenter.commentCellPresenter
      )
      .footerModel(Spacer(64))
      .deleteModeOn(true)
      .setNeedsLayoutWhenContentChanged()
   
   var commentPanelModel = WrappedX<M<TextFieldModel>.R<ButtonSelfModable>.Ninja>()
      .padding(.bottom(12))
      .spacing(20)
      .setup {
         $0.subModel
            .setAll { textField, button in
               textField
                  .placeholder(Design.text.comment)
                  .placeholderColor(Design.color.textContrastSecondary)
                  .font(Design.font.descriptionRegular14)
                  .textColor(Design.color.text)
                  
               button
                  .backImage(Design.icon.chatCircle.resized(to: .square(24)))
                  .size(.square(24))
                  .onModeChanged(\.inactive) {
                     $0.set(Design.state.button.inactiveComment)
                  }
                  .onModeChanged(\.normal) {
                     $0.set(Design.state.button.defaultComment)
                  }
                  .setMode(\.inactive)
            }
            .height(48)
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            .borderColor(Design.color.iconMidpoint)
            .borderWidth(1)
            .padding(.outline(12))
      }

   override func start() {
      super.start()

      bodyStack.arrangedModels([
         activityBlock,
         commentTableModel,
         Spacer()
      ])

      footerStack.arrangedModels([
         commentPanelModel.padHorizontal(16)
      ])
      
      activityState(.loading)
   }
}

extension CommentsViewModel: StateMachine {
   func setState(_ state: FeedCommentsState) {
      switch state {
      case let .presentComments(comments):
         if comments.isNotEmpty {
            activityState(.hidden)
         } else {
            activityState(.firstComment)
         }
         let deletableValues = getDeletableValues(comments)
         commentTableModel
            .deletableValues(deletableValues)
            .items(comments)
      case .sendButtonDisabled:
         commentPanelModel.subModel.models.right.setMode(\.inactive)
      case .sendButtonEnabled:
         commentPanelModel.subModel.models.right.setMode(\.normal)
      }
   }
}

extension CommentsViewModel {
   private func getDeletableValues(_ comments: [Comment]) -> [Bool] {
      let result = comments.map { $0.canDelete ?? false }
      return result
   }
}
