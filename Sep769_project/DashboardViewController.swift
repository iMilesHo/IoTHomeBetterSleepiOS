//
//  DashboardViewController.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-12.
//

import UIKit
import Charts
import FirebaseFirestore
import FirebaseAuth

struct TimeSeriesData {
    var time: Date
    var value: Double
}

// 自定义X轴的时间格式
class ChartXAxisFormatter: NSObject, AxisValueFormatter {
    var referenceTimeInterval: TimeInterval
    var dateFormatter: DateFormatter
    
    init(referenceTimeInterval: TimeInterval, dateFormatter: DateFormatter) {
        self.referenceTimeInterval = referenceTimeInterval
        self.dateFormatter = dateFormatter
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}

class DashboardViewController: UIViewController {
    // 创建图表控件
    var temperatureChartView: LineChartView!
    var humidityChartView: LineChartView!
    var noiseChartView: LineChartView!
    
    // 加载指示器
    var activityIndicator: UIActivityIndicatorView!
    
    // 添加日期选择器属性
    var datePicker: UIDatePicker!
    
    // 房间选择器
    var roomSegmentedControl: UISegmentedControl!
    
    var currentDate: Int64 = 0
    
    private var humiTempSounds: [HumiTempSoundModel] = []
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
        guard var query = query else { return }
        stopObserving()
        // 开始加载指示
        activityIndicator.startAnimating()
        
        
        // Display data from Firestore, part one
        listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            let models = snapshot.documents.compactMap { (document) -> HumiTempSoundModel? in
                return HumiTempSoundModel(dictionary: document.data())
            }
            self.humiTempSounds = models
            self.documents = snapshot.documents
            
            loadData()
            // 停止加载指示器
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    func filteredobserveQuery(){
        let date = datePicker.date
        
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
    }
    
    fileprivate func baseQuery() -> Query {
        var baseQuery1 = Firestore.firestore().collection("humiTempSound").whereField("userID", isEqualTo: "darktalent")//darktalentDefault-01
        baseQuery1 = baseQuery1.whereField("EdgeDeviceID", isEqualTo: "darktalentDefault-01")
        baseQuery1 = baseQuery1.whereField("created", isLessThan: 1000000000000)
        
        return baseQuery1.order(by: "created", descending: true).limit(to: 24)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Dashboard"
        
        query = baseQuery()
        
        setupRoomSelector() // 设置房间选择器
        setupDatePicker() // 设置日期选择器
        setupCharts()
        setupActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        observeQuery()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }
    
