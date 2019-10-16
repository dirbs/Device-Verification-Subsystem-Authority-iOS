/**
 * Copyright (c) 2018 Qualcomm Technologies, Inc.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of Qualcomm Technologies, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import SpreadsheetView
import SwiftyJSON
import Material
import Moya

class Paired1ViewController: UIViewController, SpreadsheetViewDataSource {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    var resultStatus = [String: [String]]()
    var json: JSON!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadMoreBtn: FlatButton!
    @IBOutlet weak var noRecordFound: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    var imsi = [String]()
    var lastSeen = [String]()
  
    
    var slotInfo = [IndexPath: (Int, Int)]()
    
    let hourFormatter = DateFormatter()
    let twelveHourFormatter = DateFormatter()
    var langStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        changeLanguage()
        populateData()
        activityIndicator.isHidden = true
        noRecordFound.text = "No record found".localized()
        titleLabel.text = "Paired Subscribers".localized()
        loadMoreBtn.title = "Load More".localized()
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
        spreadsheetView.circularScrolling = CircularScrolling.Configuration.none
        print(spreadsheetView.numberOfRows)
        
        
    }
    
    func changeLanguage()
    {
        langStr = Locale.current.languageCode!
        print("CurrentLanguage= \(langStr)")
        if(langStr == "ar")
        {
            lastSeen.append("IMSI".localized())
            imsi.append("Last Seen".localized())
            
        }
            
        else{
            
            imsi.append("IMSI".localized())
            lastSeen.append("Last Seen".localized())
            
        }
        
        
    }
    
    
    
    @IBAction func loadMoreBtnListener(_ sender: Any) {
        
        nextPage()
    }
    @IBAction func cancelBtnListener(_ sender: Any) {
        self.parent?.dismiss(animated: true)
    }
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 2
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return imsi.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        let width = (((UIScreen.main.bounds.width-32)/2)-4)
        return width
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        let height:CGFloat = 40
        
//        if labelValues[row].count > 40{
//            height = CGFloat(Double(labelValues[row].count) * 1.2)
//        }
        return height
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        
        print(indexPath.row)
        
        if indexPath.column == 0 {
            if indexPath.row == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TitleCell.self), for: indexPath) as! TitleCell
                
                cell.label.text = imsi[indexPath.row]
                
                cell.gridlines.top = .solid(width: 1, color: .black)
                cell.gridlines.bottom = .solid(width: 1, color: .black)
                cell.gridlines.left = .solid(width: 1, color: .black)
                
                return cell
            }
            else{
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ValueCell.self), for: indexPath) as! ValueCell
                
                cell.label.text = imsi[indexPath.row]
                
                cell.gridlines.top = .solid(width: 1, color: .black)
                cell.gridlines.bottom = .solid(width: 1, color: .black)
                cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
                cell.gridlines.left = cell.gridlines.right
                return cell
            }
            
            
        }
        if indexPath.column == 1   {
            if indexPath.row == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TitleCell.self), for: indexPath) as! TitleCell
                
                cell.label.text = lastSeen[indexPath.row]
                
                cell.gridlines.top = .solid(width: 1, color: .black)
                cell.gridlines.bottom = .solid(width: 1, color: .black)
                cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
                cell.gridlines.right = cell.gridlines.left
                return cell
            }
            else{
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ValueCell.self), for: indexPath) as! ValueCell
                
                cell.label.text = lastSeen[indexPath.row]
                
                cell.gridlines.top = .solid(width: 1, color: .black)
                cell.gridlines.bottom = .solid(width: 1, color: .black)
                cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
                cell.gridlines.right = cell.gridlines.left
                return cell
            }
            
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
        //        print("JSON: \(String(describing: self.state?.test))")
        //        let json = JSON(self.state?.value as Any)
        
        print("populate data")
        if(self.json != nil)
        {
            print("JSON: not nil")
            
            
            
            //                        // inactivity_reasons from result
            //                        if let inactivityReason = json["compliance"]["inactivity_reasons"][0].string {
            //                            // inactivity_reasons found in the result
            //                             self.labelValues[4] = inactivityReason
            //                        } else {
            //                            // inactivity_reasons not founc in the result
            //                            self.labelValues[4] = "N/A"
            //                        }
            
            if let items = json["pairs"]["data"].array {
                // inactivity_reasons found in the result
                print("subscribers data array found")
                
                if items.isEmpty && imsi.count < 2 {
                    print("subs array empty")
                    spreadsheetView.isHidden = true
                    loadMoreBtn.isHidden = true
                    noRecordFound.isHidden = false
                }
                else{
                    print("subs array not empty")
                    noRecordFound.isHidden = true
                    loadMoreBtn.isHidden = false
                    spreadsheetView.isHidden = false
                }
                if(items.count < 9){
                    loadMoreBtn.isHidden = true
                }
                
                if (langStr == "ar")
                {
                    
                    
                    for item in items {
                        print("items array found")
                        if let imsiEl = item["imsi"].string {
                            lastSeen.append(imsiEl)
                            
                        }
                        else{
                            lastSeen.append("N/A")
                        }
                        if let lastSeenEl = item["last_seen"].string {
                            imsi.append(lastSeenEl)
                        }
                        else{
                            imsi.append("N/A")
                        }
                        
                    }
               
                }
                else{
                    
                    
                    for item in items {
                        print("items array found")
                        if let imsiEl = item["imsi"].string {
                            imsi.append(imsiEl)
                            
                        }
                        else{
                            imsi.append("N/A")
                        }
                        if let lastSeenEl = item["last_seen"].string {
                            lastSeen.append(lastSeenEl)
                        }
                        else{
                            lastSeen.append("N/A")
                        }
                        
                    }
                    
                }
                
    
                
            }
            else{
                print("subs array not found")
                spreadsheetView.isHidden = true
                loadMoreBtn.isHidden = true 
                noRecordFound.isHidden = false
            }
            
        }
    }
    func nextPage(){
//        if let imei = json["imei"].string {
//            
//            
//            let provider = MoyaProvider<ApiRequest>()
//            loadMoreBtn.isHidden = true
//            activityIndicator.isHidden = false
//            activityIndicator.startAnimating()
//            provider.request(.verifyImei(imei: imei, start: (imsi.count+1), limit:9)) { result in
//                self.loadMoreBtn.isHidden = false
//                self.activityIndicator.isHidden = true
//                self.activityIndicator.stopAnimating()
//                switch result {
//                case let .success(moyaResponse):
//                    let data = moyaResponse.data // Data, your JSON response is probably in here!
//                    let statusCode = moyaResponse.statusCode // Int - 200, 401, 500, etc
//                    if statusCode == 200 {
//                        self.json = JSON(data)
//                        print("JSON in next page : \(self.json)")
//                        self.populateData()
//                        self.spreadsheetView.reloadData()
//                        
//                        
//                    }
//                    else
//                    {
//                        self.showErrorAlert()
//                    }
//                    
//                // do something in your app
//                case let .failure(error):
//                    print(error)
//                    self.showErrorAlert()
//                    // TODO: handle the error == best. comment. ever.
//                }
//            }
//        }
//        
        
    }
    func showErrorAlert(){
        let alert = UIAlertController(title: "Oop!", message: "There was an error connecting to server. Please try again later.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
   
    
    
}
