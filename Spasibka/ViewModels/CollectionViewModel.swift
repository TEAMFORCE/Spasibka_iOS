//
//  CollectionViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 22.01.2024.
//

import StackNinja
import UIKit

struct CollectionSection: Hashable {
   let items: [any Hashable]
}

struct CollectionViewModelEvents: InitProtocol, ScrollEventsProtocol {
   var didScroll: (velocity: CGFloat, offset: CGFloat)?
   var willEndDragging: (velocity: CGFloat, offset: CGFloat)?
   var didSelectItemAtIndex: Int?
   var didSelectItemAtIndexPath: IndexPath?
}

final class CollectionViewModel: BaseViewModel<ExtendedCollectionView>, Eventable {
   var events = EventsStore()

   typealias DataSource = UICollectionViewDiffableDataSource<CollectionSection, Int>
   typealias Snapshot = NSDiffableDataSourceSnapshot<CollectionSection, Int>
   typealias Events = CollectionViewModelEvents

   private var presenters: [String: CollectionPresenter] = [:]
   private var sections: [CollectionSection] = []

   private lazy var dataSource: DataSource = .init(collectionView: view) { [weak self] collectionView, indexPath, _ in
      guard let self else { return .init() }

      let item = self.sections[indexPath.section].items[indexPath.row]
      let cellName = String(describing: type(of: item))

      guard let presenter = self.presenters[cellName] else { return .init() }

      collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: cellName)
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath)

      let content = presenter.viewModel(for: item, indexPath: indexPath)

      cell.contentView.subviews.forEach { $0.removeFromSuperview() }

      content.uiView
         .addToSuperview(cell.contentView)
         .fitToView(cell.contentView)

      return cell
   }

   init(layouts: NSCollectionLayoutSection...) {
      let layout = UICollectionViewCompositionalLayout { index, _ in
         layouts[index]
      }

      super.init(view: .init(frame: .zero, collectionViewLayout: layout))

      view.delegate = self
   }
   
   required init() {
      fatalError("init() has not been implemented")
   }
}

extension CollectionViewModel {
   @discardableResult
   func presenters(_ presenters: any CollectionCellPresenter...) -> Self {
      presenters.forEach {
         let key = $0.cellType
         self.presenters[key] = $0
      }

      return self
   }

   @discardableResult
   func sections(_ sections: [CollectionSection], animated: Bool = true) -> Self {
      self.sections = sections
      var snapshot = Snapshot()
      snapshot.appendSections(sections)
      sections.forEach { section in
         snapshot.appendItems(section.items.map { $0.hashValue }, toSection: section)
      }
      dataSource.apply(snapshot, animatingDifferences: animated)

      return self
   }
}

extension CollectionViewModel: UICollectionViewDelegate {
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      send(\.didSelectItemAtIndexPath, indexPath)
      send(\.didSelectItemAtIndex, indexPath.item)
   }
}

final class ExtendedCollectionView: UICollectionView {}

protocol CollectionPresenter {
   func viewModel(for item: any Hashable, indexPath: IndexPath) -> UIViewModel
}

protocol CollectionCellPresenter: CollectionPresenter {
   associatedtype Item: Hashable
   func viewModel(for item: Item, indexPath: IndexPath) -> UIViewModel
}

extension CollectionCellPresenter {
   var cellType: String {
      let name = String(describing: Item.self)
      return name
   }

   func viewModel(for item: any Hashable, indexPath: IndexPath) -> UIViewModel {
      viewModel(for: item as! Item, indexPath: indexPath)
   }
}

public final class CollectionCell: UICollectionViewCell {}

enum CollectionSectionsLayoutFactory {
   static func build(
      groupSize: NSCollectionLayoutSize,
      itemSize: NSCollectionLayoutSize,
      itemSpacing: NSCollectionLayoutSpacing = .fixed(0),
      contentInsets: NSDirectionalEdgeInsets = .zero,
      hasHeader: Bool = false,
      hasFooter: Bool = false,
      isHorizontal: Bool = false
   ) -> NSCollectionLayoutSection {
      let item = NSCollectionLayoutItem(layoutSize: itemSize)

      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      group.interItemSpacing = itemSpacing

      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = contentInsets
      section.orthogonalScrollingBehavior = isHorizontal ? .continuous : .none

      if hasHeader {
         let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1)
         )
         let headerElement = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
         )
         section.boundarySupplementaryItems.append(headerElement)
      }

      if hasFooter {
         let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1)
         )
         let footerElement = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
         )
         section.boundarySupplementaryItems.append(footerElement)
      }

      return section
   }
}
