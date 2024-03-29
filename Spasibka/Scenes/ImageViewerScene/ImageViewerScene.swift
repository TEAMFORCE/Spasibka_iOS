//
//  ImageViewerScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.10.2022.
//


//нужен рефакторинг, займусь на выходных

import StackNinja
import UIKit

enum ImageViewerInput {
   case url(String)
   case image(UIImage)
   case urls([String], current: Int)
}

final class ImageViewerScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   ViewModel,
   Asset,
   ImageViewerInput,
   Void
> {
   //
   private lazy var closeButton = ButtonModel()
      .title(Design.text.close)
      .textColor(Design.color.textBrand)

   private lazy var titlePanel = StackModel(
      Spacer(16),
      shareButton,
      Spacer(),
      closeButton,
      Spacer(16)
   )
   .height(64)
   .axis(.horizontal)
   .alignment(.top)

   private lazy var image = ImageViewModel()
      .contentMode(.scaleAspectFit)

   private(set) lazy var pagingScrollModel = PagingScrollViewModel()
   private(set) var images: [UIImage] = []

   private lazy var scrollModels: [ScrollViewModel] = []
   private lazy var scrollModel = ScrollViewModel()
      .backColor(.black)

   private lazy var activity = Design.model.common.activityIndicator

   private lazy var shareButton = ButtonModel()
      .image(.init(systemName: "square.and.arrow.up")!)
      .tint(Design.color.iconBrand)
      .size(.square(32))

   private lazy var darkLoader = DarkLoaderVM<Design>()

   override func start() {
      super.start()
      scrollModel
         .viewModel(image)
      
      mainVM.backColor(Design.color.background)
      pagingScrollModel.setState(.setViewModels([scrollModel]))

      mainVM
         .addModel(pagingScrollModel, setup: { anchors, superview in
            anchors.fitToView(superview)
         })
         .addModel(titlePanel, setup: { anchors, superview in
            anchors.fitToTop(superview, offset: 16)
         })
         .addModel(activity) { anchors, view in
            anchors
               .centerX(view.centerXAnchor)
               .centerY(view.centerYAnchor)
         }

      on(\.input, self) { slf, input in
         slf.vcModel?.on(\.viewDidAppear) { [slf] in
            switch input {
            case .url(let url):
               slf.setUrlImage(url: url)
            case .image(let image):
               slf.completeFunction(image: image)
               slf.image.image(image)
               slf.images = [image]
            case .urls(let urls, let current):
               self.pagingScrollModel.setState(.deleteAll)
               for (i, url) in urls.enumerated() {
                  let scrollModel = ScrollViewModel()
                     .backColor(.black)
                  let image = ImageViewModel()
               
                  image.indirectUrl(SpasibkaEndpoints.urlBase + url) { _, image in
                     guard let image = image else { return }
                     self.images.append(image)
                     
                     let tempImage = ImageViewModel()
                        .contentMode(.scaleAspectFit)
                        .image(image)
                     
                     scrollModel
                        .viewModel(tempImage)
                        .zooming(min: 1, max: 4)
                        .doubleTapForZooming()
                     
                     self.pagingScrollModel.setState(.addViewModel(viewModel: scrollModel))
                     self.activity.hidden(true)
                     if i + 1 == urls.endIndex {
                        self.pagingScrollModel.scrollToIndex(current)
                     }
                  }
               }
            }
            
         }
      }

      closeButton.on(\.didTap, self) {
         $0.dismiss()
         $0.finishCanceled()
      }
      configureShareButton()
   }
   
   private func setUrlImage(url: String) {
      self.image.url(url) { [weak self] _, _ in
         self?.image.url(SpasibkaEndpoints.removeThumbSuffix(url)) { _, image in
            if let image {
               self?.completeFunction(image: image)
               self?.images = [image]
            } else {
               self?.image.indirectUrl(url) { [weak self] _, image in
                  if let image {
                     self?.completeFunction(image: image)
                     self?.images = [image]
                  } else {
                     self?.image.url(url) {[weak self] _, image in
                        self?.completeFunction(image: image)
                        if let image {
                           self?.images = [image]
                        }
                     }
                  }
               }
            }
         }
      }
   }

   private func presentSharing(image: UIImage?) {
      darkLoader.setState(.loading(onView: vcModel?.view))

      let imageToShare = [image]
      let activityViewController = UIActivityViewController(
         activityItems: imageToShare as [Any], applicationActivities: nil
      )
      activityViewController.popoverPresentationController?.sourceView = vcModel?.view

      activityViewController.excludedActivityTypes = [
         UIActivity.ActivityType.postToFacebook,
      ]
      vcModel?.present(activityViewController, animated: true) { [weak self] in
         self?.darkLoader.setState(.hide)
      }
   }
   
   private func completeFunction(image: UIImage?) {
      activity.hidden(true)
      scrollModel
         .zooming(min: 1, max: 4)
         .doubleTapForZooming()
   }
   
   private func configureShareButton() {
      shareButton.on(\.didTap) { [weak self] in
         guard
            let index = self?.pagingScrollModel.currentPage,
            let image = self?.images[safe: index]
         else { return }
         self?.presentSharing(image: image)
      }
   }
}
