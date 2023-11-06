import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:testfluter/home/home_screen.dart';
import 'package:testfluter/res/colors.dart';
import 'package:testfluter/res/strings.dart';
import 'package:testfluter/utils/enums.dart';

class PairingDeviceScreen extends StatefulWidget {
  final String productId;
  final String productImage;
  final String productName;
  final String ssid;
  final String passwd;
  final int typeDevice;

  const PairingDeviceScreen(
      {super.key,
      required this.productId,
      required this.productImage,
      required this.productName,
      required this.ssid,
      required this.passwd,
      required this.typeDevice});

  @override
  State<PairingDeviceScreen> createState() => _PairingDeviceScreenState();
}

class _PairingDeviceScreenState extends State<PairingDeviceScreen> {
  static const channel = MethodChannel(Constants.CHANNEL);

  String ssid = "";
  String productId = "";
  String productImage = "";
  String productName = "";
  String passwd = "";
  bool isSearching = true;
  int deviceType = 0;

  @override
  void initState() {
    ssid = widget.ssid;
    passwd = widget.passwd;
    productId = widget.productId;
    productImage = widget.productImage;
    productName = widget.productName;
    deviceType = widget.typeDevice;
    configNetwork();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        centerTitle: true,
        title: const Text(
          Strings.pairing,
          style: TextStyle(
            color: AppColors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              stopPairDevice();
              navigateToHome();
            },
            child: const Text(
              Strings.cancel,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.blueLight,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Visibility(
          visible: isSearching,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.passthrough,
              children: [
                Center(
                  child: Lottie.asset("assets/lotties/loading.json"),
                ),
                Center(
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.0),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/smart_color.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> configNetwork() async {
    var res = await channel.invokeMethod(Methods.CONFIG_PAIR,
        <String, String>{"ssid": ssid, "networkPasswd": passwd});

    if (res == true) {
      pairDevice();
    }
  }

  Future<void> pairDevice() async {
    dynamic res = "";
    if (deviceType == Constants.TYPE_DEVICE_WIFI_1) {
      res = await channel.invokeMethod(Methods.START_PAIR_DEVICE_TYPE_301, <String, String>{});
    }

    if (deviceType == Constants.TYPE_DEVICE_WIFI_3) {
      res = await channel.invokeMethod(Methods.START_PAIR, <String, String>{});
    }


    if (res == Constants.DEVICE_CONNECTED) {
      navigateToHome();
    }
  }

  Future<void> stopPairDevice() async {
    if (deviceType == Constants.TYPE_DEVICE_WIFI_1) {
      dynamic res = await channel.invokeMethod(Methods.STOP_PAIR_DEVICE_TYPE_301, <String, String>{
        "ssid": ssid,
        "networkPasswd": passwd
      });

      print(">>>>>>>>>>>> res");
      print(res);

      if (res != null) {
        navigateToHome();
      }

    } else {
      await channel.invokeMethod(Methods.STOP_PAIR, <String, String>{});
    }
  }

  void navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
      ModalRoute.withName('/home'),
    );
  }
}
