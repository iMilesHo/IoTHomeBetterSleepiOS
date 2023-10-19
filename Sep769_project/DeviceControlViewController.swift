//
//  DeviceControlViewController.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-12.
//

import UIKit
import CocoaMQTT
import FirebaseFirestore
import FirebaseAuth

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
    
    var mqtt: CocoaMQTT!
    
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
    
    private var turnOnOffRecordModels: [TurnOnOffRecordModel] = []
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
          let models = snapshot.documents.map { (document) -> TurnOnOffRecordModel in
            if let model = TurnOnOffRecordModel(dictionary: document.data()) {
              return model
            } else {
              // Don't use fatalError here in a real app.
              fatalError("Unable to initialize type \(TurnOnOffRecordModel.self) with dictionary \(document.data())")
            }
          }
          self.turnOnOffRecordModels = models
          self.documents = snapshot.documents

          
          self.tableView.reloadData()
        }

    }

    fileprivate func stopObserving() {
      listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("humidifierTurnOnOffRecord").order(by: "created", descending: true).limit(to: 50)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Control"
        self.view.backgroundColor = .white
        
        query = baseQuery()
        
        setupTableView()
        //setupViewAllHistoryButton()
        setupDeviceSwitchButton()
        
        initializeMQTT()
        mqttConnect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeQuery()
        if mqtt.connState == .disconnected {
            mqttConnect()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      stopObserving()
    }
    
    func initializeMQTT() {
        let clientID = "iOSDevice-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: "test.mosquitto.org", port: 1883)
        mqtt.delegate = self
        mqtt.keepAlive = 3600
        mqtt.autoReconnect = true
    }
    
    func mqttConnect() {
        if !mqtt.connect() {
            updateConnectButton(isConnected: false, reason: "Unable to initiate connection")
        }
    }
    
    func updateConnectButton(isConnected: Bool, reason: String? = nil) {
        if isConnected {
            deviceSwitchButton.setTitle("Turn On/Off", for: .normal)
            deviceSwitchButton.isEnabled = true
        } else {
            deviceSwitchButton.setTitle("Connection Failed: \(reason ?? "Unknown Error")", for: .disabled)
            deviceSwitchButton.isEnabled = false
        }
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
        mqtt.publish("Team1/Power", withString: "\(humidifierState)", qos: .qos2)
        
        humidifierState.toggle()
        
        history.insert(dateFormatter.string(from: Date()) + (humidifierState ? ": ON" : ": OFF"), at: 0)
        recentHistory.insert(dateFormatter.string(from: Date()) + (humidifierState ? ": ON" : ": OFF"), at: 0)
        
        let userID = Auth.auth().currentUser?.uid ?? "anonymous"
        let created = Date().timeIntervalSince1970
        let state = humidifierState
        
        let collection = Firestore.firestore().collection("humidifierTurnOnOffRecord")
        let sleepQuailityModel = TurnOnOffRecordModel(
          userID: userID,
          created: Int64(created),
          turnOrOff: humidifierState
        )

        collection.addDocument(data: sleepQuailityModel.dictionary)
        
        tableView.reloadData()
    }
    
    deinit {
      listener?.remove()
    }
}

extension DeviceControlViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.turnOnOffRecordModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        let onOroff = turnOnOffRecordModels[indexPath.row].turnOrOff ? "on" : "off"
        cell.textLabel?.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(turnOnOffRecordModels[indexPath.row].created))) + " Turn  \(onOroff)"
        return cell
    }
}

extension DeviceControlViewController: CocoaMQTTDelegate {
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("mqttDidPing")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("mqttDidReceivePong")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck, id: ", id)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didReceiveMessage, topic: ",message.topic, ", payload: ", message.payload)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage, topic: ",message.topic, ", payload: ", message.payload)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("didSubscribeTopics, topics: ", "success:",success, "failed", failed)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("didUnsubscribeTopics, topics:", topics)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
            completionHandler(true)
        print("didReceive, trust:", trust)
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            updateConnectButton(isConnected: true)
            mqtt.publish("Team1/Power", withString: "false", qos: .qos2)
            mqtt.subscribe("Team1/PlugStatus", qos: .qos2)
        } else {
            updateConnectButton(isConnected: false, reason: "Connection refused: \(ack)")
        }
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        updateConnectButton(isConnected: false, reason: err?.localizedDescription)
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

