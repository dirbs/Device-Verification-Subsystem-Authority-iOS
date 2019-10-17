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
public extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}
class State {
    var value:Any = {}
    var test = ""
    func requestData(completion: ((_ value: String) -> Void)) {
        
        completion(test)
    }
}

protocol VerifyImeiDisplayLogic: class
{
  func displayVerifyImeiData(viewModel: VerifyImei.VerifiImeiData.ViewModel)
}

class VerifyImeiViewController: UIViewController, VerifyImeiDisplayLogic,UITextFieldDelegate
{
   
    var imei:String = ""
    let recaptcha = try? ReCaptcha()
    var jsonResult: JSON!
    
    var state: State?
    fileprivate let constant: CGFloat = 32
    var labelValues = [
        "123456789012345",
        "Samsung",
        "Galaxy",
        "S6",
        "Samsung China",
        "Smart Phone",
        "Android",
        "GSMA CDMA",
        "Compliance (Active)",
        "N/A",
        "N/A",
        "N/A"
    ]
    
    
    
    let viewController = BarcodeScannerViewController()
    
    //Mark:outlet
    @IBOutlet var verifyImeiLabel: UILabel!
    
    @IBOutlet var footerNameLabel: UILabel!
    var langStr = ""
    @IBOutlet var imeiTextField: DTTextField!
    @IBOutlet var contentView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    
     var scanButton: UIButton!
    @IBOutlet var submitButton: RaisedButton!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var interactor: VerifyImeiBusinessLogic?
  var router: (NSObjectProtocol & VerifyImeiRoutingLogic & VerifyImeiDataPassing)?
    
    //Declared at top of view controller
    var accessoryDoneButton: UIBarButtonItem!
    let accessoryToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    
    override func viewDidLayoutSubviews() {
        scrollView.addSubview(contentView)//if the contentView is not already inside your scrollview in your xib/StoryBoard doc
        scrollView.contentSize = CGSize(
            width: self.contentView.frame.size.width,
            height: self.contentView.frame.size.height
        ); //sets ScrollView content size
        
    }

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
  
  // MARK: Setup
  
  private func setup()
  {
    let viewController = self
    let interactor = VerifyImeiInteractor()
    let presenter = VerifyImeiPresenter()
    let router = VerifyImeiRouter()
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
    print(" verify TabBar")
    
    
    changeLangauge()
    
    
    //hiding activity indicator
    activityIndicator.isHidden = true
    
    // Configure ReCaptacha
    recaptcha?.configureWebView { [weak self] webview in
        webview.frame = self?.view.bounds ?? CGRect.zero
    }
    
//    //add Done button above keypad
    self.accessoryDoneButton = UIBarButtonItem(title: "Done".localized(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.donePressed))

  
    
    
    let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    numberToolbar.barStyle = UIBarStyle.default
    numberToolbar.items = [
       
        UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),
        accessoryDoneButton]
   
    numberToolbar.sizeToFit()
    imeiTextField.inputAccessoryView = numberToolbar
    
