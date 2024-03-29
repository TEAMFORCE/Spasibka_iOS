//
//  GetProfileApiModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.07.2022.
//

import Foundation
import StackNinja

final class GetMyProfileApiWorker: BaseApiWorker<TokenRequest, UserData> {
    override func doAsync(work: Work<TokenRequest, UserData>) {
        guard let request = work.input else { work.fail(); return }

        apiEngine?
            .process(endpoint: SpasibkaEndpoints.ProfileEndpoint(headers: [
                Config.tokenHeaderKey: request.token,
            ]))
            .done { result in
                let decoder = DataToDecodableParser()

                guard
                    let data = result.data,
                    let user: UserData = decoder.parse(data)
                else {
                    work.fail()
                    return
                }
                work.success(result: user)
            }
            .catch { error in
                work.fail()
            }
    }
}
