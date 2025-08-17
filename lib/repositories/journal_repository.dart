import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' hide Task;
import 'package:moodly/db/tables/journal_table.dart';
import 'package:moodly/db/tables/journal_tag_table.dart';
import 'package:moodly/db/tables/tag_table.dart';
import 'package:moodly/db/tables/task_table.dart';
import 'package:moodly/models/JournalEntry.dart';
import 'package:moodly/models/Task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class JournalRepository {
  static Future<void> upsert({
    required int? id,
    required String? content,
    required DateTime date,
    required String mood,
    required List<String> tags,
    List<String> imagePaths = const [],
    List<String> thumbPaths = const [],
  }) async {
    if (id == null) {
      await JournalTable.add(content, date, mood, imagePaths, thumbPaths);
      final inserted = await JournalTable.getByDate(date);
      if (inserted?.id == null) return;

      final tagIds = <int>[];
      for (final t in tags) {
        tagIds.add(await TagTable.ensure(t));
      }
      await JournalTagTable.replaceTags(inserted!.id!, tagIds);
    } else {
      await JournalTable.update(
        id,
        content,
        date,
        mood,
        imagePaths,
        thumbPaths,
      );

      final tagIds = <int>[];
      for (final t in tags) {
        tagIds.add(await TagTable.ensure(t));
      }
      await JournalTagTable.replaceTags(id, tagIds);
    }
  }

  static Future<List<JournalEntry>> getAll() async {
    final rows = await JournalTable.getAll();
    final result = <JournalEntry>[];

    for (final e in rows) {
      if (e.id == null) continue;
      final tagIds = await JournalTagTable.getTagIdsForJournal(e.id!);
      final tagNames = await TagTable.getTagsForIds(tagIds);
      result.add(
        JournalEntry.fromMap({
          'id': e.id,
          'content': e.content,
          'date': e.date,
          'mood': e.mood,
          'images': e.imagePaths.join(','),
          'thumbs': e.thumbPaths.join(','),
        }, tags: tagNames),
      );
    }
    return result;
  }

  static Future<JournalEntry?> getByDate(DateTime date) async {
    final entry = await JournalTable.getByDate(date);
    if (entry == null || entry.id == null) return null;

    final tagIds = await JournalTagTable.getTagIdsForJournal(entry.id!);
    final tagNames = await TagTable.getTagsForIds(tagIds);

    return JournalEntry.fromMap({
      'id': entry.id,
      'content': entry.content,
      'date': entry.date,
      'mood': entry.mood,
      'images': entry.imagePaths.join(','),
      'thumbs': entry.thumbPaths.join(','),
    }, tags: tagNames);
  }

  static Future<void> _deleteFolderContents(Reference folderRef) async {
    final listResult = await folderRef.listAll();

    for (final item in listResult.items) {
      await item.delete();
    }

    for (final subfolder in listResult.prefixes) {
      await _deleteFolderContents(subfolder);
    }
  }

  static Future<void> backupToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not signed in.");
    final uid = user.uid;

    final storage = FirebaseStorage.instance;

    await _deleteFolderContents(storage.ref('backups/$uid'));

    final backupRef = FirebaseFirestore.instance.collection('backups').doc(uid);
    await backupRef.delete().catchError((_) {});

    final entries = await getAll();
    final journalData = <Map<String, dynamic>>[];

    for (final entry in entries) {
      final entryId = entry.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

      final updatedImages = <String>[];
      for (final imgPath in entry.imagePaths) {
        if (imgPath.isNotEmpty && File(imgPath).existsSync()) {
          final ext = path.extension(imgPath);
          final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_${path.basenameWithoutExtension(imgPath)}$ext';
          await storage
              .ref('backups/$uid/images/$entryId/$uniqueName')
              .putFile(File(imgPath));
          updatedImages.add(uniqueName);
        }
      }

      final updatedThumbs = <String>[];
      for (final thumbPath in entry.thumbPaths) {
        if (thumbPath.isNotEmpty && File(thumbPath).existsSync()) {
          final ext = path.extension(thumbPath);
          final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_${path.basenameWithoutExtension(thumbPath)}$ext';
          await storage
              .ref('backups/$uid/thumbs/$entryId/$uniqueName')
              .putFile(File(thumbPath));
          updatedThumbs.add(uniqueName);
        }
      }

      journalData.add(JournalEntry(
        id: entry.id,
        content: entry.content,
        date: entry.date,
        mood: entry.mood,
        tags: entry.tags,
        imagePaths: updatedImages,
        thumbPaths: updatedThumbs,
      ).toBackupMap());
    }

    final todos = await TaskTable.getAll();
    final todoData = todos.map((t) => t.toBackupMap()).toList();

    await backupRef.set({
      'journals': journalData,
      'tasks': todoData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> restoreFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not signed in.");
    final uid = user.uid;
    final storage = FirebaseStorage.instance;

    final appDir = await getApplicationDocumentsDirectory();
    for (var file in Directory(appDir.path).listSync()) {
      if (file is File) file.deleteSync();
    }

    final docSnap = await FirebaseFirestore.instance.collection('backups').doc(uid).get();
    if (!docSnap.exists) return;
    final data = docSnap.data()!;

    await JournalTable.clearAll();
    await JournalTagTable.clearAll();
    if (data['journals'] != null) {
      for (final j in List<Map<String, dynamic>>.from(data['journals'])) {
        final entry = JournalEntry.fromBackupMap(j);

        final localImages = <String>[];
        for (final filename in entry.imagePaths) {
          final ref = storage.ref('backups/$uid/images/${entry.id}/$filename');
          final localFile = File('${appDir.path}/$filename');
          await ref.writeToFile(localFile);
          localImages.add(localFile.path);
        }

        final localThumbs = <String>[];
        for (final filename in entry.thumbPaths) {
          final ref = storage.ref('backups/$uid/thumbs/${entry.id}/$filename');
          final localFile = File('${appDir.path}/$filename');
          await ref.writeToFile(localFile);
          localThumbs.add(localFile.path);
        }

        await JournalTable.addISO(
          entry.content,
          entry.date,
          entry.mood,
          localImages,
          localThumbs,
        );

        final inserted = await JournalTable.getLastInserted();
        if (inserted?.id != null) {
          final tagIds = <int>[];
          for (final t in entry.tags) {
            tagIds.add(await TagTable.ensure(t));
          }
          await JournalTagTable.replaceTags(inserted!.id!, tagIds);
        }
      }
    }

    await TaskTable.clearAll();
    if (data['tasks'] != null) {
      for (final t in List<Map<String, dynamic>>.from(data['tasks'])) {
        final task = Task.fromBackupMap(t);
        await TaskTable.addISO(task.title, task.date, task.status);
      }
    }
  }
}
