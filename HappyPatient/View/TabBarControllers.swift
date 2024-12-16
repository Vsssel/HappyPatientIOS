//
//  TabBarControllers.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 14.12.2024.
//

import Foundation
import UIKit

class TabBarControllers: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainVC = SearchViewController()
        let appointmentsVC = AppointmentsViewController()
        let recordsVC = RecordsViewController()
        let myProfileVC = MyProfileViewController()
        
        mainVC.title = "Search"
        appointmentsVC.title = "Appointments"
        recordsVC.title = "Records"
        myProfileVC.title = "My Profile"
        
        self.setViewControllers([mainVC, appointmentsVC, recordsVC, myProfileVC], animated: true)
        
        guard let items = self.tabBar.items else { return }
        
        let images = ["magnifyingglass", "calendar.badge.clock", "note.text", "person.circle"]
        
        for i in 0...3 {
            items[i].image = UIImage(systemName: images[i])
        }
    }
}
