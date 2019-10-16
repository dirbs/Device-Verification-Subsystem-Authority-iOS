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
import Material
import Alamofire
import ReCaptcha
import SwiftyJSON
import BarcodeScanner
import AVFoundation
import DTTextField
import AeroGearHttp
import AeroGearOAuth2

import SystemConfiguration
import Foundation
protocol PairedDisplayLogic: class
{
  func displayPairedData(viewModel: Paired.PairedData.ViewModel)
}

class PairedViewController: UIViewController, PairedDisplayLogic,SpreadsheetViewDataSource
{
   
    
    var resultStatus = [String: [String]]()
    var json: JSON!
    //Mark: Make outlet
    @IBOutlet var spreadsheetView: SpreadsheetView!
    @IBOutlet var loadMoreBtn: FlatButton!
    @IBOutlet var noRecordFound: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var titleLabel: UILabel!
    var imsi = [String]()
    var lastSeen = [String]()
    var slotInfo = [IndexPath: (Int, Int)]()
    let hourFormatter = DateFormatter()
    let twelveHourFormatter = DateFormatter()
    var langStr = ""
    var interactor: PairedBusinessLogic?
  var router: (NSObjectProtocol & PairedRoutingLogic & PairedDataPassing)?

  // MARK: Object lifecycle
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
  {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    setup()
  }
  
  
  //Mark: Make cancelbtn click listener Method
    @IBAction func cancelBtnClickListener(_ sender: Any) {
        
        self.parent?.dismiss(animated: true)
        
    }
    
 //Mark: Make loadmorebtn click listener Method
    @IBAction func loadMorebtnClickListener(_ sender: Any) {
        
        
        if Reachability.isConnectedToNetwork() == true {
            
          nextPage()
            
        }
        else {
            
            self.loadMoreBtn.isHidden = false
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
           showErrorAlert(title: "Oop!".localized(), message: "No Internet Connection! Please enable wifi or mobile data and try again.".localized())
            
        }
        
       
    }
    
