//
//  SceneDelegate.swift
//  Pokepedia-iOS-App
//
//  Created by Василий Клецкин on 5/26/23.
//

import UIKit
import Pokepedia_iOS
import Pokepedia
import Combine
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private let baseUrl = URL(string: "http://127.0.0.1:8080")!
    
    private let storeUrl = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
    
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "klyotskin.pokepedia.infra.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private let navigationController = UINavigationController()
    
    lazy var httpClient: HTTPClient = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        let client = URLSessionHTTPClient(session: session)
        return client
    }()
    
    lazy var store: PokemonListStore & ImageStore = {
        do {
            return try CoreDataPokemonListStore(storeUrl: storeUrl)
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return InMemoryPokemonListStore()
        }
    }()
    
    lazy var detail: PokemonListStore & ImageStore = {
        do {
            return try CoreDataPokemonListStore(storeUrl: storeUrl)
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return InMemoryPokemonListStore()
        }
    }()
    
    convenience init(
        scheduler: AnyDispatchQueueScheduler,
        store: PokemonListStore & ImageStore,
        httpClient: HTTPClient
    ) {
        self.init()
        self.scheduler = scheduler
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        try? LocalPokemonListLoader(store: store).validateCache()
    }
    
    func configureWindow() {
        let pokemonList = PokemonListFeatureComposer(
            scheduler: scheduler,
            baseUrl: baseUrl,
            store: store,
            httpClient: httpClient
        ).compose(onItemSelected: navigateToDetail)
        navigationController.viewControllers = [pokemonList]
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func navigateToDetail(from listItem: PokemonListItem) {
        let pokemonDetail = PokemonDetailFeatureComposer(
            scheduler: scheduler,
            baseUrl: baseUrl,
            httpClient: httpClient
        ).compose(for: listItem)
        navigationController.pushViewController(pokemonDetail, animated: true)
    }
}
