import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart' hide CardType;
import 'package:gulfpgb/tap_loader/awesome_loader.dart';

import '../payment/paypal_payment.dart';
import '../payment/pay_u_money.dart';
import '../helpers/current_user.dart';
import '../helpers/app_config.dart';


import 'package:go_sell_sdk_flutter/go_sell_sdk_flutter.dart';
import 'package:go_sell_sdk_flutter/model/models.dart';
import '../helpers/current_user.dart';



class PaymentMethodsScreen extends StatefulWidget {
  static const routeName = '/payment-methods';

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final payStack = PaystackPlugin();
  Map<dynamic, dynamic> tapSDKResult;
  String responseID = "";
  String sdkStatus = "";
  String sdkErrorCode;
  String sdkErrorMessage;
  String sdkErrorDescription;
  AwesomeLoaderController loaderController = AwesomeLoaderController();
  Color _buttonColor;

  @override
  void initState() {
    payStack.initialize(
      publicKey: AppConfig.paystackPublicKey,
    );
    super.initState();
    _buttonColor = Color(0xff2ace00);
    configureSDK();
  }

  // configure SDK
  Future<void> configureSDK() async {
    // configure app
    configureApp();
    // sdk session configurations
    //setupSDKSession();
  }

  // configure app key and bundle-id (You must get those keys from tap)
  Future<void> configureApp() async {
    GoSellSdkFlutter.configureApp(
        bundleId: "com.hostyler.aopgr",
        productionSecreteKey: Platform.isAndroid? "sk_live_axI1LQFP6u5pryC3DsqgYZoW" : "sk_live_F86Sq3TluIxscg2bw1MivHAE",
        sandBoxsecretKey: Platform.isAndroid? "sk_test_3XhLECVnRbW4MJtpixYQeco8" : "sk_test_9FiMZoCuQSgURaOALD0wVnc1",
        lang: "ar");
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> setupSDKSession(String price, String title) async {

    try {
      print("Price + Title");
      print(price + title);
      print("CurrentUserInfo");
      print(CurrentUser.name + CurrentUser.id);
      GoSellSdkFlutter.sessionConfigurations(
          trxMode: TransactionMode.PURCHASE,
          transactionCurrency: "kwd",
          amount: price,
          customer: Customer(
              customerId: "", // customer id is important to retrieve cards saved for this customer
              email: CurrentUser.email,
              isdNumber: "965",
              number: "00000000",
              firstName: CurrentUser.name,
              middleName: "",
              lastName: "",
              metaData: null),
          // Post URL
          postURL: "https://tap.company",
          // Payment description
          paymentDescription: "",
          // Payment Reference
          paymentReference: Reference(
              acquirer: "acquirer", gateway: "gateway", payment: "payment", track: "track", transaction: "trans_" + CurrentUser.id, order: "order_" + CurrentUser.id),
          // payment Descriptor
          paymentStatementDescriptor: "",
          // Save Card Switch
          isUserAllowedToSaveCard: false,
          // Enable/Disable 3DSecure
          isRequires3DSecure: true,
          // Receipt SMS/Email
          receipt: Receipt(true, false),
          // Authorize Action [Capture - Void]
          authorizeAction: AuthorizeAction(type: AuthorizeActionType.CAPTURE, timeInHours: 10),
          // Destinations
          destinations: null,
          // merchant id
          merchantID: "15775160",
          // Allowed cards
          allowedCadTypes: CardType.ALL,
          applePayMerchantID: "applePayMerchantID",
          allowsToSaveSameCardMoreThanOnce: false,
          // pass the card holder name to the SDK
          cardHolderName: CurrentUser.name,
          // disable changing the card holder name by the user
          allowsToEditCardHolderName: true,
          // select payments you need to show [Default is all, and you can choose between WEB-CARD-APPLEPAY ]
          paymentType: PaymentType.ALL,
          // Transaction mode
          sdkMode: SDKMode.Production);
      // sdkMode: SDKMode.Production
    } on PlatformException {
      // platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      tapSDKResult = {};
    });
  }

  Future<void> startSDK() async {
    setState(() {
      loaderController.start();
    });

    tapSDKResult = await GoSellSdkFlutter.startPaymentSDK;
    loaderController.stopWhenFull();

    print('>>>> ${tapSDKResult['sdk_result']}');
    setState(() {
      switch (tapSDKResult['sdk_result']) {
        case "SUCCESS":
          print("SUCCESS");
          sdkStatus = "تم الدفع بنجاح";
          handleSDKResult();
          break;
        case "FAILED":
          print("FAILED");
          sdkStatus = "حدث خطأ,حاول مرة اخرى";
          handleSDKResult();
          break;
        case "حدث خطأ,حاول مرة اخرى":

          print('sdk error............');
          print(tapSDKResult['sdk_error_code']);
          print(tapSDKResult['sdk_error_message']);
          print(tapSDKResult['sdk_error_description']);
          print('sdk error............');
          sdkErrorCode = tapSDKResult['sdk_error_code'].toString();
          sdkErrorMessage = tapSDKResult['sdk_error_message'];
          sdkErrorDescription = tapSDKResult['sdk_error_description'];
          break;

        case "NOT_IMPLEMENTED":
          sdkStatus = "NOT_IMPLEMENTED";
          break;
      }
    });
  }

