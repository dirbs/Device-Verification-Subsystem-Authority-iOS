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


class SubcribeTest: XCTestCase {

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
    
    func testSeenWithViewControllerDone(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyboard.instantiateViewController(withIdentifier: "SeenWithViewController") as! SubcribeViewController
        _ = resultViewController.view
        resultViewController.cancelBtn.sendActions(for: .touchUpInside);
        
    }
    
    func testSeenWithViewController(){
        var value = "{\"imei\":\"123456789012345\",\"stolen_status\":\"Not Stolen\",\"registration_status\":\"Registered\",\"gsma\":{\"brand\":\"Test Brand\",\"model_name\":\"Test Model\",\"model_number\":\"Test Model Number\",\"manufacturer\":\"Test Manufacturer\",\"device_type\":\"Test Device Type\",\"operating_system\":\"Test Operating System\",\"radio_access_technology\":\"Test Radio Access technology\"},\"compliant\":{\"status\":\"Test Status\",\"block_date\":\"Test Date\",\"inactivity_reasons\":[\"Test Reason 1\",\"Test Reason 2\"]}}"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyboard.instantiateViewController(withIdentifier: "SeenWithViewController") as! SubcribeViewController
        resultViewController.json = JSON(value)
        _ = resultViewController.view
        resultViewController.populateData()
        resultViewController.pupuplateDataRTL()
        resultViewController.loadMoreBtn.sendActions(for: .touchUpInside)
        resultViewController.spreadsheetView.reloadData()
        
    }
    
    func testSeenWithViewControllerLoadMore(){
        var value = "{\"imei\":\"123456789012345\",\"stolen_status\":\"Not Stolen\",\"registration_status\":\"Registered\",\"gsma\":{\"brand\":\"Test Brand\",\"model_name\":\"Test Model\",\"model_number\":\"Test Model Number\",\"manufacturer\":\"Test Manufacturer\",\"device_type\":\"Test Device Type\",\"operating_system\":\"Test Operating System\",\"radio_access_technology\":\"Test Radio Access technology\"},\"compliant\":{\"status\":\"Test Status\",\"block_date\":\"Test Date\",\"inactivity_reasons\":[\"Test Reason 1\",\"Test Reason 2\"]}}"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyboard.instantiateViewController(withIdentifier: "SeenWithViewController") as! SubcribeViewController
        resultViewController.json = JSON(value)
        _ = resultViewController.view
        resultViewController.loadMoreBtn.sendActions(for: .touchUpInside);
        
    }
    
