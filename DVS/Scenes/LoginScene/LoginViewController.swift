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
import AeroGearHttp
import AeroGearOAuth2
import Localize_Swift
import SystemConfiguration
import Foundation

protocol LoginDisplayLogic: class
{
  func displayLoginData(viewModel: Login.LoginData.ViewModel)
}

class LoginViewController: UIViewController, LoginDisplayLogic
{
    
    
    var userInfo: OpenIdClaim?
    var keycloakHttp = Http()
    var images: [UIImage] = []
    var currentIndex = 0
    //Mark:outlet
    @IBOutlet var loginButton: RaisedButton!
    @IBOutlet var nameLabel: UILabel!
    var interactor: LoginBusinessLogic?
    var langStr = ""
  var router: (NSObjectProtocol & LoginRoutingLogic & LoginDataPassing)?

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
  // MARK: creat click listener of login btn
    @IBAction func loginButtonClick(_ sender: UIButton) {
          print("login press" )
        
            
            if Reachability.isConnectedToNetwork() == true {
                
                
                 callLoginInterctor()
                
                
            }
            else {
                
                
                showErrorAlert(title: "Oop!".localized(), message: "No Internet Connection! Please enable wifi or mobile data and try again.".localized())
                
            }
        
    
        
      
    }
    
    
    func showErrorAlert(title:String ,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    // MARK: Setup

  private func setup()
  {
    let viewController = self
    let interactor = LoginInteractor()
    let presenter = LoginPresenter()
    let router = LoginRouter()
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
   
    changeLangauge()
   
    print("login view controller")
    
    
    
     }
//Mark: change Language Method
func changeLangauge()
{

    langStr = Locale.current.languageCode!
    print("CurrentLanguage= \(langStr)")
    Localize.setCurrentLanguage("en")
    
    loginButton.title = "Login".localized()
   

    }
  // MARK: Do something
  func callLoginInterctor()
  {
    let request = Login.LoginData.Request(flag: false)
    interactor?.doLoginData(request: request)
  }
  
    //Mark: display Sonthing  Method
  func displayLoginData(viewModel: Login.LoginData.ViewModel)
  {
    
    if(viewModel.flag == true && viewModel.access_token != nil)
    {
     
        self.performSegue(withIdentifier: "showMainPage", sender: nil)

    }
    if(viewModel.flag == false && viewModel.access_token == nil)
    {
        self.showLoginErrorAlert()

    }
   
  }
    //Mark: overide view DidAppear Method
    override func viewDidAppear(_ animated: Bool) {
        keycloakHttp = Http()

        
        let keycloakConfig = KeycloakConfig(
                       clientId: Constants.clientId,
                       host: Constants.IamURL,
                        realm: Constants.Realm,
                       isOpenIDConnect: true)
        
        
        keycloakConfig.webView = KeycloakConfig.WebViewType.safariViewController
        let oauth2Module = AccountManager.addKeycloakAccount(config: keycloakConfig)
        self.keycloakHttp.authzModule = oauth2Module
        if oauth2Module.authorizationFields() != nil {
            self.performSegue(withIdentifier: "showMainPage", sender: nil)

        }
    }
    
    //Mark: show error alert Method
    func showLoginErrorAlert(){
        let alert = UIAlertController(title: "Oop!", message: "There was an error connecting to server. Please try again later.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
     
        self.present(alert, animated: true)
    }
    //Mark: getstring Method
    public func getStringFromInfoPlist(key: String) -> String {
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
    
    
    public func getStringFromFile(key: String) -> String {
        var resourceFileDictionary: NSDictionary?
        
        //Load content of Info.plist into resourceFileDictionary dictionary
        if let path = Bundle.main.path(forResource: "url", ofType: "strings") {
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

