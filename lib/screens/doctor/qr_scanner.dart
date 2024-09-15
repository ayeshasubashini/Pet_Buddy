import 'package:flutter/material.dart';
import 'package:pet_buddy/screens/doctor/pet_view.dart';
import 'package:pet_buddy/utils/colors.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;
  bool _isNavigating = false;

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      if (!_isNavigating) {
        setState(() {
          qrText = scanData.code;
        });

        if (qrText != null && qrText!.isNotEmpty) {
          _isNavigating = true; // Prevent further navigations

          // Stop the camera
          await controller.pauseCamera();

          // Navigate to PetView with QR data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PetView(qrData: qrText!), // Pass QR data
            ),
          ).then((_) {
            _isNavigating = false; // Reset the flag
          });
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      title: 'QR Scanner',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: secondaryColor,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
          title: const Text("QR Scanner", style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
