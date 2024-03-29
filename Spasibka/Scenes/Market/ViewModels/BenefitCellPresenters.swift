//
//  BenefitCellPresenters.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 13.01.2023.
//

import StackNinja


struct BenefitCellEvent: InitProtocol {
   var cellPressed: Int?
}


final class BenefitCellPresenters<Design: DSP>: Designable, Eventable {
   typealias Events = BenefitCellEvent
   var events: EventsStore = .init()
   
   var pairPresenter: CellPresenterWork<[Benefit], HStackModel> { .init { work in
      let items = work.unsafeInput.item
      
      let lineStackModels = items.map { item in
         
         let newBenefitCell = NewBenefitCell<Design>()
         newBenefitCell.benefitName.text(item.name.unwrap)
         newBenefitCell.priceModel.label.text(item.price?.priceInThanks.unwrap.toString ?? "")
         if let benefitImageUrl = item.images?.first?.link {
            newBenefitCell.icon.indirectUrl(SpasibkaEndpoints.urlBase + benefitImageUrl)
         }
         newBenefitCell.on(\.cellPressed, self) { slf, _ in
            slf.send(\.cellPressed, item.id)
         }
         let cellStack = WrappedX(newBenefitCell)
         
         return cellStack
      }
      let lineStack = HStackModel(lineStackModels)
         .spacing(15)
         .distribution(.fillEqually)
         .padBottom(15)

      work.success(lineStack)
   }}
   
   static var presenter: CellPresenterWork<Benefit, BenefitCell<Design>> { .init { work in
      let data = work.unsafeInput.item

      let cell = BenefitCell<Design>()
      cell.titleLabel.text(data.name.unwrap)
      cell.descriptionLabel.text(data.description.unwrap)

      if let price = data.price?.priceInThanks {
         cell.currencyButton.setValue(price)
      } else {
         cell.currencyButton.hidden(true)
      }

      if
         (data.images?.contains(where: { $0.forShowcase == true })) != nil,
         let urls = data.presentingImages?.compactMap(\.link),
         urls.isEmpty == false
      {
         cell.presentImageUrls(urls)
      }

      work.success(cell)
   } }

}
