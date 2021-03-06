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
import AeroGearHttp
import AeroGearOAuth2
import Material

class LoginWorker
{
    var userInfo: OpenIdClaim?
    var keycloakHttp = Http()
    var currentIndex = 0
    //Mark: login Method
    func login(isLogin:Bool,completionHandler: @escaping (Bool?,String?) -> Void){

        let keycloakConfig = KeycloakConfig(
            clientId: Constants.clientId,
            host: Constants.iamURL,
            realm: Constants.realm,
            isOpenIDConnect: true)
        
        keycloakConfig.webView = KeycloakConfig.WebViewType.safariViewController
        
        let oauth2Module = AccountManager.addKeycloakAccount(config: keycloakConfig)
        self.keycloakHttp.authzModule = oauth2Module
        
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIdClaim?, error: NSError?) in
            self.userInfo = claims
            print("error: \(String(describing: error?.description))")
            if error == nil {
                if let userInfo = claims {
                    print("access token login : \(accessToken)")
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(accessToken as! String, forKey: "AccessToken")
                    if let name = userInfo.name {
                        userDefaults.set(name, forKey: "FullName")
                    }
                    if let username = userInfo.preferredUsername {
                        userDefaults.set(username, forKey: "Username")
                    }
                    if let email = userInfo.email {
                        userDefaults.set(email, forKey: "Email")
                    }
                    completionHandler(true,accessToken as!String)
                }
            }
            else{
              print(" login Fail : \(accessToken)")
               completionHandler(false,nil)
                print("error: \(String(describing: error?.description))")
                //self.showLoginErrorAlert()
                
            }
        }
        
    }
    //Mark: getString Method
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
  
}