    if(UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
    {
        scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "ic_barcode_scanner.png"), for: .normal)
        scanButton.imageEdgeInsets = UIEdgeInsetsMake(0, 32, 0, 0)
        scanButton.frame = CGRect(x: CGFloat(5), y: CGFloat(5), width: CGFloat(5), height: CGFloat(20))
        imeiTextField.rightView = scanButton
        imeiTextField.rightViewMode = .always
          scanButton.addTarget(self, action: #selector(self.scanButtonClick(_:)), for: .touchUpInside)
       

    }
    else{
        
        scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "ic_barcode_scanner.png"), for: .normal)
        scanButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
    scanButton.frame = CGRect(x: CGFloat(imeiTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        imeiTextField.rightView = scanButton
        imeiTextField.rightViewMode = .always
        
         scanButton.addTarget(self, action: #selector(self.scanButtonClick(_:)), for: .touchUpInside)
    }
    //scanButton.addTarget(self, action: #selector(self.scanButtonClick(_:)), for: .touchUpInside)
    
    imeiTextField.placeholderColor = UIColor.lightGray
    imeiTextField.borderColor = UIColor.lightGray
    imeiTextField.delegate = self
    
  }
    //Mark:   Make  change Language method
    func changeLangauge()
    {
        
        //set prperties
        self.tabBarItem.title = "Verify IMEI".localized()
        imeiTextField.placeholder = "Enter Imei".localized()
       
        submitButton.title = "Submit".localized()
        verifyImeiLabel.text = "Verify IMEI".localized()
        footerNameLabel.text = "Dial *#06# to check the IMEI of device".localized()
        langStr = Locale.current.languageCode!
        print("CurrentLanguage= \(langStr)")
        
        if(UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
        {
            imeiTextField.textAlignment = .right
        }
        
    }
//Mark:   Make  done press click listener Method
    @objc func donePressed() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        submitButton.sendActions(for: .touchUpInside)
    }
    //Mark: perform segue Method
    public func performResultSeige(){
        self.performSegue(withIdentifier: "showResultSegue", sender: nil)
    }
    //Mark: onscan complete Method
    func onScanComplete(data: String)
    {
        imeiTextField.text = data;
    }
    //Mark:   Make  get String method Method
    
    
    //Mark:  Make  submit button click listener Method
    @IBAction func submitButtonClickListener(_ sender: Any) {

        
        
        var imei = imeiTextField.text!
        
        if(imei.count == 0)
        {
            //imeiTextField.hideError()
            
            imeiTextField.errorMessage = "IMEI must be 14 to 16 characters long".localized()
            imeiTextField.showError()


        }

        else{

            if imei.range(of: "^(?=.[a-fA-F]*)(?=.[0-9]*)[a-fA-F0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil {


                if(imei.count < 14) && (imei.count < 16)
                {
                    imeiTextField.errorMessage = "IMEI must be 14 to 16 characters long".localized()
                    imeiTextField.showError()

                }
                else{



                                    self.imeiTextField.hideError()

                                    //start loader and disable button
                                    activityIndicator.isHidden = false
                                    activityIndicator.startAnimating()
                                    scanButton.isEnabled = false
                                    submitButton.isEnabled = false



                                    callVerifyImeiInteractor()

                }


            }



            else{
                imeiTextField.errorMessage = "InValidCharacterError".localized()
                imeiTextField.showError()
                self.imeiTextField.becomeFirstResponder()

            }
        }
        
        
        
        
        
        
        
        
        
        
    }
    //Mark: scan button click listener Method
    @IBAction func scanButtonClick(_ sender: Any) {
       
        let viewController = makeBarcodeScannerViewController()
        viewController.headerViewController.titleLabel.text =  "Barcode Scanner".localized()
        viewController.headerViewController.titleLabel.font = UIFont.systemFont(ofSize: 24.0, weight: .regular)
        
        viewController.messageViewController.messages.scanningText = "Place the barcode within the window to scan.The search will start automatically.".localized()
  //viewController.headerViewController.closeButton.setTitle("Close".localized(), for: .normal)
        viewController.headerViewController.closeButton.setTitle("".localized(), for: .normal)
        
        
        let image = UIImage(named: "ic_cancel.png");
        let sizeChange = CGSize.init(width: 25, height: 25)
        UIGraphicsBeginImageContextWithOptions(sizeChange, false, 0.0)
        image!.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        viewController.headerViewController.closeButton.setBackgroundImage(scaledImage, for: .normal)
        viewController.messageViewController.messages.scanningText = "Place the barcode within the window to scan the barcode of IMEI".localized()
        //viewController.
        
        
        
        
        
        //viewController.headerViewController.closeButton.setImage(image, for: .normal)
        
        
        present(viewController, animated: true, completion: nil)
    }
    
    //Mark:  Make imei text field text change listener Method
    @IBAction func imeiTextFieldClickListner(_ sender: DTTextField) {

        
//        if (imei.count > 15) {
//                       sender.deleteBackward()
//                   }
        
         imei = imeiTextField.text!
        if(imei.count == 0)
        {
            imeiTextField.hideError()
            
            
        }
            
        else{
            
            if imei.range(of: "^(?=.[a-fA-F]*)(?=.[0-9]*)[a-fA-F0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil {
                
                
                if(imei.count < 14) && (imei.count < 16)
                {
                    imeiTextField.errorMessage = "IMEI must be 14 to 16 characters long".localized()
                    imeiTextField.showError()
                    
                }
                else{
                    
                    
                    
                    self.imeiTextField.hideError()
                    
                    
                    
                }
                
                
            }
                
                
                
            else{
                imeiTextField.errorMessage = "InValidCharacterError".localized()
                imeiTextField.showError()
                self.imeiTextField.becomeFirstResponder()
                
            }
        }
        
        
        
        
        
        
        
        
    }
    //Mark:   Make  barcodescanner view controller Method
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        
        viewController.cameraViewController.barCodeFocusViewType = .oneDimension
        
        viewController.metadata.remove(at: viewController.metadata.index(of: AVMetadataObject.ObjectType.qr)!)
        return viewController
    }
    //Mark:   Make  show alert Method
    func showLogoutAlert(title:String ,message:String){


        let alert = UIAlertController.init(title: title, message:message , preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok".localized(), style: .default) { _ in
            self.logout()
            //custom action here.
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
       
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        
        
        return count <= 16
    }
    //Mark:   Make  show logout Method
    func logout()
    {
        
        
        
        let keycloakConfig = KeycloakConfig(
            clientId: Constants.clientId,
            host: Constants.iamURL,
            realm: Constants.realm,
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
            self.dismiss(animated: true)
        })
        

    }
  // MARK: Do something
  
  func callVerifyImeiInteractor()
  {
    
    if Reachability.isConnectedToNetwork() == true {
       
    
        let request = VerifyImei.VerifiImeiData.Request(imei:imei)
        interactor?.doVerifyImeiData(request: request)
        
        
    }
    else {
        
        self.activityIndicator.stopAnimating()
        self.scanButton.isEnabled = true
        self.submitButton.isEnabled = true
        showErrorAlert(title: "Oop!".localized(), message: "No Internet Connection! Please enable wifi or mobile data and try again.".localized())
        
    }
    
    
    
  }
  
  func displayVerifyImeiData(viewModel: VerifyImei.VerifiImeiData.ViewModel)
  {
    
    self.activityIndicator.stopAnimating()
    self.scanButton.isEnabled = true
    self.submitButton.isEnabled = true
    print("viewModel:\(viewModel.jsonResult)")
    print("viewModel:\(viewModel.statusCode)")
    if(viewModel.jsonResult != nil && viewModel.statusCode == 200)
    {
        router?.routeToSomewhere(segue: nil)
      
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
    if(viewModel.statusCode == 401)
    {
        self.showLogoutAlert(title:"Session Expired".localized() , message: "Your session has expired. Please login again to continue using DVS".localized())
        
        
    }
    
    if(viewModel.statusCode == 0 && viewModel.jsonResult == nil)
    {
        
        self.showLogoutAlert(title:"Session Expired".localized() , message: "Your session has expired. Please login again to continue using DVS".localized())
        

        
    }
    
    
    
    
  }
    //Mark:   Make  show  error alert Method
    func showErrorAlert(title:String ,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
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
//Mark:   Make   bar code scanner code  Delegate
extension VerifyImeiViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print("Barcode Data: \(code)")
        self.imeiTextField.text = code
        self.dismiss(animated: true, completion: nil)
        // confirmImei(imei: code, controller: controller)
        
    }
}

// MARK: - BarcodeScannerErrorDelegate
extension VerifyImeiViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
        controller.isOneTimeSearch = true
        controller.reset(animated: true)
    }
}

// MARK: - BarcodeScannerDismissalDelegate
extension VerifyImeiViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
}
