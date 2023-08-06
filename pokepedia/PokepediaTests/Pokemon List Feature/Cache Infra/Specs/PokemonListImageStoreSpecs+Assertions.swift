//
//  PokemonListImageStoreSpecs+Assertions.swift
//  PokepediaTests
//
//  Created by Василий Клецкин on 8/6/23.
//

import XCTest
import Pokepedia

extension PokemonListImageStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveImageDataDeliversNotFoundWhenEmpty(
        _ sut: PokemonListImageStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL(), file: file, line: line)
    }
    
    func assertThatRetrieveImageDataDeliversNotFoundWhenStoredDataURLDoesNotMatch(
        _ sut: PokemonListImageStore,
        imageUrl: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let nonMatchingURL = URL(string: "http://another-url\(UUID().uuidString).com")!
        
        try? sut.insertImage(data: anyData(), for: imageUrl)
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL, file: file, line: line)
    }
    
    func assertThatRetrieveImageDataDeliversFoundDataWhenThereIsAStoredImageDataMatchingURL(
        _ sut: PokemonListImageStore,
        imageUrl matchingUrl: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let storedData = anyData()

        try? sut.insertImage(data: storedData, for: matchingUrl)

        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingUrl, file: file, line: line)
    }
    
    func assertThatRetrieveImageDataDeliversLastInsertedValue(
        _ sut: PokemonListImageStore,
        imageUrl url: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        
        try? sut.insertImage(data: firstStoredData, for: url)
        try? sut.insertImage(data: lastStoredData, for: url)

        expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url, file: file, line: line)
    }
    
    // MARK: - Helpers
    
    private func notFound() -> Result<Data?, Error> {
        return .success(.none)
    }
    
    private func found(_ data: Data) -> Result<Data?, Error> {
        return .success(data)
    }
}
