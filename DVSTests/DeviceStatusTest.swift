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


class DeviceStatusTest: XCTestCase {

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
    
    func testDeviceStatusPopulateData(){
        var value = "{\"imei\":\"123456789012345\",\"stolen_status\":\"Not Stolen\",\"registration_status\":\"Registered\",\"gsma\":{\"brand\":\"Test Brand\",\"model_name\":\"Test Model\",\"model_number\":\"Test Model Number\",\"manufacturer\":\"Test Manufacturer\",\"device_type\":\"Test Device Type\",\"operating_system\":\"Test Operating System\",\"radio_access_technology\":\"Test Radio Access technology\"},\"compliant\":{\"status\":\"Test Status\",\"block_date\":\"Test Date\",\"inactivity_reasons\":[\"Test Reason 1\",\"Test Reason 2\"]}}"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as! DeviceStausViewController
        resultViewController.json = JSON(value)
        _ = resultViewController.view
        resultViewController.populateData()
        resultViewController.pupulateDataRtl()
        resultViewController.spreadsheetView.reloadData()
        
    }
    func testDeviceStatusDone(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as! DeviceStausViewController
        _ = resultViewController.view
        resultViewController.cancelBtn.sendActions(for: .touchUpInside);
        
        
    }
    
    func testCells(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultViewController = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as! DeviceStausViewController
        _ = resultViewController.view
        
        var titleCell = TitleCell()
        var valueCell = ValueCell()
        var blankCell = BlankCell()
        var slotCell = SlotCell()
        resultViewController.spreadsheetView.register(TitleCell.self, forCellWithReuseIdentifier: String(describing: TitleCell.self))
        resultViewController.spreadsheetView.register(ValueCell.self, forCellWithReuseIdentifier: String(describing: ValueCell.self))
        resultViewController.spreadsheetView.register(BlankCell.self, forCellWithReuseIdentifier: String(describing: BlankCell.self))
        resultViewController.spreadsheetView.register(SlotCell.self, forCellWithReuseIdentifier: String(describing: SlotCell.self))
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
        
        
        let resultIndexPath0 = IndexPath(item: 0, section: 0)
        let resultcellTitle0 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath0) as! TitleCell
        XCTAssertEqual(resultcellTitle0.label.text, "IMEI")
        result?.done()
        
        
        