    func setupRoomSelector() {
        let rooms = ["Living Room", "Bedroom", "Kitchen"]
        roomSegmentedControl = UISegmentedControl(items: rooms)
        roomSegmentedControl.selectedSegmentIndex = 0
        roomSegmentedControl.addTarget(self, action: #selector(roomChanged), for: .valueChanged)
        view.addSubview(roomSegmentedControl)
        
        roomSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roomSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            roomSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            roomSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func roomChanged() {
        loadData() // 当房间更改时重新加载数据
    }
    
    func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()  // 设置最大日期为当前日期
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        // 日期选择器的布局约束
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            datePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // 添加日期更改事件
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    @objc func dateChanged() {
        let selectedDate = datePicker.date
        let calendar = Calendar.current

        let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        guard let startDate = calendar.date(from: components) else {
            fatalError("Couldn't create the start date.")
        }

        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
            fatalError("Couldn't create the end date.")
        }

        let startTimestamp = startDate.timeIntervalSince1970
        let endTimestamp = endDate.timeIntervalSince1970
        
        var filtered = Firestore.firestore().collection("humiTempSound").whereField("userID", isEqualTo: "darktalent")//darktalentDefault-01
        filtered = filtered.whereField("EdgeDeviceID", isEqualTo: "darktalentDefault-01")
        filtered = filtered.whereField("created", isGreaterThanOrEqualTo: startTimestamp)
        filtered = filtered.whereField("created", isLessThan: endTimestamp)
        filtered = filtered.order(by: "created")
        self.query = filtered.limit(to: 100)
        //observeQuery()
        
        //loadData()
    }
    
    func setupCharts() {
        // Temperature Chart
        let temperatureTitleLabel = UILabel()
        temperatureTitleLabel.text = "Temperature"
        temperatureTitleLabel.textAlignment = .center
        
        temperatureChartView = LineChartView()
        temperatureChartView.delegate = self

        // ... [其他初始化设置]
        
        // Humidity Chart
        let humidityTitleLabel = UILabel()
        humidityTitleLabel.text = "Humidity"
        humidityTitleLabel.textAlignment = .center
        
        humidityChartView = LineChartView()
        humidityChartView.delegate = self
        // ... [其他初始化设置]
        
        // Noise Chart
        let noiseTitleLabel = UILabel()
        noiseTitleLabel.text = "Noise Level"
        noiseTitleLabel.textAlignment = .center
        
        noiseChartView = LineChartView()
        noiseChartView.delegate = self
        // ... [其他初始化设置]
        
        // ... 这里可以进行更多的图表自定义，例如颜色、轴标签等
        temperatureChartView.xAxis.labelRotationAngle = 45.0
        humidityChartView.xAxis.labelRotationAngle = 45.0
        noiseChartView.xAxis.labelRotationAngle = 45.0
        
        temperatureChartView.xAxis.labelPosition = .bottom
        humidityChartView.xAxis.labelPosition = .bottom
        noiseChartView.xAxis.labelPosition = .bottom
        
        let temperatureStack = UIStackView(arrangedSubviews: [temperatureTitleLabel, temperatureChartView])
        temperatureStack.axis = .vertical
        temperatureStack.spacing = 5
        
        let humidityStack = UIStackView(arrangedSubviews: [humidityTitleLabel, humidityChartView])
        humidityStack.axis = .vertical
        humidityStack.spacing = 5
        
        let noiseStack = UIStackView(arrangedSubviews: [noiseTitleLabel, noiseChartView])
        noiseStack.axis = .vertical
        noiseStack.spacing = 5
        
        let mainStackView = UIStackView(arrangedSubviews: [temperatureStack, humidityStack, noiseStack])
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 0
        
        view.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: roomSegmentedControl.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: datePicker.topAnchor, constant: -20)
        ])
    }
    
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func loadData() {
//        if self.humiTempSounds.count > 0 {
//            currentDate = self.humiTempSounds[0].created
//        }
//        
//        let dateFromTimestamp = Date(timeIntervalSince1970: TimeInterval(currentDate))
//
//        datePicker = UIDatePicker()
//        datePicker.date = dateFromTimestamp
        
        let humidityEntries = self.humiTempSounds.map { ChartDataEntry(x: Double($0.created*1000), y: $0.humidity) }
        let TempEntries = self.humiTempSounds.map { ChartDataEntry(x: Double($0.created*1000), y: $0.temperature) }
        let SoundEntries = self.humiTempSounds.map { ChartDataEntry(x: Double($0.created*1000), y: $0.noiseLevel) }
        
        self.updateChartData(with: humidityEntries, chartView: self.temperatureChartView)
        self.updateChartData(with: TempEntries, chartView: self.humidityChartView)
        self.updateChartData(with: SoundEntries, chartView: self.noiseChartView)
        
       
        // 模拟网络请求
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            let temperatureData = self.generateMockData(for: 24)
//            let humidityData = self.generateMockData(for: 24)
//            let noiseData = self.generateMockData(for: 24)
//            
//            self.updateChartData(with: temperatureData, chartView: self.temperatureChartView)
//            self.updateChartData(with: humidityData, chartView: self.humidityChartView)
//            self.updateChartData(with: noiseData, chartView: self.noiseChartView)
//            
//            // 停止加载指示器
//            self.activityIndicator.stopAnimating()
//        }
    }
    
    
    // 示例函数: 更新图表数据
    func updateChartData(with entries: [ChartDataEntry], chartView: LineChartView) {
        let dataSet = LineChartDataSet(entries: entries)
        dataSet.colors = [NSUIColor.gray] // 可以设置线的颜色
        dataSet.valueColors = [NSUIColor.black] // 可以设置值的颜色
        
        // 优化图表显示风格
        dataSet.mode = .linear
        dataSet.lineWidth = 2
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        
        let data = LineChartData(dataSets: [dataSet])
        chartView.data = data
        chartView.legend.enabled = false // 隐藏图例
        
        // 设置x轴的标签为时间
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let xAxisValueFormatter = ChartXAxisFormatter(referenceTimeInterval: 3600, dateFormatter: formatter)
        chartView.xAxis.valueFormatter = xAxisValueFormatter
        
        // Enable zoom and scroll
        chartView.scaleYEnabled = false
        chartView.dragEnabled = true
        chartView.dragXEnabled = true
        chartView.dragYEnabled = false
        chartView.pinchZoomEnabled = true
        
        chartView.xAxis.labelRotationAngle = 45 // Rotate labels for better visibility
        chartView.xAxis.setLabelCount(5, force: false) // Set the desired number of labels
    }
    
    // 修改生成数据函数，使其基于所选日期
    func generateMockData(for hours: Int) -> [TimeSeriesData] {
        var data = [TimeSeriesData]()
        
        let calendar = Calendar.current
        let selectedDate = datePicker.date
        
        for hour in 0..<hours {
            let time = calendar.date(byAdding: .hour, value: -hour, to: selectedDate)!
            let value = Double.random(in: 0...100)  // 生成0到100之间的随机数值
            data.append(TimeSeriesData(time: time, value: value))
        }
        
        return data.reversed()  // 因为我们是从所选日期开始的，所以需要将数组反转
    }
    
    deinit {
        listener?.remove()
    }
}

extension DashboardViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let timestamp = entry.x
        let date = Date(timeIntervalSince1970: timestamp)
        
        // Use the date object to extract the exact time
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: date)
        print(timeString)
    }
}

extension DashboardViewController {
    
    func query(withCategory category: String?, city: String?, price: Int?, sortBy: String?) -> Query {
        var filtered = baseQuery()
        
        // Sorting and Filtering Data
        if let category = category, !category.isEmpty {
            filtered = filtered.whereField("category", isEqualTo: category)
        }
        
        if let city = city, !city.isEmpty {
            filtered = filtered.whereField("city", isEqualTo: city)
        }
        
        if let price = price {
            filtered = filtered.whereField("price", isEqualTo: price)
        }
        
        if let sortBy = sortBy, !sortBy.isEmpty {
            filtered = filtered.order(by: sortBy)
        }
        
        return filtered
    }
    
    func controller(didSelectCategory category: String?,
                    city: String?,
                    price: Int?,
                    sortBy: String?) {
        let filtered = query(withCategory: category, city: city, price: price, sortBy: sortBy)
        
        self.query = filtered
        observeQuery()
    }
    
}
