import 'package:flutter/material.dart';
import 'package:moodly/repositories/journal_repository.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _backupToFirestore() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await JournalRepository.backupToFirestore();
      setState(() {
        _statusMessage = 'Backup successful!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Backup failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreFromFirestore() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await JournalRepository.restoreFromFirestore();
      setState(() {
        _statusMessage = 'Restore successful!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Restore failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _backupToFirestore,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Backup to Firestore'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _restoreFromFirestore,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Restore from Firestore'),
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('successful')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
