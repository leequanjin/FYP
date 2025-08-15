import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodly/pages/settings/auth/auth_app_bar.dart';
import 'package:moodly/repositories/journal_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  bool _isLoading = false;
  String _statusMessage = '';
  DateTime? _lastBackup;

  @override
  void initState() {
    super.initState();
    _fetchLastBackupTime();
  }

  Future<void> _fetchLastBackupTime() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('backups')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data()?['timestamp'] != null) {
        setState(() {
          _lastBackup = (doc.data()!['timestamp'] as Timestamp).toDate();
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch last backup time: $e");
    }
  }

  Future<void> _backupToFirestore() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await JournalRepository.backupToFirestore();
      await _fetchLastBackupTime();
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

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthAppBar(titleText: 'Backup & Restore'),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.history, color: Theme.of(context).colorScheme.onSurface),
                    title: const Text('Last Backup'),
                    subtitle: Text(
                      _lastBackup != null
                          ? _formatDate(_lastBackup!)
                          : 'No backups yet',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _backupToFirestore,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Backup to Firestore'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _restoreFromFirestore,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Restore from Firestore'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text("Please wait..."),
                ],
                if (_statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _statusMessage.contains('successful')
                            ? Colors.green
                            : Colors.red,
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
}
