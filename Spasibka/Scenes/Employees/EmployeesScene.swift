//
//  EmployeesScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.02.2023.
//

import StackNinja
import UIKit

struct EmployeesSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyFooterStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class EmployeesScene<Asset: ASP>: BaseParamsScene<EmployeesSceneParams<Asset>>,
Scenarible {
   
   lazy var scenario = EmployeesScenario(
      works: EmployeesWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: EmployeesScenarioParams<_>.ScenarioInputEvents(
         didChangeSearchText: searchModel.subModel.models.main.on(\.didEditingChanged),
         didSelectItemAtIndex: employeesTable.on(\.didSelectItemAtIndex),
         didFilterTapped:  mainVM.navBar.menuButton.on(\.didTap),
         didUpdateFilterState: employeesFilterModel.on(\.finishFiltered),
         requestPagination: employeesTable.on(\.requestPagination)
      )
   )
   
//   var userSearchTextField: TextFieldModel { .init()
//      .set(Design.state.textField.default)
//      .placeholder(Design.text.chooseRecipient)
//      .placeholderColor(Design.color.textFieldPlaceholder)
//      .disableAutocorrection()
//   }
   
   private lazy var searchModel = WrappedX<M<TextFieldModel>.R<ButtonModel>.Ninja>()
      .padding(.bottom(12))
      .spacing(20)
      .setup {
         $0.subModel
            .setAll { textField, button in
               textField
                  .placeholder(Design.text.findEmployee)
                  .placeholderColor(Design.color.textContrastSecondary)
                  .font(Design.font.descriptionRegular14)
                  .textColor(Design.color.text)
                  
               button
                  .image(Design.icon.searchIcon.withTintColor(Design.color.text))
                  .size(.square(18))
            }
            .height(48)
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            .borderColor(Design.color.iconMidpoint)
            .borderWidth(1)
            .padding(.outline(12))
      }
   
//   private lazy var searchField = Design.model.transact.userSearchTextField
//      .placeholder(Design.text.findEmployee)

   private lazy var employeesTable = TableItemsModel()
      .presenters(
         SpacerPresenter.presenter,
         EmployeeCellPresenter<Design>.presenter
      )
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()
   
   private lazy var hereIsEmpty = Design.model.transact.userNotFoundInfoBlock
   
   private lazy var filterButton = Design.model.common.filterButton
   
   private lazy var bottomPopupPresenter = BottomPopupPresenter()
   
   private lazy var employeesFilterModel = EmployeesFilterScene<Asset>()
         .on(\.cancelled, self) {
            $0.bottomPopupPresenter.setState(.hide)
         }

   
   override func start() {
      super.start()
      
      vcModel?.on(\.viewWillAppear, self) {
         $0.vcModel?
            .titleColor(Design.color.transparent)
            .navBarTintColor(Design.color.transparent)
            .titleAlpha(0)
      }
      
      mainVM.navBar
         .titleLabel.text(Design.text.participants)
      mainVM.navBar
         .menuButton.image(Design.icon.navBarMenuButton)
      
      mainVM.bodyStack.arrangedModels(
         Spacer(16),
         searchModel.wrappedX().padding(.horizontalOffset(16)),
         hereIsEmpty.hidden(true)
         //Spacer(8)
      )
      
      mainVM.footerStack.arrangedModels(
         employeesTable,
         Spacer()
      )
      .padding(UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
      
      scenario.configureAndStart()
   }
}

enum EmployeesSceneState {
   case initial
   case updateSearchField(String)
   case presentEmployees([Colleague])
   case presentEmployeeProfile(Colleague)
   case hereIsEmpty
   case presentFilter(EmployeesFilter?)
   case hidePopup
   case setFilterButtonActive(Bool)
}

extension EmployeesScene: StateMachine {
   func setState(_ state: EmployeesSceneState) {
      switch state {
      case .initial:
         break
      case let .presentEmployees(employees):
         guard employees.isEmpty == false else {
            employeesTable.items([])
            setState(.hereIsEmpty)
            return
         }
         hereIsEmpty.hidden(true)
         employeesTable.items(employees + [SpacerItem(96)])
        
      case let .presentEmployeeProfile(employee):
         let id = employee.userId
         Asset.router?.route(.push, scene: \.profile, payload: id)
      case .updateSearchField(let value):
         searchModel.subModel.models.main.text(value) //.text(value)
      case .hereIsEmpty:
         hereIsEmpty.hidden(false)
      case .presentFilter(let filter):
         employeesFilterModel.scenario.configureAndStart()
         employeesFilterModel.scenario.events.initializeWithFilter.sendAsyncEvent(filter)
         bottomPopupPresenter.setState(.presentWithAutoHeight(model: employeesFilterModel,
                                                              onView: vcModel?.superview))
      case .setFilterButtonActive(let value):
         if value {
            filterButton.setMode(\.selected)
         } else {
            filterButton.setMode(\.normal)
         }
         
      case .hidePopup:
         bottomPopupPresenter.setState(.hide)
      }
   }
}

enum EmployeeCellPresenter<Design: DSP> {
   static var presenter: CellPresenterWork<Colleague, ImageLabelLabelMRD> { .init { work in

      let item = work.in.item
      
      let cell = ImageLabelLabelMRD()
         .setAll { icon, name, job in
            icon
               .size(.square(36))
               .contentMode(.scaleAspectFill)
               //.backColor(Design.color.backgroundBrand)
               .cornerCurve(.continuous).cornerRadius(36/2)
            
            if let photo = item.photo {
              icon.url(SpasibkaEndpoints.tryConvertToImageUrl(photo))
            }
            else {
               let firstnameLetter = item.firstName?.first?.toString ?? ""
               let surnameLetter = item.surname?.first?.toString ?? ""
               let imageText = firstnameLetter + surnameLetter
//               icon.textImage(imageText, backColor: Design.color.backgroundBrand)
               if imageText.isEmpty {
                  icon.image(Design.icon.avatarPlaceholder)
               } else {
                  let image = imageText.drawImage(backColor: Design.color.backgroundBrand)
                  icon
                     .backColor(Design.color.backgroundBrand)
                     .image(image)
               }
            }
            
            name
               .set(Design.state.label.labelRegular14)
//               .text(item.firstName.unwrap + " " + item.surname.unwrap)
            var nameText: String = ""
            if let name = item.firstName {
               nameText = name
            }
            if let surname = item.surname {
               if !nameText.isEmpty { nameText += " "}
               nameText += surname
            }
            if nameText.isEmpty {
               nameText = item.tgName.unwrap
            }
            name
               .text(nameText)
            
            job
               .set(Design.state.label.descriptionMedium12)
               .textColor(Design.color.success)
               .text(item.jobTitle.unwrap)
               .numberOfLines(2)
         }
         .spacing(12)
         .padding(.init(top: 18, left: 28, bottom: 18, right: 28))
         .backViewModel(
            ViewModel {
               $0
                  .backColor(Design.color.background)
                  .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
                  .shadow(Design.params.newCellShadow)
            }, inset: .init(top: 8, left: 16, bottom: 8, right: 16)
         )
      
      work.success(cell)
   } }
}
