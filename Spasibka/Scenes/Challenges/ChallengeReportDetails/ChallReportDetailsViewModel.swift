//
//  ChallReportDetailsViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.10.2022.
//

import StackNinja

final class ChallReportDetailsVM<Design: DSP>: StackModel, Designable {
   
   var events: EventsStore = .init()
   
   lazy var title = Design.label.regular20
   lazy var body = Design.label.regular12
      .numberOfLines(0)
      .lineSpacing(8)
   
   let photo = ImageViewModel()
      .image(Design.icon.transactSuccess)
      .height(250)
      .width(250)
      .contentMode(.scaleAspectFill)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
      .hidden(true)
   
   override func start() {
      super.start()
      
   }
}

extension ChallReportDetailsVM: SetupProtocol {
   func setup(_ report: ChallengeReport) {
      title.text(report.challenge.name.unwrap)
      body.text(report.text.unwrap)
      
      
      if let photoLink = report.photo {
         let photoURL = SpasibkaEndpoints.urlBase + photoLink
         photo.url(photoURL)
         photo.view.on(\.didTap, self) {
            $0.send(\.presentImage, photoURL)
         }
         photo.hidden(false)
      }
   }
}
extension ChallReportDetailsVM: Eventable {
   struct Events: InitProtocol {
      var presentImage: String?
   }
}
