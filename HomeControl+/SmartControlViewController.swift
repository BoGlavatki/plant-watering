//
//  SmartControlViewController.swift
//  HomeControl+
//
//  Created by Boleslav Glavatki on 30.09.24.
//
import Charts
import UIKit

class SmartControlViewController: UIViewController, ChartViewDelegate {
    var model: SCModel? // Das Modell, das vom ersten ViewController übergeben wird
    var barChart = BarChartView()

    @IBOutlet weak var uiSubView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChart.delegate = self
        
        // Zeige die Details des Modells in den Labels an
        if let model = model {
            print("model.s_name, model.s_ip, model.s_port")
        }
        
        setupBarChart()
    }
    
    // MARK: - Setup BarChart
    func setupBarChart() {
        // Erstellen von Einträgen für das Diagramm
        var entries = [BarChartDataEntry]()
        for x in 0..<10 {
            entries.append(BarChartDataEntry(x: Double(x), y: Double(x)))
        }
        
        let set = BarChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.joyful()
        let data = BarChartData(dataSet: set)
        barChart.data = data
        
        // Sicherstellen, dass das Diagramm an den Bereich von uiSubView angepasst wird
        barChart.translatesAutoresizingMaskIntoConstraints = false
        uiSubView.addSubview(barChart)
        
        // Auto Layout Constraints für barChart, um es im Container (uiSubView) zu halten
        NSLayoutConstraint.activate([
            barChart.topAnchor.constraint(equalTo: uiSubView.topAnchor),
            barChart.bottomAnchor.constraint(equalTo: uiSubView.bottomAnchor),
            barChart.leadingAnchor.constraint(equalTo: uiSubView.leadingAnchor),
            barChart.trailingAnchor.constraint(equalTo: uiSubView.trailingAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keine Notwendigkeit mehr, den frame manuell festzulegen, da Auto Layout verwendet wird
    }
}
