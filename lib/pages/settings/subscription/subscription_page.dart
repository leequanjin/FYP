import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moodly/pages/settings/auth/auth_app_bar.dart';
import 'package:moodly/utils/user_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isPremium = false;
  DateTime? _premiumExpiry;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    final premiumStatus = await UserService.isPremiumUser();
    final expiry = await UserService.getPremiumExpiry();

    setState(() {
      _isPremium = premiumStatus;
      _premiumExpiry = expiry;
      _loading = false;
    });
  }

  Future<void> _upgradeToPremium() async {
    await UserService.upgradeToPremium();
    final expiry = await UserService.getPremiumExpiry();

    setState(() {
      _isPremium = true;
      _premiumExpiry = expiry;
    });
  }

  Future<void> _cancelSubscription() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'isPremium': false,
        'premiumExpiry': null,
      }, SetOptions(merge: true));

      setState(() {
        _isPremium = false;
        _premiumExpiry = null;
      });
    }
  }

  Widget _buildTierCard({
    required String title,
    required List<String> features,
    bool highlight = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Container(
        decoration: highlight
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondaryContainer,
                    Theme.of(context).colorScheme.tertiaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              )
            : BoxDecoration(borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: highlight
                    ? Theme.of(context).colorScheme.onTertiaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            ...features.map(
              (f) => Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: highlight
                        ? Theme.of(context).colorScheme.onTertiaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 16,
                        color: highlight
                            ? Theme.of(context).colorScheme.onTertiaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AuthAppBar(titleText: 'Subscription'),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTierCard(
                  title: "Free Tier",
                  features: [
                    "Basic themes only",
                    "No chatbot access",
                  ],
                ),
                const SizedBox(height: 8),
                _buildTierCard(
                  title: "Premium Tier",
                  features: [
                    "Premium themes",
                    "Access to chatbot",
                  ],
                  highlight: true,
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: _isPremium ? null : _upgradeToPremium,
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
                  child: Text(
                    _isPremium ? 'Already Premium' : 'Upgrade to Premium',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_isPremium)
                  OutlinedButton(
                    onPressed: _cancelSubscription,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 1,
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(
                      'Cancel Subscription',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.error,
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