    func testSeenWithAlertViewTitle() {
        let alertVerifier = QCOMockAlertVerifier()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyboard.instantiateViewController(withIdentifier: "SeenWithViewController") as! SubcribeViewController
        _ = resultViewController.view
        resultViewController.showErrorAlert()
        XCTAssertEqual(alertVerifier.title, "Oop!")
    }
    func testSeenWithAlertViewMessage() {
        let alertVerifier = QCOMockAlertVerifier()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyboard.instantiateViewController(withIdentifier: "SeenWithViewController") as! SubcribeViewController
        _ = resultViewController.view
        resultViewController.showErrorAlert()
        XCTAssertEqual(alertVerifier.message, "There was an error connecting to server. Please try again later.")
    }
    func testSeenWithAlertViewButton() {
        let alertVerifier = QCOMockAlertVerifier()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyboard.instantiateViewController(withIdentifier: "SeenWithViewController") as! SubcribeViewController
        _ = resultViewController.view
        //resultViewController.loadMoreBtn.sendActions(for: .touchUpInside)
        resultViewController.showErrorAlert()
        resultViewController.logout()
        resultViewController.showErrorAlert(title: "oop!", message: "There was an error connecting to server. Please try again later.")
        resultViewController.showLogoutAlert(title: "ali", message: "There was an error connecting to server. Please try again later.")
        
        XCTAssertEqual(alertVerifier.message, "There was an error connecting to server. Please try again later.")
        //alertVerifier.executeActionForButton(withTitle: "OK")
    }
    
    
    func testNetworkResponseData()
    {
        
        
        let url1 = URL(string: "http://localhost:8000/apiman-gateway/DIRBS/dvs/1.0/apiman-gateway/DIRBS/dvs/1.0/fullstatus")!
        var stub1 = StubRequest(method: .POST, url: url1)
        var response1 = StubResponse()
        let body1 = "{\n" +
            "    \"registration_status\": \"Registered\",\n" +
            "    \"stolen_status\": \"No report\",\n" +
            "    \"pairs\": {\n" +
            "        \"count\": 3,\n" +
            "        \"data\": [\n" +
            "            {\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"last_seen\": \"2017-10-31\"\n" +
            "            },\n" +
            "            {\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"last_seen\": \"2017-11-30\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"last_seen\": \"2017-11-30\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"last_seen\": \"2017-11-30\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"last_seen\": \"2017-11-30\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"last_seen\": \"2017-11-30\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"last_seen\": \"2017-11-30\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"last_seen\": \"2017-11-30\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"last_seen\": \"2017-11-30\"\n" +
            "            },\n" +
            "            {\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"last_seen\": \"2017-12-31\"\n" +
            "            }\n" +
            "        ],\n" +
            "        \"limit\": 10,\n" +
            "        \"start\": 1\n" +
            "    },\n" +
            "    \"imei\": \"12345678912345\",\n" +
            "    \"classification_state\": {\n" +
            "        \"blocking_conditions\": [],\n" +
            "        \"informative_conditions\": [\n" +
            "            {\n" +
            "                \"condition_met\": false,\n" +
            "                \"condition_name\": \"duplicate_compound\"\n" +
            "            }\n" +
            "        ]\n" +
            "    },\n" +
            "    \"gsma\": {\n" +
            "        \"brand\": \"Not Known\",\n" +
            "        \"manufacturer\": \"BlackBerry Limited\",\n" +
            "        \"model_name\": \"This is a Test IMEI to be used with multiple prototype models. The frequency bands for each model may not match what is listed in this record\",\n" +
            "        \"device_type\": \"Handheld\",\n" +
            "        \"radio_access_technology\": \"GSM 1800,GSM 900\",\n" +
            "        \"model_number\": \"This is a Test IMEI to be used with multiple prototype models. The frequency bands for each model may not match what is listed in this record\",\n" +
            "        \"operating_system\": null\n" +
            "    },\n" +
            "    \"subscribers\": {\n" +
            "        \"count\": 3,\n" +
            "        \"data\": [\n" +
            "            {\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-10-31\"\n" +
            "            },\n" +
            "            {\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-11-30\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-10-31\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-10-31\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-10-31\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-10-31\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-10-31\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-10-31\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-10-31\"\n" +
            "            },\n" +
            "\t\t\t{\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-10-31\"\n" +
            "            },\n" +
            "            {\n" +
            "                \"imsi\": \"111010000000597\",\n" +
            "                \"msisdn\": \"223000000000605\",\n" +
            "                \"last_seen\": \"2017-12-31\"\n" +
            "            }\n" +
            "        ],\n" +
            "        \"limit\": 10,\n" +
            "        \"start\": 1\n" +
            "    },\n" +
            "    \"compliant\": {\n" +
            "        \"status\": \"Compliant (Active)\"\n" +
            "    }\n" +
        "}"
        response1.body = body1.data(using: .utf8)!
        stub1.response = response1
        Hippolyte.shared.add(stubbedRequest: stub1)
        Hippolyte.shared.start()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: "ViewController") as! VerifyImeiViewController
        let _ = main.view
        
        
        
        UIApplication.shared.keyWindow?.rootViewController = main
        main.imeiTextField.insertText("123456789123456")
        main.submitButton.sendActions(for: .touchUpInside)
        
