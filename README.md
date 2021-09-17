What is it
----------

Library for implement Yandex Checkout functionality on React Native environment.

Android library: [5.1.2](https://github.com/yandex-money/yandex-checkout-android-sdk)

iOS library: [5.4.1](https://github.com/yoomoney/yookassa-payments-swift/tree/57a7c596c5069cc322b3ab18936970f240df0699)

![v1](./.github/v1.gif)

Usage
=====

[How to get client id](https://github.com/yoomoney/yookassa-payments-swift/tree/57a7c596c5069cc322b3ab18936970f240df0699#%D0%BA%D0%B0%D0%BA-%D0%BF%D0%BE%D0%BB%D1%83%D1%87%D0%B8%D1%82%D1%8C-client-id-%D1%86%D0%B5%D0%BD%D1%82%D1%80%D0%B0-%D0%B0%D0%B2%D1%82%D0%BE%D1%80%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D0%B8-%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D1%8B-%D1%8Emoney)

```ts
import YandexPayment, { Shop, Payment, PaymentToken } from 'react-native-yandex-payment';

const shop: Shop = {
    id: 'SHOP_ID',
    token: 'test_SHOP_TOKEN',
    name: 'Shop name',
    description: 'Shop description',
    applePayMerchantIdentifier: 'merchant.com.site',
    customColor: 'rgba(0, 0, 0, 1)'
}
const payment: Payment = {
    amount: 399.99,
    currency: 'RUB', // 'RUB' | 'USD' | 'EUR'
    types: ['BANK_CARD'], // 'YOO_MONEY' | 'BANK_CARD' | 'SBERBANK' | 'PAY'. PAY - means Google Pay or Apple Pay
    savePaymentMethod: 'USER_SELECTS', // 'ON' | 'OFF' | 'USER_SELECTS'
    yooKassaClientId: '', // See how to get client id
}
const paymentToken: PaymentToken = await YandexPayment.show(shop, payment)
console.warn(paymentToken.token) // payment token
console.warn(paymentToken.type) // payment method type
```

Install
=======

```bash
npm install react-native-yandex-payment@https://github.com/YuriFA/react-native-yookassa-payment --save 
```
or
```bash
yarn add react-native-yandex-payment@https://github.com/YuriFA/react-native-yookassa-payment
```

Android
-------

Add Yandex repository inside `android/build.gradle`
```groovy
allprojects {
    repositories {
      ...
      maven { url 'https://dl.bintray.com/yandex-money/maven' }    
    }
}
```

Enable multidex if needed in `android/app/build.gradle`
```diff
android {
    defaultConfig {
        ...
+        multiDexEnabled true
    }
}

dependencies {
    ...
+    implementation 'androidx.multidex:multidex:2.0.1'
}
```

Add Yandex Client ID in `android/app/build.gradle`
```groovy
android {
    defaultConfig {
        manifestPlaceholders = [YANDEX_CLIENT_ID: "ваш id приложения в Яндекс.Паспорте"]
    }
}
```

iOS
---

See instructions in [YooKassa SDK README](https://github.com/yoomoney/yookassa-payments-swift/tree/57a7c596c5069cc322b3ab18936970f240df0699#cocoapods)
Update your `ios/Podfile`
```ruby
target 'MyApp' do

    # ... other dependencies

  # Yandex (YooKassa) payment
  pod 'MyFramework', :path => '../node_modules/react-native-yandex-payment/ios/MyFramework.podspec'

  pod 'YooKassaPayments', 
  :build_type => :dynamic_framework,
  :git => 'https://github.com/yoomoney/yookassa-payments-swift.git',
  :tag => '5.4.1'

end
```

Install pods in `ios`
```bash
pod install
```

Open newly generated `.xcworkspace` in XCode and create new swift file. 
Be sure, that it have Foundation import
```swift
import Foundation
```

Create `Frameworks` directory inside `ios` folder
```bash
cd ios && mkdir Frameworks
```

Put inside `ios/Frameworks` `TrustDefender.framework` (you should receive your own TrustDefender.framework from Yandex support).

Be sure, that TrustDefender has Header folder inside it
![trustdefender](./.github/trustdefender.png)

Roadmap
=======

- [x] React Native 60.5
- [x] Types embedded
- [x] Android support
- [x] iOS support
- [x] Bank card, Yandex Wallet, Sberbank, Google Pay and Apple Pay payment types support (you should properly configure your shop for this)
- [x] Change color scheme
- [ ] Configure test environment

If you have a question or need specific feature, feel free to [open an issue](https://github.com/YuriFA/react-native-yookassa-payment/issues/new) or create pull request.


---
```
The MIT License

Copyright (c) 2010-2019 Lamantin Group, LTD. https://lamantin.group

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
