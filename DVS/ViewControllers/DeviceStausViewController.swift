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

import UIKit
import SpreadsheetView
import SwiftyJSON

class DeviceStausViewController: UIViewController, SpreadsheetViewDataSource {
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    var state: State?
    var json: JSON!
    var resultStatus = [String: [String]]()
    var rowToMerge = 0
    var resultRowsToMerge: [Int] = []
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    var labels = [
        "IMEI".localized(),
        "IMEI Compliance Status".localized(),
        "Brand".localized(),
        "Model Name".localized(),
        "Model Number".localized(),
        "Manufacturer".localized(),
        "Device Type".localized(),
        "Operating System".localized(),
        "Radio Access Technology".localized(),
        "Registration Status".localized(),
        "Lost/Stolen Status".localized(),
        "Block as of Date".localized()
    ]
    var labelValues = [
        "123456789012345".localized(),
        "Samsung".localized(),
        "Galaxy".localized(),
        "S6".localized(),
        "Samsung China".localized(),
        "Smart Phone".localized(),
        "Android".localized(),
        "GSMA CDMA".localized(),
        "Compliance (Active)".localized(),
        "N/A".localized(),
        "N/A".localized(),
        "N/A".localized()
    ]
    
    
     var langStr = ""
   
    
    var slotInfo = [IndexPath: (Int, Int)]()
    
    let hourFormatter = DateFormatter()
    let twelveHourFormatter = DateFormatter()
  
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
       
        langStr = Locale.current.languageCode!
        print("CurrentLanguage= \(langStr)")
        
        if(UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
        {
            labelValues.removeAll()
            labels.removeAll()
            
            labelValues.append("IMEI".localized())
            labelValues.append("IMEI Compliance Status".localized())
            labelValues.append("Brand".localized())
            labelValues.append("Model Name".localized())
            labelValues.append("Model Number".localized())
            labelValues.append("Manufacturer".localized())
            labelValues.append("Device Type".localized())
            labelValues.append("Operating System".localized())
            labelValues.append("Radio Access Technology".localized())
            labelValues.append("Registration Status".localized())
            labelValues.append("Lost/Stolen Status".localized())
            labelValues.append("Block as of Date".localized())
            
            
            labels.append("123456789012345".localized())
            labels.append("Samsung".localized())
            labels.append("Galaxy".localized())
            labels.append("S6".localized())
            labels.append("Samsung China".localized())
            labels.append("Smart Phone".localized())
            labels.append("Android".localized())
            labels.append("GSMA CDMA".localized())
            labels.append("Compliance (Active)".localized())
            labels.append("N/A".localized())
            labels.append("N/A".localized())
            labels.append("N/A".localized())

            

            print(labelValues)
            //populateData()
            pupulateDataRtl()

            
           
            
        }
            
        else{
            
           
            
             populateData()
             //pupulatedataAr()
            
            
            //lastSeen.append("Last Seen".localized())
            
        }
        
        titleLabel.text = "Device Status".localized()
        spreadsheetView.dataSource = self
        //        spreadsheetView.delegate = self s! SpreadsheetViewDelegate
        
        spreadsheetView.register(TitleCell.self, forCellWithReuseIdentifier: String(describing: TitleCell.self))
        spreadsheetView.register(ValueCell.self, forCellWithReuseIdentifier: String(describing: ValueCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: SlotCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SlotCell.self))
        spreadsheetView.register(BlankCell.self, forCellWithReuseIdentifier: String(describing: BlankCell.self))
        
        spreadsheetView.backgroundColor = .white
        
        let hairline = 1 / UIScreen.main.scale
        spreadsheetView.intercellSpacing = CGSize(width: hairline, height: hairline)
        spreadsheetView.gridStyle = .solid(width: hairline, color: .lightGray)
        spreadsheetView.circularScrolling =
            CircularScrolling.Configuration.none
        
        print("device status result=\(labelValues)")
        
        
        
    }
    @IBAction func cancelBtnLIstener(_ sender: Any) {
        self.dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 2
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return labelValues.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {

        let width = (((UIScreen.main.bounds.width-30)/2)-4)
      
        return width
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        var height:CGFloat = 40
        
 
        if(UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
        {
    
    if labels[row].count > 40{
        height = CGFloat(Double(labels[row].count) * 1.5)
    }
    
        }
        
 else{
    if labelValues[row].count > 40{
                    height = CGFloat(Double(labelValues[row].count) * 1.5)
               }
    
        }
    

    
        return height
    }   
  
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        
        print(indexPath.row)
        
        if indexPath.column == 0 {
            
            if labels[indexPath.row] == "N/A".localized() && labelValues[indexPath.row] == "" {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ValueCell.self), for: indexPath) as! ValueCell
                
                
                cell.label.text = labels[indexPath.row]
               
               
                
                cell.gridlines.top = .solid(width: 1, color: .black)
                cell.gridlines.bottom = .solid(width: 1, color: .black)
                cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
                cell.gridlines.right = cell.gridlines.left
                return cell
            }
            else{
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TitleCell.self), for: indexPath) as! TitleCell
                
