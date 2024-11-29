// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';

class RaspberryPiSSHConnection extends StatefulWidget {
  @override
  _RaspberryPiSSHConnectionState createState() =>
      _RaspberryPiSSHConnectionState();
}

class _RaspberryPiSSHConnectionState extends State<RaspberryPiSSHConnection> {
  final _commandController = TextEditingController();
  SSHClient? _sshClient;
  String _outputText = '-';
  bool _isConnected = false;

  Future<void> _executeCommand() async {
    if (_sshClient == null) return;

    try {
      final result = await _sshClient!.run(_commandController.text);
      setState(() {
        _outputText = String.fromCharCodes(result);
      });
    } catch (e) {
      setState(() {
        _outputText = 'Command Execution Failed: $e';
      });
    }
  }

  Future<void> connectToSshClient() async {
    try {
      _sshClient = SSHClient(
        await SSHSocket.connect("192.168.31.XX", 22,
            timeout: const Duration(seconds: 10)),
        username: 'pi',
        onPasswordRequest: () => "raspberry",
      );

      await _sshClient!.authenticated;

      setState(() {
        _isConnected = true;
      });

      log("Authenticated");
    } catch (e) {
      print(e);
      log("not authenticated - or some other connection problem");
      if (e is SSHAuthFailError) {
        log("not authenticated");
      }
    }
  }

  @override
  void initState() {
    connectToSshClient();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raspberry Pi SSH')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_isConnected)
                const Text("NOT CONNECTED WITH THE REMOTE SERVER :("),
              if (_isConnected) ...[
                TextField(
                  controller: _commandController,
                  decoration: const InputDecoration(
                      labelText: 'Enter Command', hintText: 'e.g., ls, df -h'),
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  onPressed: _executeCommand,
                  child: const Text('Execute Command'),
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _outputText,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
