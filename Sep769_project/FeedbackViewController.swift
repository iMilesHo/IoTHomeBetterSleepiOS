//
//  FeedbackViewController.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-13.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol DataTransferDelegate: AnyObject {
    func transfer(data: String, sleepQuality: Int)
}


class FeedbackViewController: UIViewController {
    private var history: [String] = []
    private var recentHistory: [String] = []
    private let tableView = UITableView()
    private let historyLabel = UILabel()
    private let viewAllHistoryButton = UIButton()
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    private let deviceSwitchButton: UIButton = {
        let button = UIButton()
        let visitorColor = UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1.0)  // A modern shade of green
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.highlightedLabel, for: .highlighted)
        button.setBackgroundImage(visitorColor.image, for: .normal)
        button.setBackgroundImage(UIColor.systemGreen.highlighted.image, for: .highlighted)
        button.setTitle("  Sleep Quality feedback  ", for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    
    private var sleepfeedbackmodels: [SleepQualituyFeedbackModel] = []
    private var documents: [DocumentSnapshot] = []

    fileprivate var query: Query? {
      didSet {
        if let listener = listener {
          listener.remove()
          observeQuery()
        }
      }
    }

    private var listener: ListenerRegistration?

    fileprivate func observeQuery() {
      guard let query = query else { return }
      stopObserving()

      // Display data from Firestore, part one
        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
          guard let snapshot = snapshot else {
            print("Error fetching snapshot results: \(error!)")
            return
          }
          let models = snapshot.documents.map { (document) -> SleepQualituyFeedbackModel in
            if let model = SleepQualituyFeedbackModel(dictionary: document.data()) {
              return model
            } else {
              // Don't use fatalError here in a real app.
              fatalError("Unable to initialize type \(SleepQualituyFeedbackModel.self) with dictionary \(document.data())")
            }
          }
          self.sleepfeedbackmodels = models
          self.documents = snapshot.documents

          
          self.tableView.reloadData()
        }

    }

    fileprivate func stopObserving() {
      listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("sleepQualityFeedback").order(by: "created", descending: true).limit(to: 50)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feedback"
        self.view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        setupTableView()
        //setupViewAllHistoryButton()
        setupDeviceSwitchButton()
        query = baseQuery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.setNeedsStatusBarAppearanceUpdate()
      observeQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      stopObserving()
    }
    
    func setupTableView() {
        historyLabel.text = "Recent Actions:"
        historyLabel.numberOfLines = 0
        historyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(historyLabel)
        
        NSLayoutConstraint.activate([
            historyLabel.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            historyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "historyCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let height = view.frame.height * 0.46
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 20),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    // 在 viewDidLoad() 方法中的某个位置
    func setupViewAllHistoryButton() {
        viewAllHistoryButton.setTitle("View All History", for: .normal)
        viewAllHistoryButton.setTitleColor(.black, for: .normal)
        viewAllHistoryButton.addTarget(self, action: #selector(viewAllHistory), for: .touchUpInside)
        viewAllHistoryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewAllHistoryButton)
        
        NSLayoutConstraint.activate([
            viewAllHistoryButton.topAnchor.constraint(equalTo: historyLabel.topAnchor, constant: -8),
            viewAllHistoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func viewAllHistory() {
        let historyVC = HistoryViewController(history: self.history)
        let navigationController = UINavigationController(rootViewController: historyVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func setupDeviceSwitchButton() {
        deviceSwitchButton.addTarget(self, action: #selector(feedbackSleepQuality), for: .touchUpInside)
        view.addSubview(deviceSwitchButton)
        deviceSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            deviceSwitchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviceSwitchButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            deviceSwitchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func feedbackSleepQuality() {
        let historyVC = SleepQualityFeedbackViewController(history: self.history)
        historyVC.delegate = self
        let navigationController = UINavigationController(rootViewController: historyVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    deinit {
      listener?.remove()
    }
    
}

extension FeedbackViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sleepfeedbackmodels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(sleepfeedbackmodels[indexPath.row].created))) + " sleep quality(1-10): \(sleepfeedbackmodels[indexPath.row].sleepQuaility)"
        return cell
    }
    
}

extension FeedbackViewController: DataTransferDelegate {
    func transfer(data: String, sleepQuality: Int){
        
        history.insert(data, at: 0)
        recentHistory.insert(data, at: 0)

        let userID = Auth.auth().currentUser?.uid ?? "anonymous"
        let created = Date().timeIntervalSince1970
        let sleepQuaility = sleepQuality

        // Write Data to Firestore
          let collection = Firestore.firestore().collection("sleepQualityFeedback")
          let sleepQuailityModel = SleepQualituyFeedbackModel(
            userID: userID,
            created: Int64(created),
            sleepQuaility: sleepQuaility
          )

          collection.addDocument(data: sleepQuailityModel.dictionary)
        tableView.reloadData()
    }
}


class SleepQualityFeedbackViewController: UIViewController {
    weak var delegate: DataTransferDelegate?

    private var buttons: [UIButton] = []
    private var history: [String]
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    init(history: [String]) {
        self.history = history
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Feedback"
        
        setupFeedbackButtons()
        // 添加一个关闭按钮
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeAction))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    func setupFeedbackButtons() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.contentMode = .scaleAspectFit
        
        for i in 1...10 {
            let button = UIButton(type: .system)
            button.setTitle("\(i)", for: .normal)
            button.setTitleColor(.black, for: .normal)
            
            // 设置按钮背景为图片，不显示按钮本身的颜色和形状
            button.setBackgroundImage(UIImage(named: "circleIconGray"), for: .normal)
            button.contentMode = .scaleAspectFit  // 保持图片的纵横比
            button.backgroundColor = .clear
            button.layer.cornerRadius = 0
            button.layer.masksToBounds = true
            
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.widthAnchor.constraint(equalToConstant: 44).isActive = true
            
            button.tag = i
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        for button in buttons {
            if button == sender {
                button.setBackgroundImage(UIImage(named: "circleIcon"), for: .normal)
                let description = dateFormatter.string(from: Date()) + " sleep quality(1-10): \(sender.tag)"
                delegate?.transfer(data: description, sleepQuality: sender.tag)
                closeAction()
            } else {
                button.setBackgroundImage(UIImage(named: "circleIconGray"), for: .normal)
            }
        }
    }
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
}