  //Mark: Make setup Method
  private func setup()
  {
    let viewController = self
    let interactor = PairedInteractor()
    let presenter = PairedPresenter()
    let router = PairedRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  // MARK: Routing
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
  
  // MARK: View lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    print("Paired Tabbar")
   
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
     //Mark: Make changeLanguage Method
    func changeLanguage()
    {
        langStr = Locale.current.languageCode!
        print("CurrentLanguage= \(langStr)")
        
        if(UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
        {
            lastSeen.append("IMSI".localized())
            imsi.append("Last Seen".localized())
            
        }
            
        else{
            
            imsi.append("IMSI".localized())
            lastSeen.append("Last Seen".localized())
            
        }
        
        
        
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
       
        
//                if la[row].count > 40{
//                    height = CGFloat(Double(lastSeen[row].count) * 1.2)
//                }
        
        
        var height:CGFloat = 40
        
        
        if(UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
        {
            
            if lastSeen[row].count > 40{
                height = CGFloat(Double(lastSeen[row].count) * 1.5)
            }
            
        }
            
        else{
            if lastSeen[row].count > 40{
                height = CGFloat(Double(lastSeen[row].count) * 1.5)
            }
            
        }
        
        
        
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
     //Mark: Make done Method
    @objc func done() { // remove @objc for Swift 3
        dismiss(animated: true)
    }
     //Mark: Make cancelbtn click listener Method
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.done()
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if case 0 = indexPath.row {
            print("load more ")
            spreadsheetView.reloadData()
        }
    }
     //Mark: Make populateData Method
    func populateData(){
       
        
        print("populate data")
        if(self.json != nil)
        {
            print("JSON: not nil")
            
            noRecordFound.isHidden = true
            loadMoreBtn.isHidden = false
            spreadsheetView.isHidden = false
            
            if let items = json["pairs"]["data"].array {
                // inactivity_reasons found in the result
              
                
                
                if(UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
                {
                    
                    
                    for item in items {
                        print("items array found")
                        if let imsiEl = item["imsi"].string {
                            lastSeen.append(imsiEl)
                            
                        }
                        else{
                            lastSeen.append("N/A".localized())
                        }
                        if let lastSeenEl = item["last_seen"].string {
                            imsi.append(lastSeenEl)
                        }
                        else{
                            imsi.append("N/A".localized())
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
                            imsi.append("N/A".localized())
                        }
                        if let lastSeenEl = item["last_seen"].string {
                            lastSeen.append(lastSeenEl)
                        }
                        else{
                            lastSeen.append("N/A".localized())
                        }
                        
                    }
                    
                }
                
                
                
                if(items.count < Constants.limit)
                    
                {
                    
                    print("hide button")
                    loadMoreBtn.isHidden = true
                    activityIndicator.stopAnimating()
                    activityIndicator.isHidden = true
                }
                
                if(items.isEmpty && items.count < 2)
                    
                {
                    
                    noRecordFound.isHidden = false
                    loadMoreBtn.isHidden = true
                    spreadsheetView.isHidden = true
                    
                    
                }
                
                
                
            }
           
            
        }
    }
     //Mark: Make nextpage Method
    func nextPage(){
        
        callPairedInteractor()
        
    
    }
     //Mark: Make showLogoutAlert Method
    func showLogoutAlert(title:String ,message:String){
        
        let alert = UIAlertController.init(title: title, message:message , preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok".localized(), style: .default) { _ in
            self.logout()
            //custom action here.
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
     //Mark: Make show error alert Method
    func showErrorAlert(title:String ,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
    }
     //Mark: Make logout Method
    func logout()
    {
        var keycloakHttp = Http()
        let keycloakConfig = KeycloakConfig(
            clientId: getStringFromInfoPlist(key: "ClientId"),
            host: getStringFromInfoPlist(key: "IamURL"),
            realm: getStringFromInfoPlist(key: "Realm"),
            isOpenIDConnect: true)
        let oauth2Module = AccountManager.addKeycloakAccount(config: keycloakConfig)
        
        oauth2Module.revokeAccess(completionHandler: {(response, error) in
            if (error != nil) {
                // do something with error
                print("error "+(error?.description)!)
            }
            // do domething
            oauth2Module.oauth2Session.clearTokens()
            //completionHandler(true)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main") as! LoginViewController
            //self.present(vc, animated: true, completion: nil)
            let appDlg = UIApplication.shared.delegate as? AppDelegate
            appDlg?.window?.rootViewController = vc
        })
        
        
        
    }
  
   //Mark: Make dosomthing Method
  func callPairedInteractor()
  {
    
    self.loadMoreBtn.isHidden = true
    self.activityIndicator.isHidden = false
    self.activityIndicator.startAnimating()

    if let imei = json["imei"].string {
        
        let request = Paired.PairedData.Request(imei:imei ,start: imsi.count)
        interactor?.doPairedData(request: request)
    }
    
  }
    //Mark: Make displaySomthing Method

  func displayPairedData(viewModel: Paired.PairedData.ViewModel)
  {
    //self.loadMoreBtn.isHidden = false
    self.activityIndicator.isHidden = true
    self.activityIndicator.stopAnimating()
    
    print("viewModel:\(viewModel.jsonResult)")
    if(viewModel.jsonResult != nil && viewModel.statusCode == 200)
    {
        self.json = viewModel.jsonResult
        print("JSON in next page : \(self.json)")
        
            self.populateData()
    
         self.spreadsheetView.reloadData()
        
    }
    
    if(viewModel.statusCode == 401)
    {
        self.showLogoutAlert(title:"Session Expired".localized() , message: "Your session has expired. Please login again to continue using DVS".localized())
    
    }
        
    
    if(viewModel.statusCode ==  500)
    {
        
        showErrorAlert(title: "Oop!".localized(), message: "There was an error connecting to server. Please try again later.".localized())
        
    }
    if(viewModel.statusCode ==  400)
    {
        
        showErrorAlert(title: "Oop!".localized(), message: "Problem getting reponse. Please try again or try updating the app if problem persists.".localized())
        
    }
    if(viewModel.statusCode ==  504)
    {
        
        showErrorAlert(title: "Oop!".localized(), message: "Problem connecting to server. Please check your internet connection and try again.".localized())
        
    }
//    if(viewModel.statusCode == 0 && viewModel.jsonResult == nil)
//    {
//        
//        showErrorAlert(title: "Oop!".localized(), message: "Problem connecting to server. Please check your internet connection and try again.".localized())
//        
//        
//    }
    
    
    
  }
     //Mark: Make getstring Method
    private func getStringFromInfoPlist(key: String) -> String {
        var resourceFileDictionary: NSDictionary?
        
        //Load content of Info.plist into resourceFileDictionary dictionary
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            resourceFileDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let resourceFileDictionaryContent = resourceFileDictionary {
            
            // Get something from our Info.plist like TykUrl
            
            return resourceFileDictionaryContent.object(forKey:key)! as! String
            
        }
        else{
            return ""
        }
    }
    
    
    
    public class Reachability {
        
        class func isConnectedToNetwork() -> Bool {
            
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                return false
            }
            
            var flags: SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return false
            }
            
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            
            return (isReachable && !needsConnection)
        }
    }
    

}