        let expectation1 = self.expectation(description: "Stubs network call")
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0, execute: {
            expectation1.fulfill()
        })
        
        waitForExpectations(timeout: 6, handler: nil)
        
        
        let inputViewController = main.presentedViewController as! TabBarViewController
        
        
        
        let result = inputViewController.childViewControllers.first as? DeviceStausViewController
        
        
        inputViewController.selectedIndex = 1
        let resultSubcribe = inputViewController.viewControllers![1] as? SubcribeViewController
        resultSubcribe?.loadMoreBtn.sendActions(for: .touchUpInside)
        resultSubcribe?.pupuplateDataRTL()
        
        let resultSubcribeIndexPath0 = IndexPath(item: 0, section: 0)
        let resultSubcribecellTitle0 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeIndexPath0) as! TitleCell
        XCTAssertEqual(resultSubcribecellTitle0.label.text, "IMSI")
        
        let resultSubcribeIndexPath1 = IndexPath(item: 1, section: 0)
        let resultSubcribecellvalue1 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeIndexPath1) as! ValueCell
        XCTAssertEqual(resultSubcribecellvalue1.label.text, "111010000000597")
        
        
        let resultSubcribeIndexPath2 = IndexPath(item: 2, section: 0)
        let resultSubcribecellvalue2 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeIndexPath2) as! ValueCell
        XCTAssertEqual(resultSubcribecellvalue2.label.text, "111010000000597")
        
        
        let resultSubcribeIndexPath3 = IndexPath(item: 3, section: 0)
        let resultSubcribecellvalue3 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeIndexPath3) as! ValueCell
        XCTAssertEqual(resultSubcribecellvalue3.label.text, "111010000000597")
        
        
        let resultSubcribeIndexPath4 = IndexPath(item: 4, section: 0)
        let resultSubcribecellvalue4 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeIndexPath4) as! ValueCell
        XCTAssertEqual(resultSubcribecellvalue4.label.text, "111010000000597")
        
        let resultSubcribeIndexPath5 = IndexPath(item: 5, section: 0)
        let resultSubcribecellvalue5 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeIndexPath5) as! ValueCell
        XCTAssertEqual(resultSubcribecellvalue5.label.text, "111010000000597")
        
        let resultSubcribeIndexPath6 = IndexPath(item: 6, section: 0)
        let resultSubcribecellvalue6 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeIndexPath6) as! ValueCell
        XCTAssertEqual(resultSubcribecellvalue6.label.text, "111010000000597")
        
        let resultSubcribeIndexPath7 = IndexPath(item: 7, section: 0)
        let resultSubcribecellvalue7 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeIndexPath7) as! ValueCell
        XCTAssertEqual(resultSubcribecellvalue7.label.text, "111010000000597")
        
        
        
        let resultSubcribeTitleIndexPath1 = IndexPath(item: 1, section: 1)
        let resultSubcribecellTitle1 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeTitleIndexPath1) as! ValueCell
        XCTAssertEqual(resultSubcribecellTitle1.label.text, "223000000000605")
        
        
        let resultSubcribeTitleIndexPath2 = IndexPath(item: 2, section: 1)
        let resultSubcribecellTitle2 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeTitleIndexPath2) as! ValueCell
        XCTAssertEqual(resultSubcribecellTitle2.label.text, "223000000000605")
        
        resultSubcribe?.cancelBtn.sendActions(for: .touchUpInside)
        
        
        
        let resultSubcribeTitleIndexPath3 = IndexPath(item: 3, section: 1)
        let resultSubcribecellTitle3 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeTitleIndexPath3) as! ValueCell
        XCTAssertEqual(resultSubcribecellTitle3.label.text, "223000000000605")
        
        
        let resultSubcribeTitleIndexPath4 = IndexPath(item: 4, section: 1)
        let resultSubcribecellTitle4 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeTitleIndexPath4) as! ValueCell
        XCTAssertEqual(resultSubcribecellTitle4.label.text, "223000000000605")
        
        
        let resultSubcribeTitleIndexPath5 = IndexPath(item: 1, section: 1)
        let resultSubcribecellTitle5 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeTitleIndexPath5) as! ValueCell
        XCTAssertEqual(resultSubcribecellTitle5.label.text, "223000000000605")
        
        let resultSubcribeTitleIndexPath6 = IndexPath(item: 6, section: 1)
        let resultSubcribecellTitle6 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeTitleIndexPath6) as! ValueCell
        XCTAssertEqual(resultSubcribecellTitle6.label.text, "223000000000605")
        
        
        let resultSubcribeTitleIndexPath7 = IndexPath(item: 7, section: 1)
        let resultSubcribecellTitle7 = resultSubcribe?.spreadsheetView((resultSubcribe?.spreadsheetView)!, cellForItemAt: resultSubcribeTitleIndexPath7) as! ValueCell
        XCTAssertEqual(resultSubcribecellTitle7.label.text, "223000000000605")
        
        
        
        
        
    }


}
