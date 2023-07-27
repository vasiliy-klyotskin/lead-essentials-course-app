//
//  ListPokemonItemUIComposer.swift
//  Pokepedia-iOS-App
//
//  Created by Василий Клецкин on 6/2/23.
//

import Pokepedia_iOS
import Pokepedia
import Combine
import UIKit

enum ListPokemonItemUIComposer {
    typealias Presenter = LoadingResourcePresenter<ListPokemonItemImage, WeakProxy<ListPokemonItemViewController>>
    typealias PresentationAdapter = ResourceLoadingPresentationAdapter<ListPokemonItemImage, WeakProxy<ListPokemonItemViewController>>
    
    static func compose(
        item: PokemonListItem,
        loader: @escaping () -> AnyPublisher<ListPokemonItemImage, Error>
    ) -> ListPokemonItemViewController {
        let loadingAdapter = PresentationAdapter(loader: loader)
        let viewModel = PokemonListPresenter.map(
            item: item,
            colorMapping: UIColor.fromHex
        )
        let controller = ListPokemonItemViewController(
            viewModel: viewModel,
            onImageRequest: loadingAdapter.load
        )
        let presenter = Presenter(
            view: WeakProxy(controller),
            errorView: WeakProxy(controller),
            loadingView: WeakProxy(controller),
            mapping: UIImage.tryFrom
        )
        loadingAdapter.presenter = presenter
        return controller
    }
}
