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

protocol ProfileDisplayLogic: class
{
  func displayProfileData(viewModel: Profile.ProfileData.ViewModel)
 func displayProfileToken(viewModel: Profile.RemoveToken.ViewModel)
}

class ProfileViewController: UIViewController, ProfileDisplayLogic,TableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profile", for: indexPath) as! profileCell
        cell.item.text = item[indexPath.row]
        cell.itemdetail.text = itemdeatil[indexPath.row]
        
        return cell
    }
    
    var item = ["Name".localized(),"Username".localized(),"Email".localized()]
   var itemdeatil = [String]()
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBOutlet var titleLabel: UILabel!
    var keycloakHttp = Http()
    //Mark:outlet
    @IBOutlet var logoutButton: RaisedButton!
    
    
    
  var interactor: ProfileBusinessLogic?
  var router: (NSObjectProtocol & ProfileRoutingLogic & ProfileDataPassing)?

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
    //Mark:  Make display Remove Token Method
    func displayProfileToken(viewModel: Profile.RemoveToken.ViewModel) {
        self.dismiss(animated: true)
    }
    //Mark: Make   Remove Token Method
    func removeToken()
    {
        let request = Profile.RemoveToken.Request()
        interactor?.doProfileRemoveToken(request: request)
        
    }
    //Mark:  Make  Logout btn clickListener Method
    @IBAction func logoutButtonClickListener(_ sender: Any) {
     removeToken()
    }
   
  
  private func setup()
  {
    let viewController = self
    let interactor = ProfileInteractor()
    let presenter = ProfilePresenter()
    let router = ProfileRouter()
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
   
    changeLanguage()
    
     callProfileInteractor()
  
    
  }
    //Mark: change Language Method
    func changeLanguage()
    {
        logoutButton.title = "Logout".localized()
        titleLabel.text = "Profile".localized()
        
    }
     
  
  // MARK: Do something
  
  func callProfileInteractor()
  {
    let request = Profile.ProfileData.Request()
    interactor?.doProfileData(request: request)
  }
   //Mark: display somthing Method
  func displayProfileData(viewModel: Profile.ProfileData.ViewModel)
  {
    
    
    itemdeatil.append(viewModel.fullName!)
     itemdeatil.append(viewModel.userName!)
     itemdeatil.append(viewModel.email!)
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.isUserInteractionEnabled = false

    
  }
    
   
}
