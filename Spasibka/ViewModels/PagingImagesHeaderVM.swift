//
//  PagingImagesHeaderVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 15.03.2023.
//

import StackNinja
import UIKit

class PagingImagesHeaderVM<Design: DSP>: StackModel.X, Eventable {
   struct Events: InitProtocol {
      var didImagePresented: UIImage?
      var pressedImagePath: String?
   }
   
   var events: EventsStore = .init()
   
   private(set) lazy var pagingScrollModel = PagingScrollViewModel()
   private(set) lazy var imageModels = [ImageViewModel]()
   
   override func start() {
      super.start()
      
      arrangedModels(pagingScrollModel)
      pagingScrollModel.on(\.didViewModelPresented, self) {
         guard let image = ($1.0.uiView as? UIImageView)?.image else { return }
         
         $0.send(\.didImagePresented, image)
      }
   }
   
   func presentIndirectUrls(_ urls: [String], placeHolder: UIImage? = nil) {
      setViewModels([])
      imageModels.removeAll()
      
      urls.enumerated().forEach {
         let path = $0.element
         let index = $0.offset
         let viewModel = ImageViewModel()
         viewModel
            .contentMode(.scaleAspectFill)
            .presentActivityModel(ActivityIndicator<Design>())
            .indirectUrl(path) { [weak self] imageModel, image in
               imageModel?.hideActivityModel()
               if let image, index == self?.pagingScrollModel.currentPage {
                  self?.send(\.didImagePresented, image)
               }
            }
            .view
            .startTapGestureRecognize()
            .on(\.didTap, self) {
               $0.send(\.pressedImagePath, path)
            }
         if let placeHolder {
            viewModel.image(placeHolder)
         }
         viewModel.setNeedsStoreModelInView()
         
         imageModels.append(viewModel)
         addViewModel(viewModel)
      }
   }
   
   func addViewModel(_ imageModel: ImageViewModel, atIndex: Int? = nil) {
      imageModels.append(imageModel)
      pagingScrollModel.setState(.addViewModel(viewModel: imageModel))
   }
   
   func setViewModels(_ models: [ImageViewModel]) {
      pagingScrollModel.setState(.setViewModels(models))
   }
}

