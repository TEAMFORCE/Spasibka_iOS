//
//  String+DateFormat.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 29.08.2022.
//

import Foundation

enum DateFormat: String {
   case dMMMyHHmm = "d MMM y HH:mm"
   case dMMMy = "d MMM y"
   case dMMMMy = "d MMMM y"
   case ddMMyyyy = "dd.MM.yyyy"
   case yyyyMMdd = "yyyy-MM-dd"
   case yyyyMMddTHHmmssZZZZZ = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
   case yyyyMMddTHHmmssSSSSSSZ = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
   case ddMM = "dd MMMM"
   case dMMMMyyyy = "d MMMM yyyy"
   case ddMMyyyyHHmm = "dd.MM.yyyy HH:mm"
   case hhMM = "HH:mm"
}

enum BackEndDateFormat: String, CaseIterable {
   case dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
   case dateFormatFull = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
   case dateYearMonthDay = "yyyy-MM-dd"
}

enum TimeZomeAbbreviation: String {
   case UTC = "UTC"
}

extension Date {
   func convertToString(_ format: DateFormat = .dMMMyHHmm, abbreviation: TimeZomeAbbreviation? = nil) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = format.rawValue
      formatter.locale = .autoupdatingCurrent //Locale(identifier: "ru_RU")
      if let abbreviation = abbreviation {
         formatter.timeZone = TimeZone(abbreviation: abbreviation.rawValue)
      }
      let result = formatter.string(from: self)
      print(result)
      return result
   }
}

extension String {
   func dateFormatted(_ format: DateFormat = .dMMMyHHmm) -> String? {
      let inputFormatter = DateFormatter()
      return BackEndDateFormat.allCases.compactMap {
         inputFormatter.dateFormat = $0.rawValue
         if let convertedDate = inputFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = .autoupdatingCurrent //Locale(identifier: "ru_RU")
            outputFormatter.dateFormat = format.rawValue

            return outputFormatter.string(from: convertedDate)
         }
         return nil
      }.first
   }
}

extension String {
   var dateConvertedToDate: Date? {
      let inputFormatter = DateFormatter()
      inputFormatter.dateFormat = BackEndDateFormat.dateFormatFull.rawValue
      var convertedDate = inputFormatter.date(from: self) //else { return nil }
      if convertedDate == nil {
         inputFormatter.dateFormat = BackEndDateFormat.dateYearMonthDay.rawValue
         convertedDate = inputFormatter.date(from: self)
      }
      return convertedDate
   }
   
   // needs refactoring: make one function from dataConvertedToDate and dataConvertedToDate1
   var dateConvertedToDate1: Date? {
      let inputFormatter = DateFormatter()
      inputFormatter.dateFormat = BackEndDateFormat.dateFormat.rawValue
      guard let convertedDate = inputFormatter.date(from: self) else { return nil }
      return convertedDate
   }

   var dateConverted: String {
      guard let convertedDate = dateConvertedToDate else { return "" }

      let outputFormatter = DateFormatter()
      outputFormatter.locale = .autoupdatingCurrent //Locale(identifier: "ru_RU")
      outputFormatter.dateFormat = "d MMM y"

      return outputFormatter.string(from: convertedDate)
   }
   
   var dateConvertedDDMMYY: String {
      guard let convertedDate = dateConvertedToDate else { return "" }
      
      let outputFormatter = DateFormatter()
      outputFormatter.locale = .autoupdatingCurrent //Locale(identifier: "ru_RU")
      outputFormatter.dateFormat = "dd.MM.yyyy"

      return outputFormatter.string(from: convertedDate)
   }

   var timeAgoConverted: String {
      let inputFormatter = DateFormatter()
      inputFormatter.dateFormat = BackEndDateFormat.dateFormatFull.rawValue
      guard let convertedDate = inputFormatter.date(from: self) else { return "" }

      let formatter = RelativeDateTimeFormatter()
      formatter.locale = .autoupdatingCurrent
      formatter.unitsStyle = .full
      return formatter.localizedString(for: convertedDate, relativeTo: Date())
   }
   
   var dateFullConverted: String {
      guard let convertedDate = dateConvertedToDate else { return "" }

      let outputFormatter = DateFormatter()
      outputFormatter.locale = .autoupdatingCurrent
      outputFormatter.dateFormat = "d MMM y HH:mm"

      return outputFormatter.string(from: convertedDate)
   }

   func dateConverted(
      inputFormat: DateFormat,
      outputFormat: DateFormat
   ) -> String? {
      let inputFormatter = DateFormatter()
      inputFormatter.dateFormat = inputFormat.rawValue
      guard let convertedDate = inputFormatter.date(from: self) else { return nil }

      let outputFormatter = DateFormatter()
      outputFormatter.locale = .autoupdatingCurrent
      outputFormatter.dateFormat = outputFormat.rawValue

      return outputFormatter.string(from: convertedDate)
   }

   func dateAgoConverted(
      inputFormat: DateFormat,
      unitsStyle: RelativeDateTimeFormatter.UnitsStyle
   ) -> String? {
      let inputFormatter = DateFormatter()
      inputFormatter.dateFormat = inputFormat.rawValue
      guard let convertedDate = inputFormatter.date(from: self) else { return nil }

      let formatter = RelativeDateTimeFormatter()
      formatter.locale = .autoupdatingCurrent
      formatter.unitsStyle = unitsStyle
      return formatter.localizedString(for: convertedDate, relativeTo: Date())
   }
}
