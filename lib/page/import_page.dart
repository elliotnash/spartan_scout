import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:spartan_scout/provider/scouting_data_provider.dart';
import 'package:spartan_scout/provider/template_provider.dart';
import 'package:spartan_scout/widgets/snackbar.dart';

class ImportPage extends StatefulHookConsumerWidget {
  final ImportPageController? controller;
  const ImportPage({
    this.controller,
    super.key
  });

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> with AutomaticKeepAliveClientMixin<ImportPage> {
  @override
  bool get wantKeepAlive => true;

  bool permission = true;
  String? lastScan;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void initState() {
    widget.controller?.setActive = () async {
      await controller?.resumeCamera();
    };
    widget.controller?.setInactive = () async {
      await controller?.pauseCamera();
    };
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.setActive = () async {};
    widget.controller?.setInactive = () async {};
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!kIsWeb && Platform.isMacOS) {
      return MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
        onDetect: (capture) {
          for (final code in capture.barcodes) {
            if (code.rawValue != lastScan) {
              _onNewData(code.rawValue);
            }
            lastScan = code.rawValue;
          }
        },
      );
    } else {
      return Stack(
        children: [
          if (permission)
            const Center(
              child: CupertinoActivityIndicator(),
            ),
          QRView(
            key: qrKey,
            onQRViewCreated: (controller) {
              this.controller = controller;
              controller.scannedDataStream.listen((scanData) {
                if (scanData.code != lastScan) {
                  _onNewData(scanData.code);
                }
                lastScan = scanData.code;
              });
            },
            onPermissionSet: (controller, permission) {
              setState(() {
                this.permission = permission;
              });
            },
          ),
          if (!permission)
            Center(
              child: CupertinoButton(
                child: const Text("Grant camera permission"),
                onPressed: () async {
                  if (!(await Permission.camera.request().isGranted)) {
                    await openAppSettings();
                  }
                },
              ),
            ),
        ],
      );
    }
  }

  Future<void> _onNewData(String? code) async {
    if (code != null) {
      try {
        final map = jsonDecode(code);
        final data = await ref.read(templatesProvider.notifier).scoutingDataFromSimpleJson(map);
        await ref.read(scoutingDataListProvider(data.type).notifier).put(data);

        if (mounted) {
          await showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text("Imported Scouting Data!"),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Ok"),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        showSnackbar(const Text("Invalid QR Code scanned!"));
      }
    } else {
      showSnackbar(const Text("Invalid QR Code scanned!"));
    }
  }
}

class ImportPageController {
  Future<void> Function() setActive = () async {};
  Future<void> Function() setInactive = () async {};
}
