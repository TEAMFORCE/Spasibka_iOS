//
//  ChallengeSmallCellPresenter.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.09.2023.
//

import StackNinja

final class ChallengeSmallCellPresenter<Design: DSP>: Eventable {
   struct Events: InitProtocol {
      var didSelectItemAtIndex: Int?
   }
   
   var events = EventsStore()
   
   var presenter: CellPresenterWork<ChainCellData, StackModel> { .init { [weak self] work in
      let cellIndex = work.in.indexPath.row
      let items = work.in.item.itemsPair
      
      var subCells: [UIViewModel] = items.enumerated().map { index, item in
         let model = ChallengeSmallViewModel<Design>()
            .backColor(Design.color.background)
         
         model.setStates(.init(
            imageUrl: SpasibkaEndpoints.tryConvertToImageUrl(item.photos?.first),
            imagePlaceHolder: Design.icon.challengeWinnerIllustrateFull,
            title: item.name.unwrap,
            body: Design.text.from + " \(item.creatorSurname.unwrap) \(item.creatorName.unwrap)",
            prizeCaption: Design.text.reward,
            prizeImage: Design.icon.smallLogo.withTintColor(Design.color.iconBrand),
            prizeText: item.prizeSize.toString,
            status: ChallengeNewCellStatus(withChallCondition: item.challengeCondition)
         ))
         .backColor(Design.color.background)
         .cornerCurve(.continuous)
         .cornerRadius(Design.params.cornerRadiusSmall)
         .shadow(Design.params.cellShadow)
         .view
         .startTapGestureRecognize()
         .on(\.didTap) {
            let realIndex = cellIndex * 2 + index
            self?.send(\.didSelectItemAtIndex, realIndex)
         }
         
         return model
      }
      if subCells.count == 1 {
         subCells.append(ViewModel())
      }
      
      let cell = HStackModel()
         .spacing(10.5)
         .distribution(.fillEqually)
         .arrangedModels(subCells)
         .padHorizontal(16)
         .padVertical(10.5 / 2)
         .setNeedsStoreModelInView()
      
      work.success(cell)
   }}
}
