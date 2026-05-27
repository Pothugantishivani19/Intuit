// Copyright © 2021 Intuit, Inc. All rights reserved.

import XCTest
@testable import Cat_Demo

class Cat_DemoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchCatImage() {
    
        let handlerExpectation = expectation(description: "waiter")
        
        Network.fetchCatImage(breedId: "amis") { (result) in
            switch result {
            case .success(let details):
                print("\(details)")
                
                handlerExpectation.fulfill()
                break
                
            case .failure(let error):
                print("\(error)")
                XCTFail()
            }
        }
        
        let result = XCTWaiter().wait(for: [handlerExpectation], timeout: 5)
        XCTAssert(result == .completed)
    }

}