        let resultIndexPath1 = IndexPath(item: 1, section: 0)
        let resultcellTitle1 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath1) as! TitleCell
        XCTAssertEqual(resultcellTitle1.label.text, "IMEI Compliance Status")
        
        
        let resultIndexPath2 = IndexPath(item: 2, section: 0)
        let resultcellTitle2 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath2) as! TitleCell
        XCTAssertEqual(resultcellTitle2.label.text, "Brand")
        
        
        let resultIndexPath3 = IndexPath(item: 3, section: 0)
        let resultcellTitle3 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath3) as! TitleCell
        XCTAssertEqual(resultcellTitle3.label.text, "Model Name")
        
        
        
        let resultIndexPath4 = IndexPath(item: 4, section: 0)
        let resultcellTitle4 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath4) as! TitleCell
        XCTAssertEqual(resultcellTitle4.label.text, "Model Number")
        
        
        
        
        let resultIndexPath5 = IndexPath(item: 5, section: 0)
        let resultcellTitle5 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath5) as! TitleCell
        XCTAssertEqual(resultcellTitle5.label.text, "Manufacturer")
        
        
        let resultIndexPath6 = IndexPath(item: 6, section: 0)
        let resultcellTitle6 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath6) as! TitleCell
        XCTAssertEqual(resultcellTitle6.label.text, "Device Type")
        
        
        let resultIndexPath7 = IndexPath(item: 7, section: 0)
        let resultcellTitle7 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath7) as! TitleCell
        XCTAssertEqual(resultcellTitle7.label.text, "Operating System")
        
        
        let resultIndexPath8 = IndexPath(item: 8, section: 0)
        let resultcellTitle8 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath8) as! TitleCell
        XCTAssertEqual(resultcellTitle8.label.text, "Radio Access Technology")
        
        
        let resultIndexPath9 = IndexPath(item: 9, section: 0)
        let resultcellTitle9 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath9) as! TitleCell
        XCTAssertEqual(resultcellTitle9.label.text, "Registration Status")
        
        
        
        let resultIndexPath10 = IndexPath(item: 10, section: 0)
        let resultcellTitle10 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath10) as! TitleCell
        XCTAssertEqual(resultcellTitle10.label.text, "Lost/Stolen Status")
        
        
        
        let resultIndexPath11 = IndexPath(item: 11, section: 0)
        let resultcellTitle11 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath11) as! TitleCell
        XCTAssertEqual(resultcellTitle11.label.text, "Block as of Date")
        
        let resultIndexPath12 = IndexPath(item: 12, section: 0)
        let resultcellTitle12 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath12) as! TitleCell
        XCTAssertEqual(resultcellTitle12.label.text, "Per Condition Classification State")
        
        
        let resultIndexPath13 = IndexPath(item: 13, section: 0)
        let resultcellTitle13 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath13) as! ValueCell
        XCTAssertEqual(resultcellTitle13.label.text, "N/A")
        
        let resultIndexPath14 = IndexPath(item: 14, section: 0)
        let resultcellTitle14 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath14) as! TitleCell
        XCTAssertEqual(resultcellTitle10.label.text, "Lost/Stolen Status")
        
        
        let resultIndexPath15 = IndexPath(item: 15, section: 0)
        let resultcellTitle15 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPath15) as! TitleCell
        XCTAssertEqual(resultcellTitle15.label.text, "duplicate_compound")
        
        
        
        let resultIndexPathValue = IndexPath(item: 0, section: 1)
        let resultcellValue = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue) as! ValueCell
        XCTAssertEqual(resultcellValue.label.text, "12345678912345")
        
        let resultIndexPathValue1 = IndexPath(item: 1, section: 1)
        let resultcellValue1 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue1) as! ValueCell
        XCTAssertEqual(resultcellValue1.label.text, "Compliant (Active)")
        
        
        let resultIndexPathValue2 = IndexPath(item: 2, section: 1)
        let resultcellValue2 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue2) as! ValueCell
        XCTAssertEqual(resultcellValue2.label.text, "Not Known")
        
        let resultIndexPathValue3 = IndexPath(item: 3, section: 1)
        let resultcellValue3 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue3) as! ValueCell
        XCTAssertEqual(resultcellValue3.label.text, "This is a Test IMEI to be used with multiple prototype models. The frequency bands for each model may not match what is listed in this record")
        
        let resultIndexPathValue4 = IndexPath(item: 4, section: 1)
        let resultcellValue4 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue4) as! ValueCell
        XCTAssertEqual(resultcellValue4.label.text, "This is a Test IMEI to be used with multiple prototype models. The frequency bands for each model may not match what is listed in this record")
        
        let resultIndexPathValue5 = IndexPath(item: 5, section: 1)
        let resultcellValue5 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue5) as! ValueCell
        XCTAssertEqual(resultcellValue5.label.text, "BlackBerry Limited")
        
        
        let resultIndexPathValue6 = IndexPath(item: 6, section: 1)
        let resultcellValue6 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue6) as! ValueCell
        XCTAssertEqual(resultcellValue6.label.text, "Handheld")
        
        
        let resultIndexPathValue7 = IndexPath(item: 7, section: 1)
        let resultcellValue7 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue7) as! ValueCell
        XCTAssertEqual(resultcellValue7.label.text, "N/A")
        result?.cancelBtn.sendActions(for: .touchUpInside)
        result?.pupulateDataRtl()
        
        
        let resultIndexPathValue8 = IndexPath(item: 8, section: 1)
        let resultcellValue8 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue8) as! ValueCell
        XCTAssertEqual(resultcellValue8.label.text, "GSM 1800,GSM 900")
        
        
        let resultIndexPathValue9 = IndexPath(item: 9, section: 1)
        let resultcellValue9 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue9) as! ValueCell
        XCTAssertEqual(resultcellValue9.label.text, "Registered")
        
        
        let resultIndexPathValue10 = IndexPath(item: 10, section: 1)
        let resultcellValue10 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue10) as! ValueCell
        XCTAssertEqual(resultcellValue10.label.text, "No report")
        
        
        
        let resultIndexPathValue11 = IndexPath(item: 11, section: 1)
        let resultcellValue11 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue11) as! ValueCell
        XCTAssertEqual(resultcellValue11.label.text, "N/A")
        
        
        let resultIndexPathValue12 = IndexPath(item: 12, section: 1)
        let resultcellValue12 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue12) as! ValueCell
        XCTAssertEqual(resultcellValue12.label.text, "")
        
        
        let resultIndexPathValue13 = IndexPath(item: 13, section: 1)
        let resultcellValue13 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue13) as! ValueCell
        XCTAssertEqual(resultcellValue13.label.text, "")
        
        let resultIndexPathValue14 = IndexPath(item: 14, section: 1)
        let resultcellValue14 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue14) as! ValueCell
        XCTAssertEqual(resultcellValue14.label.text, "")
        
        let resultIndexPathValue15 = IndexPath(item: 15, section: 1)
        let resultcellValue15 = result?.spreadsheetView((result?.spreadsheetView)!, cellForItemAt: resultIndexPathValue15) as! ValueCell
        XCTAssertEqual(resultcellValue15.label.text, "false")
        
        
        
    }

}
