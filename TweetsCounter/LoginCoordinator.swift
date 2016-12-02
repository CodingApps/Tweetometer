//
//  LoginCoordinator.swift
//  TweetsCounter
//
//  Created by Patrick Balestra on 12/1/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import UIKit
import TwitterKit

protocol LoginCoordinatorDelegate: class {
    func dismiss()
}

final class LoginCoordinator: LoginCoordinatorDelegate {

    lazy var loginViewController: LoginViewController = {
        return StoryboardScene.Main.LoginViewController()
    }()

    var childCoordinators = Array<AnyObject>()

    let parent: UIViewController

    init(parent: UIViewController) {
        self.parent = parent
    }

    func start() {
        loginViewController.coordinator = self
        parent.present(loginViewController, animated: true)
    }

    // MARK: LoginCoordinatorDelegate

    func dismiss() {
        loginViewController.dismiss(animated: true)
    }
}