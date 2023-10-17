//
//  DeviceControlViewController.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-12.
//

import UIKit

class DeviceControlViewController: UIViewController {
    
    private var humidifierState: Bool = false
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
        button.backgroundColor = visitorColor
        button.setBackgroundImage(UIColor.systemGreen.highlighted.image, for: .highlighted)
        button.setTitle("Turn on", for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    
    // 设备开关状态
    private var isDeviceOn: Bool = false {
        didSet {
            if isDeviceOn {
                deviceSwitchButton.setTitle("Turn on", for: .normal)
                deviceSwitchButton.backgroundColor = UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1.0)  // A modern shade of green
            } else {
                deviceSwitchButton.setTitle("Turn off", for: .normal)
                deviceSwitchButton.backgroundColor = .systemGray
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Control"
        self.view.backgroundColor = .white
        
        
        setupTableView()
        setupViewAllHistoryButton()
        setupDeviceSwitchButton()
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
        deviceSwitchButton.addTarget(self, action: #selector(toggleDevice), for: .touchUpInside)
        view.addSubview(deviceSwitchButton)
        deviceSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            deviceSwitchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deviceSwitchButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            deviceSwitchButton.widthAnchor.constraint(equalToConstant: 200),
            deviceSwitchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func toggleDevice() {
        isDeviceOn.toggle()
        // 这里可以加入其他逻辑，例如发送网络请求，来真正控制设备。
        
        humidifierState.toggle()
        
        history.insert(dateFormatter.string(from: Date()) + (humidifierState ? ": ON" : ": OFF"), at: 0)
        recentHistory.insert(dateFormatter.string(from: Date()) + (humidifierState ? ": ON" : ": OFF"), at: 0)
        
        // Show only the last 12 actions
        if recentHistory.count > 12 {
            recentHistory.removeLast()
        }
        tableView.reloadData()
    }
    
}

extension DeviceControlViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = recentHistory[indexPath.row]
        return cell
    }
    
    
}



class HistoryViewController: UIViewController {
    
    private var history: [String]
    private let tableView = UITableView()
    
    // 初始化视图控制器并传递历史记录数据
    init(history: [String]) {
        self.history = history
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "History"
        view.backgroundColor = .white
        
        setupTableView()
        
        // 添加一个关闭按钮
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeAction))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") ?? UITableViewCell(style: .default, reuseIdentifier: "HistoryCell")
        cell.textLabel?.text = history[indexPath.row]
        return cell
    }
}


