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

protocol SubcribeDisplayLogic: class
{
  func displaySubcribeData(viewModel: Subcribe.SubcribeData.ViewModel)
}

class SubcribeViewController: UIViewController, SubcribeDisplayLogic,SpreadsheetViewDataSource
{
    
     //Mark: Outlet
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var spreadsheetView: SpreadsheetView!
    
    @IBOutlet var loadMoreBtn: FlatButton!
    @IBOutlet var cancelBtn: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
   
    var resultStatus = [String: [String]]()
    var json: JSON!
    var imsi = [String]()
    var msisdn = [String]()
    var lastSeen = [String]()
    var isPullable = true
    var slotInfo = [IndexPath: (Int, Int)]()
   
    @IBOutlet var noRecordFound: UILabel!
    let hourFormatter = DateFormatter()
    let twelveHourFormatter = DateFormatter()
    var langStr = ""
    
  var interactor: SubcribeBusinessLogic?
  var router: (NSObjectProtocol & SubcribeRoutingLogic & SubcribeDataPassing)?

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
    //Mark: Make cancel btn click listener Method
    @IBAction func cancelBtnClickListener(_ sender: Any) {
        
        
         self.parent?.dismiss(animated: true)
    }
    
  // MARK: Setup
  
  private func setup()
  {
    let viewController = self
    let interactor = SubcribeInteractor()
    let presenter = SubcribePresenter()
    let router = SubcribeRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  //Mark: Make load more btn click listener Method
    @IBAction func loadmorebtnclickListener(_ sender: Any) {
        
        
        
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
    
    //Mark: Make override prepare Method
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
    print("subcribe Tabbar")

    changeLanguage()
    //add heading
    langStr = Locale.current.languageCode!
    print("CurrentLanguage= \(langStr)")
    
    if(UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
    {
        
        imsi.append("MSISDN".localized())
        msisdn.append("IMSI".localized())
        lastSeen.append("Last Seen Date".localized())
        titleLabel.font = UIFont(name:  titleLabel.font!.fontName, size: 17)
        pupuplateDataRtl()
        
    }
        
    else{
        
        imsi.append("IMSI".localized())
        msisdn.append("MSISDN".localized())
        lastSeen.append("Last Seen Date".localized())
        populateData()
    }
    
    
    activityIndicator.isHidden = true
    spreadsheetView.dataSource = self
    spreadsheetView.isPagingEnabled = true
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
    //Mark: Make change Language Method
    func changeLanguage()
    {
        
         noRecordFound.text = "No record found".localized()
        loadMoreBtn.title = "Load More".localized()
        titleLabel.text = "Subscribers Seen With IMEI".localized()
        
    }
    //Mark: Make pupolate data set arabic Language Method
    
    func pupuplateDataRtl()
    {
        
        print("populate data")
        if(self.json != nil)
        {
            print("JSON: not nil")
            
            
            noRecordFound.isHidden = true
            loadMoreBtn.isHidden = false
            spreadsheetView.isHidden = false
            
            
            
        
            if let items = json["subscribers"]["data"].array {
                // inactivity_reasons found in the result
                
                
                for item in items {
                    print("items array found")
                    if let imsiEl = item["imsi"].string {
                        msisdn.append(imsiEl)
                    }
                    else{
                        msisdn.append("N/A".localized())
                    }
                    if let msisdnEl = item["msisdn"].string {
                        imsi.append(msisdnEl)
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
        var height:CGFloat = 40
        
        
    
        
        
        if(UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
        {
            
            if imsi[row].count > 40{
                height = CGFloat(Double(imsi[row].count) * 1.5)
            }
            
        }
            
        else{
            if imsi[row].count > 40{
                height = CGFloat(Double(imsi[row].count) * 1.5)
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
                return cell
            }
            
            
        }
        if indexPath.column == 1   {
            if indexPath.row == 0 {
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TitleCell.self), for: indexPath) as! TitleCell
                
                cell.label.text = msisdn[indexPath.row]
                
                cell.gridlines.top = .solid(width: 1, color: .black)
                cell.gridlines.bottom = .solid(width: 1, color: .black)
                cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
                cell.gridlines.right = cell.gridlines.left
                return cell
            }
            else{
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ValueCell.self), for: indexPath) as! ValueCell
                
                cell.label.text = msisdn[indexPath.row]
                
                cell.gridlines.top = .solid(width: 1, color: .black)
                cell.gridlines.bottom = .solid(width: 1, color: .black)
                cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
                cell.gridlines.right = cell.gridlines.left
                return cell
            }
            
        }

        
        return spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: BlankCell.self), for: indexPath)
    }
    
    //Mark: Make done btn click listener Method
    @objc func done() { // remove @objc for Swift 3
        dismiss(animated: true)
    }
    //Mark: Make cancel btn click listener Method
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.done()
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if case 0 = indexPath.row {
            print("load more ")
            spreadsheetView.reloadData()
        }
    }
    //Mark: Make pupolate data  Method
    func populateData(){
        //        print("JSON: \(String(describing: self.state?.test))")
        //        let json = JSON(self.state?.value as Any)
        
        print("populate data")
        if(self.json != nil)
        {
            print("JSON: not nil")
            
            
            noRecordFound.isHidden = true
            loadMoreBtn.isHidden = false
            spreadsheetView.isHidden = false
           
            
            if let items = json["subscribers"]["data"].array {
            
                for item in items{
                
                    
                    print("items array found")
                    if let imsiEl = item["imsi"].string {
                        imsi.append(imsiEl)
                    }
                    else{
                        imsi.append("N/A".localized())
                    }
                    if let msisdnEl = item["msisdn"].string {
                        msisdn.append(msisdnEl)
                    }
                    else{
                        msisdn.append("N/A".localized())
                    }
                    if let lastSeenEl = item["last_seen"].string {
                        lastSeen.append(lastSeenEl)
                    }
                    else{
                        lastSeen.append("N/A".localized())
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
    
//Mark: Make next Page Method
    func nextPage(){
        
        callSubcribeInteractor()
        
    }
    func showErrorAlert(){
        let alert = UIAlertController(title: "Oop!", message: "There was an error connecting to server. Please try again later.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
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
  //Mark: Make show logout Alert Method
    func showLogoutAlert(title:String ,message:String){

        
        let alert = UIAlertController.init(title: title, message:message , preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok".localized(), style: .default) { _ in
            self.logout()
            //custom action here.
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    //Mark: Make show error Alert Method
    
    func showErrorAlert(title:String ,message:String){
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
                alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: nil))
               alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel, handler: nil))
        
                self.present(alert, animated: true)
    }
  
  func callSubcribeInteractor()
  {
    
    
    
    self.loadMoreBtn.isHidden = true
    self.activityIndicator.isHidden = false
    self.activityIndicator.startAnimating()
    
      if let imei = json["imei"].string {
        
        
        let request = Subcribe.SubcribeData.Request(imei: imei ,start: imsi.count)
        interactor?.doSubcribeData(request: request)
    }
  }
    //Mark: Make  logout  Method
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
            //self.dismiss(animated: true)
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main") as! LoginViewController
            //self.present(vc, animated: true, completion: nil)
                    let appDlg = UIApplication.shared.delegate as? AppDelegate
                   appDlg?.window?.rootViewController = vc
           // self.router?.routeToSomewhere(segue: nil)
            
        })
        
        
        
    }
    //Mark: Make displaysomthing Method
  
  func displaySubcribeData(viewModel: Subcribe.SubcribeData.ViewModel)
  {
    
    //self.loadMoreBtn.isHidden = false
    self.activityIndicator.isHidden = true
    self.activityIndicator.stopAnimating()
    print("viewModel:\(viewModel.jsonResult)")
    if(viewModel.jsonResult != nil && viewModel.statusCode == 200)
    {
        self.json = viewModel.jsonResult
            print("JSON in next page : \(self.json)")
        
        if(UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
        {
           pupuplateDataRtl()
        }
        else{
            self.populateData()
        }
            self.spreadsheetView.reloadData()
        
    }
    
    if(viewModel.statusCode == 401)
    {
        self.showLogoutAlert(title:"Session Expired".localized() , message: "Your session has expired. Please login again to continue using DVS".localized())
        // router?.routeToSomewhere(segue: nil)

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

