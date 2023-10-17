//
//  EmailLoginViewController.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-12.
//

import UIKit
import FirebaseAuth

class EmailLoginViewController: UIViewController {
  weak var delegate: LoginDelegate?

  private var loginView: EmailLoginView { view as! EmailLoginView }

  private var email: String { loginView.emailTextField.text! }
  private var password: String { loginView.passwordTextField.text! }

  // Hides tab bar when view controller is presented
  override var hidesBottomBarWhenPushed: Bool { get { true } set {} }

  // MARK: - View Controller Lifecycle Methods

  override func loadView() {
    view = EmailLoginView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBar()
    configureDelegatesAndHandlers()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setTitleColor(.label)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true)
    navigationController?.setTitleColor(.systemOrange)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    navigationController?.popViewController(animated: false)
  }

  // Dismisses keyboard when view is tapped
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
  }

  // MARK: - Firebase 🔥

  private func login(with email: String, password: String) {
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
      guard error == nil else { return self.displayError(error) }
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            let tabBarController = MainTabBarController()
            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }
  }

  // MARK: - Action Handlers

  @objc
  private func handleLogin() {
    login(with: email, password: password)
  }

  // MARK: - UI Configuration

  private func configureNavigationBar() {
    navigationItem.title = "Welcome"
    navigationItem.backBarButtonItem?.tintColor = .systemYellow
  }

  private func configureDelegatesAndHandlers() {
    loginView.emailTextField.delegate = self
    loginView.passwordTextField.delegate = self
    loginView.loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
  }

  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    loginView.emailTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 15 : 50
    loginView.passwordTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 5 : 20
  }
}

// MARK: - UITextFieldDelegate

extension EmailLoginViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if loginView.emailTextField.isFirstResponder, loginView.passwordTextField.text!.isEmpty {
      loginView.passwordTextField.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
    }
    return true
  }
}


/// Login View presented when peforming Email & Password Login Flow
class EmailLoginView: UIView {
  var emailTextField: UITextField! {
    didSet {
      emailTextField.textContentType = .emailAddress
    }
  }

  var passwordTextField: UITextField! {
    didSet {
      passwordTextField.textContentType = .password
    }
  }

  var emailTopConstraint: NSLayoutConstraint!
  var passwordTopConstraint: NSLayoutConstraint!

  lazy var loginButton: UIButton = {
    let button = UIButton()
    button.setTitle("Login", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.setTitleColor(.highlightedLabel, for: .highlighted)
    button.setBackgroundImage(UIColor.systemGreen.image, for: .normal)
    button.setBackgroundImage(UIColor.systemGreen.highlighted.image, for: .highlighted)
    button.clipsToBounds = true
    button.layer.cornerRadius = 14
    return button
  }()

  convenience init() {
    self.init(frame: .zero)
    setupSubviews()
  }

  // MARK: - Subviews Setup

  private func setupSubviews() {
    backgroundColor = .systemBackground
    clipsToBounds = true

    setupLogoImage()
    setupEmailTextfield()
    setupPasswordTextField()
    setupLoginButton()
  }

  private func setupLogoImage() {
    let firebaseLogo = UIImage(named: "iotIcon")
    let imageView = UIImageView(image: firebaseLogo)
    imageView.contentMode = .scaleAspectFit
    addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -55),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 55),
      imageView.widthAnchor.constraint(equalToConstant: 280),
      imageView.heightAnchor.constraint(equalToConstant: 280),
    ])
  }

  private func setupEmailTextfield() {
    emailTextField = textField(placeholder: "Email", symbolName: "person.crop.circle")
    emailTextField.translatesAutoresizingMaskIntoConstraints = false
    addSubview(emailTextField)
    NSLayoutConstraint.activate([
      emailTextField.leadingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.leadingAnchor,
        constant: 15
      ),
      emailTextField.trailingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.trailingAnchor,
        constant: -15
      ),
      emailTextField.heightAnchor.constraint(equalToConstant: 45),
    ])
      
    emailTopConstraint = emailTextField.topAnchor.constraint(
      equalTo: safeAreaLayoutGuide.topAnchor,
      constant: 50
    )
    emailTopConstraint.isActive = true
  }

  private func setupPasswordTextField() {
    passwordTextField = textField(placeholder: "Password", symbolName: "lock.fill")
    passwordTextField.translatesAutoresizingMaskIntoConstraints = false
    addSubview(passwordTextField)
    NSLayoutConstraint.activate([
      passwordTextField.leadingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.leadingAnchor,
        constant: 15
      ),
      passwordTextField.trailingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.trailingAnchor,
        constant: -15
      ),
      passwordTextField.heightAnchor.constraint(equalToConstant: 45),
    ])

    let constant: CGFloat = UIDevice.current.orientation.isLandscape ? 5 : 20
    passwordTopConstraint =
      passwordTextField.topAnchor.constraint(
        equalTo: emailTextField.bottomAnchor,
        constant: constant
      )
    passwordTopConstraint.isActive = true
  }

  private func setupLoginButton() {
    addSubview(loginButton)
    loginButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      loginButton.leadingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.leadingAnchor,
        constant: 15
      ),
      loginButton.trailingAnchor.constraint(
        equalTo: safeAreaLayoutGuide.trailingAnchor,
        constant: -15
      ),
      loginButton.heightAnchor.constraint(equalToConstant: 45),
      loginButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 5),
    ])
  }

  // MARK: - Private Helpers

  private func textField(placeholder: String, symbolName: String) -> UITextField {
    let textfield = UITextField()
    textfield.backgroundColor = .secondarySystemBackground
    textfield.layer.cornerRadius = 14
    textfield.placeholder = placeholder
    textfield.tintColor = .systemGreen
    let symbol = UIImage(systemName: symbolName)
    textfield.setImage(symbol)
    return textfield
  }
}
