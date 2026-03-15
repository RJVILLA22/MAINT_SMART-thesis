import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCReaderScreen extends StatefulWidget {
  @override
  _NFCReaderScreenState createState() => _NFCReaderScreenState();
}

class _NFCReaderScreenState extends State<NFCReaderScreen> {
  String nfcData = "Tap an NFC tag";

  Future<void> startNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        nfcData = "NFC is not available on this device";
      });
      return;
    }
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        setState(() {
          nfcData = tag.data.toString();
        });
        NfcManager.instance.stopSession();
      },
    );
  }

  Future<void> writeNFC(String message) async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        Ndef? ndef = Ndef.from(tag);
        if (ndef != null && ndef.isWritable) {
          NdefMessage ndefMessage = NdefMessage([
            NdefRecord.createText(message),
          ]);
          await ndef.write(ndefMessage);
        }
        NfcManager.instance.stopSession();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
