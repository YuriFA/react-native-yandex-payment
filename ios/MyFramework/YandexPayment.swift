import Foundation

import YooKassaPayments
import YooKassaPaymentsApi


@objc(YandexPayment)
class YandexPayment: RCTViewManager, TokenizationModuleOutput {
    var storedResolver: RCTPromiseResolveBlock?
    var storedRejecter: RCTPromiseRejectBlock?
    var viewController: (UIViewController & TokenizationModuleInput)?
    
    @objc
    func show3ds(_ requestUrl: String,
                 resolver: @escaping RCTPromiseResolveBlock,
                 rejecter: @escaping RCTPromiseRejectBlock) -> Void {
        // decline previous callback
        if  self.storedRejecter != nil {
            self.storedRejecter?("decline","You are trying to show functionality without clossing previous",nil)
        }
        self.storedResolver = resolver
        self.storedRejecter = rejecter
        if let viewController = viewController {
            viewController.start3dsProcess(requestUrl: requestUrl)
        }
    }
    
    @objc
    func close() -> Void {
        if let viewController = viewController  {
            DispatchQueue.main.async {
                viewController.dismiss(animated: true)
            }
        }
    }
    
    @objc
    func attach(_ map: NSDictionary,
                resolver: @escaping RCTPromiseResolveBlock,
                rejecter: @escaping RCTPromiseRejectBlock) -> Void {
        // decline previous callback
        if  self.storedRejecter != nil {
            self.storedRejecter?("decline","You are trying to show functionality without clossing previous",nil)
        }
        self.storedResolver = resolver
        self.storedRejecter = rejecter
        
        let customizationColor = map["SHOP_CUSTOM_COLOR_RGBA"] as? String
        
        let shop = Shop(
            id: map["SHOP_ID"] as! String,
            token: map["SHOP_TOKEN"] as! String,
            name: map["SHOP_NAME"] as! String,
            description: map["SHOP_DESCRIPTION"] as! String,
            returnUrl: map["SHOP_RETURN_URL"] as? String,
            applePayMerchantIdentifier: map["SHOP_APPLEPAY_MERCHANT_IDENTIFIER"] as? String,
            customizationSettingsColor: (customizationColor != nil) ? UIColorFromString(string: customizationColor!) : nil
        )
        
        let payment = Payment(
            amount: map["PAYMENT_AMOUNT"] as! Double,
            currency: stringToCurrency(string: map["PAYMENT_CURRENCY"] as! String),
            types: arrayToSetPaymentTypes(nsArray: (map["PAYMENT_TYPES_ARRAY"] as! NSArray)),
            savePaymentMethod: stringToSavePaymentType(string: map["PAYMENT_SAVE_TYPE"] as! String),
            moneyAuthClientId: map["PAYMENT_YOO_MONEY_CLIENT_ID"] as? String,
            userPhoneNumber: map["PAYMENT_USER_PHONE"] as? String
        )
        
        let moduleInputData = TokenizationModuleInputData(
            clientApplicationKey: shop.token,
            shopName: shop.name,
            purchaseDescription: shop.description,
            amount: Amount(value: Decimal(payment.amount), currency: payment.currency),
            tokenizationSettings: TokenizationSettings(paymentMethodTypes: PaymentMethodTypes(rawValue: payment.types)),
            applePayMerchantIdentifier: shop.applePayMerchantIdentifier,
            userPhoneNumber: payment.userPhoneNumber,
            customizationSettings: shop.customizationSettingsColor != nil ? CustomizationSettings(mainScheme: shop.customizationSettingsColor!) : CustomizationSettings(),
            savePaymentMethod: payment.savePaymentMethod,
            moneyAuthClientId: payment.moneyAuthClientId
        )
        let inputData: TokenizationFlow = .tokenization(moduleInputData)
        
        DispatchQueue.main.async {
            self.viewController = TokenizationAssembly.makeModule(
                inputData: inputData,
                moduleOutput: self
            )
            let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
            rootViewController.present(self.viewController!, animated: true, completion: nil)
        }
    }
    
    // TokenizationModuleOutput interface callbacks
    func didSuccessfullyPassedCardSec(on module: TokenizationModuleInput) {
        DispatchQueue.main.async {
            if let resolver = self.storedResolver {
                resolver("RESULT_OK")
            }
            self.storedResolver = nil
            self.storedRejecter = nil
            self.viewController?.dismiss(animated: true)
        }
    }
    
    func didSuccessfullyConfirmation(paymentMethodType: YooKassaPayments.PaymentMethodType) {
        DispatchQueue.main.async {
            if let resolver = self.storedResolver {
                resolver("RESULT_OK")
            }
            self.storedResolver = nil
            self.storedRejecter = nil
            self.viewController?.dismiss(animated: true)
        }
    }
    
    func tokenizationModule(_ module: TokenizationModuleInput,
                            didTokenize token: YooKassaPayments.Tokens,
                            paymentMethodType: YooKassaPayments.PaymentMethodType) {
        if let resolver = self.storedResolver {
            resolver([
                token.paymentToken,
                paymentTypeToString(paymentType: paymentMethodType)
                ])
        }
        self.storedResolver = nil
        self.storedRejecter = nil
    }
        
    func didFinish(on module: TokenizationModuleInput, with error: YooKassaPaymentsError?) {
        DispatchQueue.main.async {
            if let rejecter = self.storedRejecter {
                rejecter("problems", "", error)
            }
            self.storedResolver = nil
            self.storedRejecter = nil
            self.viewController?.dismiss(animated: true)
        }
    }
    
//  #pragma mark - Helpers
    func paymentTypeToString(paymentType: YooKassaPayments.PaymentMethodType) -> String {
        switch paymentType {
            case .bankCard:
                return "BANK_CARD"
            case .yooMoney:
                return "YOO_MONEY"
            case .sberbank:
                return "SBERBANK"
            case .applePay:
                return "PAY"
            default:
              return "BANK_CARD"
        }
    }
    
    func arrayToSetPaymentTypes(nsArray: NSArray) -> Set<YooKassaPayments.PaymentMethodType> {
        var set: Set<YooKassaPayments.PaymentMethodType> = []

        let array: [String] = nsArray.compactMap({ ($0 as! String) })
        for type in array {
            if type == "YOO_MONEY" {
                set.insert(.yooMoney)
            } else if type == "BANK_CARD" {
                set.insert(.bankCard)
            } else if type == "SBERBANK" {
                set.insert(.sberbank)
            } else if type == "PAY" {
                set.insert(.applePay)
            }
        }
        
        if set.isEmpty {
            return [.bankCard, .yooMoney, .applePay, .sberbank]
        } else {
            return set
        }
    }
    
    func stringToSavePaymentType(string: String) -> YooKassaPayments.SavePaymentMethod {
        switch string {
            case "ON":
              return .on
            case "OFF":
              return .off
            case "USER_SELECTS":
              return .userSelects
            default:
              return .off
        }
    }
  
    func stringToCurrency(string: String) -> Currency {
        return Currency(rawValue: string)!
    }
    
    func UIColorFromString(string: String) -> UIColor {
        let componentsString = string.replacingOccurrences(of: "rgba(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: ", ", with: ",")
        let components = componentsString.split(separator: ",", maxSplits: 3)
        return UIColor(red: CGFloat((components[0] as NSString).floatValue),
                     green: CGFloat((components[1] as NSString).floatValue),
                      blue: CGFloat((components[2] as NSString).floatValue),
                     alpha: CGFloat((components[3] as NSString).floatValue))
    }
}

