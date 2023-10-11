//
//  ViewController.swift
//  FuelCostCalculator
//
//  Created by Apollo on 10.10.2023.
//

import CoreLocation
import SnapKit
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var departureCoordinate: CLLocationCoordinate2D?
    private var arrivingCoordinate: CLLocationCoordinate2D?

    private let mainLabel: UILabel = {
        let mainText = UILabel()
        mainText.text = "Yakıt Ücreti Hesaplayıcı"
        mainText.textAlignment = .center
        mainText.font = .systemFont(ofSize: 30)
        mainText.textColor = .white
        return mainText
    }()
    private let departureTextField: UITextField = {
        let departures = UITextField()
        departures.placeholder = "Kalkış İli (Örn: Adana)"
        departures.textAlignment = .center
        departures.layer.cornerRadius = 10
        return departures
    }()
    private let arrivingTextField: UITextField = {
        let arriving = UITextField()
        arriving.placeholder = "Varış İli (Örn: Bolu)"
        arriving.textAlignment = .center
        arriving.layer.cornerRadius = 10
        return arriving
    }()
    private let fuelAskLabel: UILabel = {
        let askFuel = UILabel()
        askFuel.text = "Ortalama Yakıt Tüketiminiz: "
        askFuel.textColor = .white
        askFuel.font = .systemFont(ofSize: 19)
        return askFuel
    }()
    private let askFuelTextField: UITextField = {
        let askFuel = UITextField()
        askFuel.layer.cornerRadius = 15
        askFuel.textAlignment = .center
        askFuel.keyboardType = .decimalPad
        return askFuel
    }()
    private let currentFuelLabel: UILabel = {
        let currentFuel = UILabel()
        currentFuel.text = "Güncel Litre Fiyatı: "
        currentFuel.textColor = .white
        currentFuel.font = .systemFont(ofSize: 19)
        return currentFuel
    }()
    private let currentFuelPrice: UITextField = {
        let fuelPrice = UITextField()
        fuelPrice.layer.cornerRadius = 15
        fuelPrice.textAlignment = .center
        fuelPrice.keyboardType = .decimalPad
        return fuelPrice
    }()
    private let calculateButton: UIButton = {
        let calculate = UIButton()
        calculate.backgroundColor = UIColor(red: 0.60, green: 0.70, blue: 2.70, alpha: 1)
        calculate.setTitle("Hesapla", for: .normal)
        calculate.layer.cornerRadius = 10
        return calculate
    }()
    private let priceLabel: UILabel = {
        let price = UILabel()
        price.textColor = .white
        price.font = .systemFont(ofSize: 25)
        price.textAlignment = .center
        return price
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.50, green: 0.60, blue: 1.10, alpha: 1)
        configure()
        calculateButton.addTarget(self, action: #selector(handleCalculateButton), for: .touchUpInside)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    // MARK: - Selector
    
    @objc private func handleCalculateButton() {
        guard let departureAddress = departureTextField.text, !departureAddress.isEmpty,
              let arrivingAddress = arrivingTextField.text, !arrivingAddress.isEmpty,
              let fuelConsumptionText = askFuelTextField.text, !fuelConsumptionText.isEmpty,
              let fuelPriceText = currentFuelPrice.text, !fuelPriceText.isEmpty
        else {
            showAlert(message: "Lütfen tüm alanları doldurun.")
            return
        }
        geocodeAddress(departureAddress, isDeparture: true)
        geocodeAddress(arrivingAddress, isDeparture: false)
    }
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    func geocodeAddress(_ address: String, isDeparture: Bool) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if error != nil {
                self.showAlert(message: "Geçerli bir il adı giriniz.")
                return
            }
            if let placemark = placemarks?.first,
               let location = placemark.location
            {
                if isDeparture {
                    self.departureCoordinate = location.coordinate
                } else {
                    self.arrivingCoordinate = location.coordinate
                }
                if let departureCoordinate = self.departureCoordinate, let arrivingCoordinate = self.arrivingCoordinate {
                    let distance = self.calculateDistanceBetweenCoordinates(departureCoordinate, arrivingCoordinate)
                    let distanceKm = distance / 1000
                    let correctKm = distanceKm + (0.15 * distanceKm)
                    var finalPrice = correctKm
                    let doubleFuelPrice = Double(self.currentFuelPrice.text ?? "")
                    let doubleCarFuel = Double(self.askFuelTextField.text ?? "")
                    finalPrice = (((correctKm * doubleCarFuel!) / 100) * doubleFuelPrice!)
                    self.priceLabel.text = "Tahmini Yakıt Ücreti: \(Int(finalPrice)) TL"
                }
            }
        }
    }
    func calculateDistanceBetweenCoordinates(_ coordinate1: CLLocationCoordinate2D, _ coordinate2: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
        let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
        return location1.distance(from: location2)
    }
    func configure() {
        view.addSubview(mainLabel)
        view.addSubview(departureTextField)
        view.addSubview(arrivingTextField)
        view.addSubview(fuelAskLabel)
        view.addSubview(askFuelTextField)
        view.addSubview(currentFuelLabel)
        view.addSubview(currentFuelPrice)
        view.addSubview(calculateButton)
        view.addSubview(priceLabel)

        departureTextField.backgroundColor = .white
        arrivingTextField.backgroundColor = .white
        askFuelTextField.backgroundColor = .white
        currentFuelPrice.backgroundColor = .white

        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(60)
        }
        departureTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(120)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(45)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(45)
            make.height.equalTo(37)
        }
        arrivingTextField.snp.makeConstraints { make in
            make.top.equalTo(departureTextField).offset(60)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(45)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(45)
            make.height.equalTo(37)
        }
        fuelAskLabel.snp.makeConstraints { make in
            make.top.equalTo(arrivingTextField).offset(70)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(45)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.height.equalTo(30)
        }
        askFuelTextField.snp.makeConstraints { make in
            make.top.equalTo(arrivingTextField).offset(70)
            make.left.equalTo(fuelAskLabel).offset(235)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(45)
            make.height.equalTo(30)
        }
        currentFuelLabel.snp.makeConstraints { make in
            make.top.equalTo(fuelAskLabel).offset(45)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(45)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.height.equalTo(30)
        }
        currentFuelPrice.snp.makeConstraints { make in
            make.top.equalTo(askFuelTextField).offset(45)
            make.left.equalTo(currentFuelLabel).offset(235)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(45)
            make.height.equalTo(30)
        }
        calculateButton.snp.makeConstraints { make in
            make.top.equalTo(currentFuelLabel).offset(70)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(45)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(45)
            make.height.equalTo(45)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(calculateButton).offset(70)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(45)
        }
    }
}
