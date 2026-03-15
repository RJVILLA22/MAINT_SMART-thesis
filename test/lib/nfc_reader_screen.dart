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
          print(nfcData);
        });
        NfcManager.instance.stopSession();
      },
    );
  }

  Future<void> writeNFC(String message) async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        nfcData = "NFC is not available on this device";
      });
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
          setState(() {
            nfcData = "Message written: $message";
            print(nfcData);
          });
        } else {
          setState(() {
            nfcData = "Tag is not writable";
          });
        }
        NfcManager.instance.stopSession();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NFC Reader/Writer")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nfcData,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: startNFC, child: Text("Start NFC Read")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => writeNFC("Hello NFC"),
              child: Text("Write 'Hello NFC'"),
            ),
          ],
        ),
      ),
    );
  }
}
