/**
 *  Copyright (c) 2018-2019 Qualcomm Technologies, Inc.
 * All rights reserved.
 *  Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of Qualcomm Technologies, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment is required by displaying the trademark/log as per the details provided here: [https://www.qualcomm.com/documents/dirbs-logo-and-brand-guidelines]
 * Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * This notice may not be removed or altered from any source distribution.
 NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest
@testable import DVS
import BarcodeScanner
import UIKit
import ReCaptcha
import SwiftyJSON
import Moya
import MockUIAlertController
import Hippolyte


class ProfileTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //    Profile tab
    func testLogoutButtonClick() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: "ProfileController") as! ProfileViewController
        let _ = main.view
        main.logoutButton.sendActions(for: .touchUpInside)
    }
    func testProfileLabels() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: "ProfileController") as! ProfileViewController
        let _ = main.view
        let userDefaults = UserDefaults.standard
        
        var fullNametxt = userDefaults.object(forKey: "FullName") as? String
        var usernametxt = userDefaults.object(forKey: "Username") as? String
        var emailtxt = userDefaults.object(forKey: "Email") as? String
        
        if fullNametxt == nil {
            fullNametxt = "-"
        }
        if usernametxt == nil {
            usernametxt = "-"
        }
        if emailtxt == nil {
            emailtxt = "-"
        }
        
        XCTAssertEqual(main.fullName.text, fullNametxt)
        XCTAssertEqual(main.userName.text, usernametxt)
        XCTAssertEqual(main.email.text, emailtxt)
        
    }

}
