//
//  AwardsViewModelWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.12.2023.
//

import Foundation
import StackNinja

enum AwardsMode {
   case normal
   case receivedAwards
}

struct AwardsSection {
   let title: String
   let awards: [Award]
}

final class AwardsViewModelWorks<Asset: ASP>: WorksProtocol {
   let retainer = Retainer()

   var mode = AwardsMode.normal
   var awardsSections: [AwardsSection] = []
   var filterIndex: Int?

   func setInitialMode(_ mode: AwardsMode) {
      self.mode = mode
   }

   var loadAwards: Out<[AwardsSection]> { .init { [self] work in
      self.loadAwardGroups
         .doAsync()
         .doZip(self.loadAwardsAll)
         .doMap { awardGroups, awards in
            let awardsForMode = awards.filter { award in
               if self.mode == .receivedAwards {
                  return award.received.unwrap
               } else {
                  return true
               }
            }
            var unfilteredAwards = awardsForMode
            let groupsWithAwards = awardGroups.map { group -> AwardsSection in
               let name = group.name.unwrap
               let filtered = awardsForMode.filter { $0.categoryId == group.id }
               unfilteredAwards.removeAll(where: { $0.categoryId == group.id })
               return AwardsSection(title: name, awards: filtered)
            }
            return groupsWithAwards + [AwardsSection(title: Asset.Design.text.uniqueAwards, awards: unfilteredAwards)]
         }
         .doFilter {
            !$0.awards.isEmpty
         }
         .doSaveTo(self, \.awardsSections)
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }

   }.retainBy(retainer) }

   func getAwardSections() -> [AwardsSection] {
      filterIndex = nil
      return awardsSections
   }

   func getFilteredForIndex(_ index: Int) -> [AwardsSection] {
      filterIndex = index
      return [awardsSections[index]]
   }

   func getAwardForIndexPath(_ indexPath: IndexPath) -> Award {
      if let filterIndex = filterIndex {
         return awardsSections[filterIndex].awards[indexPath.row]
      } else {
         return awardsSections[indexPath.section].awards[indexPath.row]
      }
   }

   // MARK: - Private

   private var loadAwardGroups: Out<[AwardGroup]> { .init { work in
      Asset.userDefaultsWorks.loadValueWork()
         .doAsync(.currentOrganizationID)
         .onFail {
            work.fail()
         }
         .doNext(Asset.apiUseCase.getAwardGroups)
         .onFail {
            work.fail()
         }
         .onSuccess {
            work.success($0)
         }
   }.retainBy(retainer) }

   private var loadAwardsAll: Out<[Award]> { .init { work in
      Asset.userDefaultsWorks.loadValueWork()
         .doAsync(.currentOrganizationID)
         .onFail {
            work.fail()
         }
         .doNext(Asset.apiUseCase.getAwards)
         .onFail {
            work.fail()
         }
         .onSuccess {
            work.success($0)
         }
   }.retainBy(retainer) }
}

private func fakeAradGroups() -> [AwardGroup] {
   [
      AwardGroup(id: 1, name: "Group 1"),
      AwardGroup(id: 2, name: "Group 2"),
      AwardGroup(id: 3, name: "Group 3"),
      AwardGroup(id: 4, name: "Group 4"),
      AwardGroup(id: 5, name: "Group 5"),
      AwardGroup(id: 6, name: "Group 6"),
      AwardGroup(id: 7, name: "Group 7"),
      AwardGroup(id: 8, name: "Group 8"),
   ]
}

private func fakeAwards() -> [Award] {
   [
//      Award(id: 1, name: "Award 1", cover: nil, reward: 1, toScore: 1, description: "Description 1", scored: 1, received: true, categoryId: 1, categoryName: "Category 1", coverFullUrlString: "https://picsum.photos/200/300"),
//      Award(id: 2, name: "Award 2", cover: nil, reward: 2, toScore: 2, description: "Description 2", scored: 2, received: false, categoryId: 2, categoryName: "Category 2", coverFullUrlString: "https://picsum.photos/200/300"),
//      Award(id: 3, name: "Award 3", cover: nil, reward: 3, toScore: 3, description: "Description 3", scored: 0, received: false, categoryId: 3, categoryName: "Category 3"),
//      Award(id: 4, name: "Award 4", cover: nil, reward: 4, toScore: 4, description: "Description 4", scored: 2, received: false, categoryId: 4, categoryName: "Category 4", coverFullUrlString: "https://picsum.photos/200/300"),
//      Award(id: 5, name: "Award 5", cover: nil, reward: 5, toScore: 5, description: "Description 5", scored: 1, received: true, categoryId: 5, categoryName: "Category 5"),
//      Award(id: 6, name: "Award 6", cover: nil, reward: 6, toScore: 6, description: "Description 6", scored: 3, received: false, categoryId: 6, categoryName: "Category 6", coverFullUrlString: "https://picsum.photos/200/300"),
//      Award(id: 7, name: "Award 7", cover: nil, reward: 7, toScore: 7, description: "Description 7", scored: 7, received: false, categoryId: 7, categoryName: "Category 7"),
//      Award(id: 8, name: "Award 8", cover: nil, reward: 8, toScore: 8, description: "Description 8", scored: 0, received: true, categoryId: 1, categoryName: "Category 8"),
//      Award(id: 9, name: "Award 9", cover: nil, reward: 9, toScore: 9, description: "Description 9", scored: 3,
//            received: true, categoryId: 9, categoryName: "Category 9", coverFullUrlString: "https://picsum.photos/200/300"),
//      Award(id: 10, name: "Award 10", cover: nil, reward: 10, toScore: 10, description: "Description 10", scored: 7, received: true, categoryId: 1, categoryName: "Category 10"),
//      Award(id: 11, name: "Award 11", cover: nil, reward: 11, toScore: 11, description: "Description 11", scored: 11, received: false, categoryId: 1, categoryName: "Category 11", coverFullUrlString: "https://picsum.photos/200/300"),
      Award(id: 12, name: "Award 12", cover: nil, reward: 12, toScore: 12, description: "Description 12", scored: 0, received: false, categoryId: 2, categoryName: "Category 12"),
      Award(id: 13, name: "Award 13", cover: nil, reward: 13, toScore: 13, description: "Description 13", scored: 0, received: true, categoryId: 2, categoryName: "Category 13"),
   ]
}
