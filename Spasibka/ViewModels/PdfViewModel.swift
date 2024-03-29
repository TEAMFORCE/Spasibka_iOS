//
//  PdfViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 03.09.2023.
//

import StackNinja
import PDFKit

class PdfViewModel: BaseViewModel<PDFView>, Stateable {
   typealias State = ViewState

   @discardableResult
   func pdfDocument(_ value: PDFDocument) -> Self {
      view.document = value
      return self
   }

   @discardableResult
   func autoScales(_ value: Bool) -> Self {
      view.autoScales = value
      return self
   }
}
