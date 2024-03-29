//
//  PlaygroundScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 07.08.2022.
//

import StackNinja
import UIKit

import Lottie

struct PlaysParams<Asset: ASP>: SceneParams {

    struct Models: SceneModelParams {
        typealias VCModel = DefaultVCModel
        typealias MainViewModel = StackModel
    }

    struct InOut: InOutParams {
        typealias Input = Void
        typealias Output = Void
    }
}

final class PlaygroundScene<Asset: ASP>: BaseParamsScene<PlaysParams<Asset>> {

    private lazy var lottie = LottieAnima()

    override func start() {
        mainVM.arrangedModels(lottie)

        let anima = LottieAnimation.named("winter_intro")
        lottie.view.animation = anima
        lottie.view.play()
    }
}

final class LottieAnima: BaseViewModel<LottieAnimationView> {

}
