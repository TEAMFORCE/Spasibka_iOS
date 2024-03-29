//
//  GetCurrentPeriodApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 19.08.2022.
//

import StackNinja

final class GetCurrentPeriodApiWorker: BaseApiWorker<String, Period> {
    override func doAsync(work: Wrk) {
        apiEngine?
            .process(endpoint: SpasibkaEndpoints.GetCurrentPeriod(headers: [
                Config.tokenHeaderKey: work.input.unwrap,
            ]))
            .done { result in
                let decoder = DataToDecodableParser()

                guard
                    let data = result.data,
                    let period: Period = decoder.parse(data)
                else {
                    work.fail()
                    return
                }

                work.success(result: period)
            }
            .catch { _ in
                work.fail()
            }
    }
}
