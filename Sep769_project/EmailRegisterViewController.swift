//
//  EmailRegisterViewController.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-12.
//

import UIKit
import FirebaseAuth

class  EmailRegisterViewController: UIViewController {
    weak var delegate: LoginDelegate?
    
    private var registerView: EmailRegisterView { view as! EmailRegisterView }
    
    private var userName: String { registerView.userNameTextField.text! }
    private var email: String { registerView.emailTextField.text! }
    private var password: String { registerView.passwordTextField.text! }
    
    // Hides tab bar when view controller is presented
    override var hidesBottomBarWhenPushed: Bool { get { true } set {} }
    
    // MARK: - View Controller Lifecycle Methods
    
    override func loadView() {
        view = EmailRegisterView()
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
    private func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard error == nil else { return self.displayError(error) }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = self.userName
            changeRequest?.commitChanges { error in
              guard error == nil else { return self.displayError(error) }
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate {

                    let tabBarController = MainTabBarController()
                    sceneDelegate.window?.rootViewController = tabBarController
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    // MARK: - Action Handlers
    @objc
    private func handleCreateAccount() {
        createUser(email: email, password: password)
    }
    
    // MARK: - UI Configuration
    
    private func configureNavigationBar() {
        navigationItem.title = "Welcome"
        navigationItem.backBarButtonItem?.tintColor = .systemYellow
    }
    
    private func configureDelegatesAndHandlers() {
        registerView.userNameTextField.delegate = self
        registerView.emailTextField.delegate = self
        registerView.passwordTextField.delegate = self
        registerView.createAccountButton.addTarget(self, action: #selector(handleCreateAccount), for: .touchUpInside)
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        registerView.emailTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 15 : 50
        registerView.passwordTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 5 : 20
    }
}

// MARK: - UITextFieldDelegate

extension  EmailRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if registerView.emailTextField.isFirstResponder, registerView.passwordTextField.text!.isEmpty {
            registerView.passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}


/// Login View presented when peforming Email & Password Login Flow
class EmailRegisterView: UIView {
    var userNameTextField: UITextField! {
        didSet {
            userNameTextField.textContentType = .username
        }
    }
    
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
    
    var userNameTopConstraint: NSLayoutConstraint!
    var emailTopConstraint: NSLayoutConstraint!
    var passwordTopConstraint: NSLayoutConstraint!
    
    lazy var createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
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
        setupUserNameTextfield()
        setupEmailTextfield()
        setupPasswordTextField()
        setupCreateAccountButton()
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
    
    private func setupUserNameTextfield() {
        userNameTextField = textField(placeholder: "UserName", symbolName: "person.text.rectangle")
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(userNameTextField)
        NSLayoutConstraint.activate([
            userNameTextField.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: 15
            ),
            userNameTextField.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -15
            ),
            userNameTextField.heightAnchor.constraint(equalToConstant: 45),
        ])
        
        let constant: CGFloat = UIDevice.current.orientation.isLandscape ? 15 : 50
        userNameTopConstraint = userNameTextField.topAnchor.constraint(
            equalTo: safeAreaLayoutGuide.topAnchor,
            constant: constant
        )
        userNameTopConstraint.isActive = true
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
        
        let constant: CGFloat = UIDevice.current.orientation.isLandscape ? 5 : 20
        emailTopConstraint =
        emailTextField.topAnchor.constraint(
            equalTo: userNameTextField.bottomAnchor,
            constant: constant
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
    
    private func setupCreateAccountButton() {
        addSubview(createAccountButton)
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        let constant: CGFloat = UIDevice.current.orientation.isLandscape ? 5 : 20
        NSLayoutConstraint.activate([
            createAccountButton.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: 15
            ),
            createAccountButton.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -15
            ),
            createAccountButton.heightAnchor.constraint(equalToConstant: 45),
            createAccountButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: constant)
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
