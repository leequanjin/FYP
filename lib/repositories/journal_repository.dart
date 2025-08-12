import 'package:flutter/cupertino.dart';
import 'package:moodly/db/tables/journal_table.dart';
import 'package:moodly/db/tables/journal_tag_table.dart';
import 'package:moodly/db/tables/tag_table.dart';
import 'package:moodly/models/JournalEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalRepository {
  /// Create or update a journal entry with tags
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
      // Insert new
      await JournalTable.add(content, date, mood, imagePaths, thumbPaths);
      final inserted = await JournalTable.getByDate(date);
      if (inserted?.id == null) return;

      final tagIds = <int>[];
      for (final t in tags) {
        tagIds.add(await TagTable.ensure(t));
      }
      await JournalTagTable.replaceTags(inserted!.id!, tagIds);
    } else {
      // Update existing
      await JournalTable.update(id, content, date, mood, imagePaths, thumbPaths);

      final tagIds = <int>[];
      for (final t in tags) {
        tagIds.add(await TagTable.ensure(t));
      }
      await JournalTagTable.replaceTags(id, tagIds);
    }

    // Optional: automatically backup to Firestore after every upsert
    try {
      await backupToFirestore();
    } catch (e) {
      debugPrint("Firestore backup failed: $e");
    }
  }

  /// Retrieve all journal entries with their tags
  static Future<List<JournalEntry>> getAll() async {
    final rows = await JournalTable.getAll();
    final result = <JournalEntry>[];

    for (final e in rows) {
      if (e.id == null) continue;
      final tagIds = await JournalTagTable.getTagIdsForJournal(e.id!);
      final tagNames = await TagTable.getTagsForIds(tagIds);
      result.add(
        JournalEntry.fromMap(
          {
            'id': e.id,
            'content': e.content,
            'date': e.date,
            'mood': e.mood,
            'images': e.imagePaths.join(','),
            'thumbs': e.thumbPaths.join(','),
          },
          tags: tagNames,
        ),
      );
    }
    return result;
  }

  /// Retrieve a single journal entry by date
  static Future<JournalEntry?> getByDate(DateTime date) async {
    final entry = await JournalTable.getByDate(date);
    if (entry == null || entry.id == null) return null;

    final tagIds = await JournalTagTable.getTagIdsForJournal(entry.id!);
    final tagNames = await TagTable.getTagsForIds(tagIds);

    return JournalEntry.fromMap(
      {
        'id': entry.id,
        'content': entry.content,
        'date': entry.date,
        'mood': entry.mood,
        'images': entry.imagePaths.join(','),
        'thumbs': entry.thumbPaths.join(','),
      },
      tags: tagNames,
    );
  }

  /// Backup all journal entries to Firestore
  static Future<void> backupToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not signed in.");

    final entries = await getAll();
    final backupRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journal_backup');

    // 1️⃣ Remove all old backups first
    final oldDocs = await backupRef.get();
    for (final doc in oldDocs.docs) {
      await doc.reference.delete();
    }

    if (entries.isEmpty) return;

    // 2️⃣ Write fresh backup
    final batch = FirebaseFirestore.instance.batch();
    for (final entry in entries) {
      final docRef = backupRef.doc(entry.id.toString());
      batch.set(docRef, entry.toBackupMap());
    }
    await batch.commit();
  }

  /// Restore all journal entries from Firestore
  static Future<void> restoreFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not signed in.");

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journal_backup')
        .get();

    if (snapshot.docs.isEmpty) return;

    // Optional: clear local DB before restore
    await JournalTable.clearAll();
    await JournalTagTable.clearAll();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final entry = JournalEntry.fromBackupMap(data);

      // Insert fresh
      await JournalTable.addISO(
        entry.content,
        entry.date,
        entry.mood,
        entry.imagePaths,
        entry.thumbPaths,
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

}