                cell.label.text = labels[indexPath.row]
                
                cell.gridlines.top = .solid(width: 1, color: .black)
                cell.gridlines.bottom = .solid(width: 1, color: .black)
                cell.gridlines.left = .solid(width: 1, color: .black)
                return cell
            }
            
        }
        if indexPath.column == 1 {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ValueCell.self), for: indexPath) as! ValueCell
            
            cell.label.text = labelValues[indexPath.row]
            var a = labelValues[indexPath.row] as! String
        
            
            cell.gridlines.top = .solid(width: 1, color: .black)
            cell.gridlines.bottom = .solid(width: 1, color: .black)
            cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
            cell.gridlines.right = cell.gridlines.left
           
            return cell
        }
      
        return spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: BlankCell.self), for: indexPath)
    }
    @objc func done() { // remove @objc for Swift 3
        dismiss(animated: true)
    }   
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.done()
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if case 0 = indexPath.row {
           print("load more ")
            spreadsheetView.reloadData()
        }
    }
    func populateData(){
        
        
      
        
        
        if(self.json != nil)
        {
        print("JSON: \(json!)")
            
        
            
        // imei from resuult
        if let imeiNumber = json["imei"].string {
            // imei found in the result
            print(imeiNumber)
            self.labelValues[0] = imeiNumber
        } else {
            // imei not founc in the result
            self.labelValues[0] = "N/A".localized()
        }
            
        // status from result
        if let status = json["compliant"]["status"].string {
            // model_name found in the result
            self.labelValues[1] = status
            print(status)
        } else {
            // model_name not founc in the result
            self.labelValues[1] = "N/A".localized()
        }
        
        // brand from result
        
        if let brand = json["gsma"]["brand"].string {
            // brand found in the result
            self.labelValues[2] = brand
            print(brand)
        } else {
            // brand not founc in the result
            self.labelValues[2] = "N/A".localized()
        }
        
        // model_name from result
        if let model = json["gsma"]["model_name"].string {
            // model_name found in the result
            self.labelValues[3] = model
        } else {
            // model_name not founc in the result
            self.labelValues[3] = "N/A".localized()
        }
        
        // model_number from result
        if let modelNumber = json["gsma"]["model_number"].string {
            // model_number found in the result
            self.labelValues[4] = modelNumber
        } else {
            // model_number not founc in the result
            self.labelValues[4] = "N/A".localized()
        }
        
        // manufacturer from result
        if let manufacturer = json["gsma"]["manufacturer"].string {
            // manufacturer found in the result
            self.labelValues[5] = manufacturer
        } else {
            // manufacturer not founc in the result
            self.labelValues[5] = "N/A".localized()
        }
        
        // device_type from result
        if let deviceType = json["gsma"]["device_type"].string {
            // device_type found in the result
            self.labelValues[6] = deviceType
        } else {
            // device_type not founc in the result
            self.labelValues[6] = "N/A".localized()
        }
        
        // operating_system from result
        if let operatingSystem = json["gsma"]["operating_system"].string {
            // operating_system found in the result
            self.labelValues[7] = operatingSystem
        } else {
            // operating_system not founc in the result
            self.labelValues[7] = "N/A".localized()
        }
        
        // radio_access_technology from result
        if let radioAccessTechnology = json["gsma"]["radio_access_technology"].string {
            // radio_access_technology found in the result
            self.labelValues[8] = radioAccessTechnology
        } else {
            // radio_access_technology not founc in the result
            self.labelValues[8] = "N/A".localized()
        }
        
        // registration_status from result
        if let registrationStatus = json["registration_status"].string {
            // registration_status found in the result
            self.labelValues[9] = registrationStatus
        } else {
            // registration_status not founc in the result
            self.labelValues[9] = "N/A".localized()
        }
        
        // stolen_status from result
        if let stolenStatus = json["stolen_status"].string {
            // model_name found in the result
            self.labelValues[10] = stolenStatus
        } else {
            // model_name not founc in the result
            self.labelValues[10] = "N/A".localized()
        }
        
        // block_date from result
        if let blockDate = json["compliant"]["block_date"].string {
            // block_date found in the result
            self.labelValues[11] = blockDate
        } else {
            // block_date not founc in the result
            self.labelValues[11] = "N/A".localized()
        }
        if labels.count < 13 
        {
            
           
        //TO POPULATE Classification State
        if let items = json["classification_state"]["blocking_conditions"].array {
                // inactivity_reasons found in the result
            
                self.labels.append("Per Condition Classification State".localized())
               self.labelValues.append("")
            if items.isEmpty {
                self.labels.append("N/A".localized())
                self.labelValues.append("")
                resultRowsToMerge.append((labels.count-1))
            }
                for item in items {
                    if let labelEl = item["condition_name"].string {
                        self.labels.append(labelEl)
                    }
                    else{
                        self.labels.append("N/A".localized())
                        
                    }
                    if let labelValueEl = item["condition_met"].bool {
                        self.labelValues.append(labelValueEl.description)
                    }
                    else{
                        self.labelValues.append("N/A".localized())
                    }
                    
                }
                
            }
            //TO POPULATE Informative Conditions
            if let items = json["classification_state"]["informative_conditions"].array {
                // inactivity_reasons found in the result
                
                    //self.labels.append("IMEI Per Informational Condition".localized())
                    //self.labelValues.append("")
                //rowToMerge = (labels.count - 1)
                if items.isEmpty {
                    self.labels.append("N/A".localized())
                    self.labelValues.append("")
                    resultRowsToMerge.append((labels.count - 1))
                }
                
                for item in items {
                    if let labelEl = item["condition_name"].string {
                        self.labels.append(labelEl)
                    }
                    else{
                        self.labels.append("N/A".localized())
                    }
                    if let labelValueEl = item["condition_met"].bool {
                        self.labelValues.append(labelValueEl.description)
                    }
                    else{
                        self.labelValues.append("N/A".localized())
                    }
                    
                }
                
            }
            }
        
        }
        
      
        print("label value=\(labels)")
        print("label value2=\(labelValues)")
    }
    
    func pupulateDataRtl()
    {
        
        if(self.json != nil)
        {
            print("JSON: \(json!)")
            
            
            
            // imei from resuult
            if let imeiNumber = json["imei"].string {
                // imei found in the result
                print(imeiNumber)
                self.labels[0] = imeiNumber
            } else {
                // imei not founc in the result
                self.labels[0] = "N/A".localized()
            }
            
            // status from result
            if let status = json["compliant"]["status"].string {
                // model_name found in the result
                self.labels[1] = status
                print(status)
            } else {
                // model_name not founc in the result
                self.labels[1] = "N/A".localized()
            }
            
            // brand from result
            
            if let brand = json["gsma"]["brand"].string {
                // brand found in the result
                self.labels[2] = brand
                print(brand)
            } else {
                // brand not founc in the result
                self.labels[2] = "N/A".localized()
            }
            
            // model_name from result
            if let model = json["gsma"]["model_name"].string {
                // model_name found in the result
                self.labels[3] = model
            } else {
                // model_name not founc in the result
                self.labels[3] = "N/A".localized()
            }
            
            // model_number from result
            if let modelNumber = json["gsma"]["model_number"].string {
                // model_number found in the result
                self.labels[4] = modelNumber
            } else {
                // model_number not founc in the result
                self.labels[4] = "N/A".localized()
            }
            
            // manufacturer from result
            if let manufacturer = json["gsma"]["manufacturer"].string {
                // manufacturer found in the result
                self.labels[5] = manufacturer
            } else {
                // manufacturer not founc in the result
                self.labels[5] = "N/A".localized()
            }
            
            // device_type from result
            if let deviceType = json["gsma"]["device_type"].string {
                // device_type found in the result
                self.labels[6] = deviceType
            } else {
                // device_type not founc in the result
                self.labels[6] = "N/A".localized()
            }
            
            // operating_system from result
            if let operatingSystem = json["gsma"]["operating_system"].string {
                // operating_system found in the result
                self.labels[7] = operatingSystem
            } else {
                // operating_system not founc in the result
                self.labels[7] = "N/A".localized()
            }
            
            // radio_access_technology from result
            if let radioAccessTechnology = json["gsma"]["radio_access_technology"].string {
                // radio_access_technology found in the result
                self.labels[8] = radioAccessTechnology
            } else {
                // radio_access_technology not founc in the result
                self.labels[8] = "N/A".localized()
            }
            
            // registration_status from result
            if let registrationStatus = json["registration_status"].string {
                // registration_status found in the result
                self.labels[9] = registrationStatus
            } else {
                // registration_status not founc in the result
                self.labels[9] = "N/A".localized()
            }
            
            // stolen_status from result
            if let stolenStatus = json["stolen_status"].string {
                // model_name found in the result
                self.labels[10] = stolenStatus
            } else {
                // model_name not founc in the result
                self.labels[10] = "N/A".localized()
            }
            
            // block_date from result
            if let blockDate = json["compliant"]["block_date"].string {
                // block_date found in the result
                self.labels[11] = blockDate
            } else {
                // block_date not founc in the result
                self.labels[11] = "N/A".localized()
            }
            if labels.count < 13
            {
                
                
                //TO POPULATE Classification State
                if let items = json["classification_state"]["blocking_conditions"].array {
                    // inactivity_reasons found in the result
                    
                    self.labels.append("Per Condition Classification State".localized())
                    self.labelValues.append("")
                    if items.isEmpty {
                        self.labels.append("N/A".localized())
                        self.labelValues.append("")
                        resultRowsToMerge.append((labels.count-1))
                    }
                    for item in items {
                        if let labelEl = item["condition_name"].string {
                            self.labelValues.append(labelEl)
                        }
                        else{
                            self.labelValues.append("N/A".localized())
                            
                        }
                        if let labelValueEl = item["condition_met"].bool {
                            self.labels.append(labelValueEl.description)
                        }
                        else{
                            self.labels.append("N/A".localized())
                        }
                        
                    }
                    
                }
                //TO POPULATE Informative Conditions
                if let items = json["classification_state"]["informative_conditions"].array {
                
                    if items.isEmpty {
                        self.labels.append("N/A".localized())
                        self.labelValues.append("")
                        resultRowsToMerge.append((labels.count - 1))
                    }
                    
                    for item in items {
                        if let labelEl = item["condition_name"].string {
                            self.labelValues.append(labelEl)
                        }
                        else{
                            self.labelValues.append("N/A".localized())
                        }
                        if let labelValueEl = item["condition_met"].bool {
                            self.labels.append(labelValueEl.description)
                        }
                        else{
                            self.labels.append("N/A".localized())
                        }
                        
                    }
                    
                }
            }
            
        
            
        }
        
       // print("label value=\(labelValues)")
        
        print("label value=\(labels)")
         print("label value2=\(labelValues)")
        
        
        
        
    }
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        var cellRange = [CellRange(from: (row: 12, column: 0), to: (row: 12, column: 1))]
        print("rowToMerge \(rowToMerge) ")
        if rowToMerge > 0 {
            cellRange.append(CellRange(from: (row: rowToMerge, column: 0), to: (row: rowToMerge, column: 1)))
        }
        for i in resultRowsToMerge {
            cellRange.append(CellRange(from: (row: i, column: 0), to: (row: i, column: 1)))
        }
        return cellRange
    }
   
    
    
}
