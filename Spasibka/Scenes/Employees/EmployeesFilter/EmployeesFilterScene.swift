//
//  EmployeesFilterScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.02.2023.
//

import CoreGraphics
import StackNinja

final class EmployeesFilterScene<Asset: ASP>: BaseFilterPopupScene<Asset, EmployeesFilter?>, Scenarible {
   lazy var scenario = EmployeesFilterScenario<Asset>(
      works: EmployeesFilterWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: EmployeesFilterScenarioEvents(
         initializeWithFilter: Out<EmployeesFilter?>(),
         didSelectFilterItemAtIndex: filterList.on(\.didSelectItemAtIndex),
         firedAtSwitched: firedAtSwitcher.switcher.on(\.turned),
         inOfficeSwitched: inOfficeSwitcher.switcher.on(\.turned),
         onHolidaySwitched: onHolidaySwitcher.switcher.on(\.turned),
         didApplyFilterPressed: applyFilterButton.on(\.didTap),
         didClearFilterPressed: clearFilterButton.on(\.didTap)
      )
   )

   // private

   private lazy var filterList = TableItemsModel()
      .presenters(
         CheckMarkLabelPresenter<Design>.presenter
      )
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()
      .maxHeight(200.aspected)

   private lazy var firedAtSwitcher = LabelSwitcherX.switcherWith(text: Design.text.firedAt)
      .setAll { label, _ in
         label.set(Design.state.label.regular14)
      }

   private lazy var inOfficeSwitcher = LabelSwitcherX.switcherWith(text: Design.text.inOffice)
      .setAll { label, _ in
         label.set(Design.state.label.regular14)
      }

   private lazy var onHolidaySwitcher = LabelSwitcherX.switcherWith(text: Design.text.onHoliday)
      .setAll { label, _ in
         label.set(Design.state.label.regular14)
      }

   // Start

   override func start() {
      super.start()
      title.font(Design.font.descriptionMedium20)
      bodyStack
         .spacing(12)
         .arrangedModels(
            LabelModel()
               .set(Design.state.label.descriptionMedium16)
               .text(Design.text.subdivision),
            filterList,
            firedAtSwitcher,
            inOfficeSwitcher,
            onHolidaySwitcher,
            Spacer(32)
         )

      closeButton.on(\.didTap, self) {
         $0.send(\.cancelled)
      }
      closeButton.removeTapGestures()
      closeButton.alpha(0)
//      closeButton.hidden(true)

      scenario.configureAndStart()
   }
}

enum EmployeesFilterSceneState {
   case initial([SelectWrapper<DepartmentTree>])
   
   case setupFilterFace(EmployeesFilter?)

   case updateFilterItemAtIndex(item: SelectWrapper<DepartmentTree>, index: Int)

   case applyFilter(EmployeesFilter?)
}

extension EmployeesFilterScene: StateMachine {
   func setState(_ state: EmployeesFilterSceneState) {
      switch state {
      case let .initial(value):
         let items = value.map(checkmarkInputFrom)
         filterList.items(items)
         
      case let .setupFilterFace(filter):
         firedAtSwitcher.switcher.setState(.turned(filter?.filterFiredAt == 1 ? true : false))
         inOfficeSwitcher.switcher.setState(.turned(filter?.filterInOffice == 1 ? true : false))
         onHolidaySwitcher.switcher.setState(.turned(filter?.filterOnHoliday == 1 ? true : false))

      case let .applyFilter(filter):
         send(\.finishFiltered, filter)

      case let .updateFilterItemAtIndex(item, index):
         filterList.updateItemAtIndex(
            checkmarkInputFrom(item),
            index: index
         )
      }
   }

   private func checkmarkInputFrom(_ depTree: SelectWrapper<DepartmentTree>) -> CheckMarkLabelInput {
      CheckMarkLabelInput(
         text: depTree.value.name,
         isSelected: depTree.isSelected,
         leftOffset: (depTree.value.depth.unwrap).cgFloat * 24
      )
   }
}

struct CheckMarkLabelPresenter<Design: DSP> {
   static var presenter: CellPresenterWork<CheckMarkLabelInput, CheckMarkLabel<Design>> { .init { work in
      let item = work.in.item
      let offset = work.in.item.leftOffset

      let cell = CheckMarkLabel<Design>()
         .setStates(
            .text(item.text),
            .selected(item.isSelected)
         )
         .padding(.verticalOffset(7))
         .padLeft(offset)
         .userInterractionEnabled(false)

      work.success(cell)
   }}
}
