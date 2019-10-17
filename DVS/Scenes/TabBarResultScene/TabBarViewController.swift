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
import SwiftyJSON

protocol TabBarDisplayLogic: class
{
  func displayTabBarData(viewModel: TabBar.ResultTabbarData.ViewModel)
}

class TabBarViewController: UITabBarController,TabBarDisplayLogic, UITabBarControllerDelegate
{
    var navBar: UINavigationBar!
    var json: JSON?
    var navItem: UINavigationItem!
   
    
    
  var interactor: TabBarBusinessLogic?
  var router: (NSObjectProtocol & TabBarRoutingLogic & TabBarDataPassing)?

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
    let interactor = TabBarInteractor()
    let presenter = TabBarPresenter()
    let router = TabBarRouter()
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
    callResultTabBarInteractor()
    self.delegate = self
    
  
    print("JSON in tabbar view did load : \(String(describing: self.json))")
    if let rvc = self.viewControllers![0] as? DeviceStausViewController {
        print("result VC assign json")
        rvc.json = nil
    
        rvc.json = self.json
        rvc.tabBarItem.title =  "Device Status".localized()
    }
    if let swvc = self.viewControllers![1] as? SubcribeViewController {
        swvc.json = nil
        swvc.json = self.json
        swvc.tabBarItem.title = "Subscribers".localized()

         
    }
    if let pvc = self.viewControllers![2] as? PairedViewController {
        pvc.json = nil
        pvc.json = self.json
        pvc.tabBarItem.title = "Paired Subscribers".localized()

        
    }
    
  }
    

  
  func callResultTabBarInteractor()
  {
    let request = TabBar.ResultTabbarData.Request()
    interactor?.doResultTabBarData(request: request)
  }
  
  func displayTabBarData(viewModel: TabBar.ResultTabbarData.ViewModel)
  {
    
    json = viewModel.jsonResult
  
   print(" Tabbar jason Result2:\(json)")
   
  }
}