  void handleSDKResult() {
    switch (tapSDKResult['trx_mode']) {
      case "CHARGE":
        printSDKResult('Charge');
        break;

      case "AUTHORIZE":
        printSDKResult('Authorize');
        break;

      case "SAVE_CARD":
        printSDKResult('Save Card');
        break;

      case "TOKENIZE":
        print('TOKENIZE token : ${tapSDKResult['token']}');
        print('TOKENIZE token_currency  : ${tapSDKResult['token_currency']}');
        print('TOKENIZE card_first_six : ${tapSDKResult['card_first_six']}');
        print('TOKENIZE card_last_four : ${tapSDKResult['card_last_four']}');
        print('TOKENIZE card_object  : ${tapSDKResult['card_object']}');
        print('TOKENIZE card_exp_month : ${tapSDKResult['card_exp_month']}');
        print('TOKENIZE card_exp_year    : ${tapSDKResult['card_exp_year']}');

        responseID = tapSDKResult['token'];
        break;
    }
  }

  void printSDKResult(String trx_mode) {
    print('$trx_mode status                : ${tapSDKResult['status']}');
    print('$trx_mode id               : ${tapSDKResult['charge_id']}');
    print('$trx_mode  description        : ${tapSDKResult['description']}');
    print('$trx_mode  message           : ${tapSDKResult['message']}');
    print('$trx_mode  card_first_six : ${tapSDKResult['card_first_six']}');
    print('$trx_mode  card_last_four   : ${tapSDKResult['card_last_four']}');
    print('$trx_mode  card_object         : ${tapSDKResult['card_object']}');
    print('$trx_mode  card_brand          : ${tapSDKResult['card_brand']}');
    print('$trx_mode  card_exp_month  : ${tapSDKResult['card_exp_month']}');
    print('$trx_mode  card_exp_year: ${tapSDKResult['card_exp_year']}');
    print('$trx_mode  acquirer_id  : ${tapSDKResult['acquirer_id']}');
    print('$trx_mode  acquirer_response_code : ${tapSDKResult['acquirer_response_code']}');
    print('$trx_mode  acquirer_response_message: ${tapSDKResult['acquirer_response_message']}');
    print('$trx_mode  source_id: ${tapSDKResult['source_id']}');
    print('$trx_mode  source_channel     : ${tapSDKResult['source_channel']}');
    print('$trx_mode  source_object      : ${tapSDKResult['source_object']}');
    print('$trx_mode source_payment_type : ${tapSDKResult['source_payment_type']}');
    responseID = tapSDKResult['charge_id'];
  }


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> pushedMap =
        ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Methods',
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
      ),
      body: Container(
    constraints: BoxConstraints.expand(),
    height: double.infinity,
    width: double.infinity,
    decoration: BoxDecoration(
    image: DecorationImage(
    fit: BoxFit.fill,
    image: ExactAssetImage('assets/images/background.jpeg'),
    ),
    ), child:Padding(
    padding:const EdgeInsets.only(
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    ),
    child:Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Container(
              child: SizedBox(
                  height: 45,
                  child: RaisedButton(
                    color: Colors.amber,
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.all(Radius.circular(30))),
                    onPressed: () {
                      startSDK(); //fun1
                      print("It Worked"); //fun2
                      setupSDKSession('${double.parse(pushedMap['price'])}','Subscription: ${pushedMap['title']}');
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 25,
                        height: 25,
                        child: AwesomeLoader(
                          outerColor: Colors.white,
                          innerColor: Colors.white,
                          strokeWidth: 3.0,
                          controller: loaderController,
                        ),
                      ),
                      Spacer(),
                      Text('TAP PAY', style: TextStyle(color: Colors.white, fontSize: 16.0)),
                      Spacer(),
                      Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                      ),
                    ]),
                  )),
            ),
            if (AppConfig.paypalOn)
              ListTile(
                key: ValueKey('PayPal'),
                title: Text('PayPal'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/paypal.png',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => PaypalPayment(
                          'Subscription: ${pushedMap['title']}',
                          '${double.parse(pushedMap['price']) / 100}'),
                    ),
                  );
                },
              ),
            if (AppConfig.payUMoneyOn)
              ListTile(
                key: ValueKey('PayUMoney'),
                title: Text('PayUMoney'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/pay_u1.png',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => PayUMoney(
                        itemName: 'Subscription: ${pushedMap['title']}',
                        itemPrice: '${double.parse(pushedMap['price']) / 100}',
                        productDescription: 'Subscription for premium features',
                        buyerEmail: CurrentUser.email,
                        buyerFirstName: CurrentUser.name,
                        buyerLastName: CurrentUser.name,
                        buyerPhone: CurrentUser.name,
                      ),
                    ),
                  );
                },
              ),
            if (AppConfig.payStackOn)
              ListTile(
                key: ValueKey('PayStack'),
                title: Text('PayStack'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/paystack.png',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () async {
                  Charge charge = Charge()
                    ..amount = double.parse(pushedMap['price']).round()
                    ..reference = _getReference()
                    // or ..accessCode = _getAccessCodeFrmInitialization()
                    // ..currency = 'MDL'
                    ..email = 'customer@email.com';
                  CheckoutResponse response = await payStack.checkout(
                    context,
                    method: CheckoutMethod
                        .card, // Defaults to CheckoutMethod.selectable
                    charge: charge,
                  );
                  print(response);
                },
              ),

            Container(
              child: Text("$sdkStatus",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.w400, fontFamily: "Roboto", fontStyle: FontStyle.normal, fontSize: 25.0),
                  textAlign: TextAlign.center),
            ),

          ],
        ),
      ),
    ),
      ),
    );
  }
}

String _getReference() {
  String platform;
  if (Platform.isIOS) {
    platform = 'iOS';
  } else {
    platform = 'Android';
  }

  return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
}
