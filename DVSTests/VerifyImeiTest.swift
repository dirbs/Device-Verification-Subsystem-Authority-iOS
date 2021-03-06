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



class VerifyImeiTest: XCTestCase {

    
    var  verifyImei : VerifyImeiViewController!
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

    
    
    func getVerifyViwcontroller()
    {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SeenWithViewController") as! VerifyImeiViewController
        
        
        verifyImei = vc
        verifyImei = vc
        let _ = verifyImei.view
    }
    func testImeiPlaceholder() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        
        let _ = mainViewController.view
        XCTAssertEqual("Enter Imei", mainViewController.imeiTextField!.attributedPlaceholder?.string)
    }
    func testImeiLength() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        let _ = main.view
        main.imeiTextField.insertText("123456")
        XCTAssertEqual("IMEI must be 14 to 16 characters long", main.imeiTextField!.errorMessage)
    }
    func testImeiAlpha() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        let _ = main.view
        main.imeiTextField.insertText("123456asdfghjk")
        XCTAssertEqual("IMEI must contain A-F, a-f and 0-9 only", main.imeiTextField!.errorMessage)
    }
    func testButtonClick() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        let _ = main.view
        main.submitButton.sendActions(for: .touchUpInside)
    }
    func testScanButtonClick() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        let _ = main.view
        main.scanButton.sendActions(for: .touchUpInside)
    }
    func testParseJson(){
        var value = "{\"imei\":\"123456789012345\",\"stolen_status\":\"Not Stolen\",\"registration_status\":\"Registered\",\"gsma\":{\"brand\":\"Test Brand\",\"model_name\":\"Test Model\",\"model_number\":\"Test Model Number\",\"manufacturer\":\"Test Manufacturer\",\"device_type\":\"Test Device Type\",\"operating_system\":\"Test Operating System\",\"radio_access_technology\":\"Test Radio Access technology\"},\"compliant\":{\"status\":\"Test Status\",\"block_date\":\"Test Date\",\"inactivity_reasons\":[\"Test Reason 1\",\"Test Reason 2\"]}}"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        let _ = main.view
        main.jsonResult = JSON(value)
        main.performResultSeige()
        
        
    }
    
    func testMainAlertViewTitle() {
        let alertVerifier = QCOMockAlertVerifier()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        let _ = mainViewController.view
        mainViewController.showErrorAlert(title: "oop!",message: "There was an error connecting to server. Please try again later.")
        XCTAssertEqual(alertVerifier.title, "oop!")
        
        XCTAssertEqual(alertVerifier.message, "There was an error connecting to server. Please try again later.")
        
        //alertVerifier.executeActionForButton(withTitle: "ok")
    }
    func testMainAlertViewMessage() {
        let alertVerifier = QCOMockAlertVerifier()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        let _ = mainViewController.view
        mainViewController.showLogoutAlert(title: "oop!", message: "Your session has expired. Please login again to continue using DVS")
        XCTAssertEqual(alertVerifier.message, "Your session has expired. Please login again to continue using DVS")
        mainViewController.logout()
    }
    func testMainAlertViewButton() {
        let alertVerifier = QCOMockAlertVerifier()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        let _ = mainViewController.view
        // mainViewController.showErrorAlert()
        // alertVerifier.executeActionForButton(withTitle: "OK")
    }
    
    func testForScanBtn()
        
    {
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        let _ = mainViewController.view
        mainViewController.scanner(mainViewController.viewController, didCaptureCode: "123456", type: "123456")
        XCTAssertEqual(mainViewController.imeiTextField.text, "123456")
        
        
    }

}
