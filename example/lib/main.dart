import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:refer_me/refer_me.dart';

// Global referral client instance
// Use the workaround version to avoid install_referrer package issues
late final ReferralClient referral;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the referral client (using workaround to avoid package issues)
  referral = ReferralClient(
    key: 'your_key',
  );

  // Start listening for in-app deep links (Universal/App Links)
  referral.startLinkListener();

  // Try confirming via Android Install Referrer (post-install case)
  // Wrap in try-catch to handle potential package issues
  try {
    await referral.confirmInstallIfPossible();
  } catch (e) {
    print('Warning: Install referrer check failed: $e');
    // Continue with app startup even if this fails
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Referral Client Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ReferralExampleScreen(),
    );
  }
}

class ReferralExampleScreen extends StatefulWidget {
  const ReferralExampleScreen({super.key});

  @override
  State<ReferralExampleScreen> createState() => _ReferralExampleScreenState();
}

class _ReferralExampleScreenState extends State<ReferralExampleScreen> {
  String? _generatedLink;
  String? _lastConfirmation;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Referral Client Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User ID Input
            TextField(
              decoration: const InputDecoration(
                labelText: 'Your User ID/Code',
                hintText: 'Enter your user ID (e.g., USER123)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Store the user ID for later use
               setState(() {
                 _userId = value;
               });
              },
            ),
            const SizedBox(height: 20),

            // Generate Referral Link Button
            ElevatedButton.icon(
              onPressed: _userId?.isNotEmpty == true ? _generateReferralLink : null,
              icon: _isLoading ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ) : const Icon(Icons.link),
              label: Text(_isLoading ? 'Generating...' : 'Generate Referral Link'),
            ),
            const SizedBox(height: 20),

            // Generated Link Display
            if (_generatedLink != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generated Referral Link:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _generatedLink!,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _copyToClipboard(_generatedLink!),
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _shareLink(_generatedLink!),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Manual Confirmation Section
            const Text(
              'Manual Confirmation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Token to Confirm',
                      hintText: 'Enter referral token',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _tokenToConfirm = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _tokenToConfirm?.isNotEmpty == true ? _confirmInstall : null,
                  child: const Text('Confirm'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Last Confirmation Result
            if (_lastConfirmation != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Confirmation Result:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_lastConfirmation!),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Generate referral links for your users'),
                  Text('• Android: Uses Install Referrer for attribution'),
                  Text('• iOS: Uses Universal Links for attribution'),
                  Text('• Automatic confirmation on app launch'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _userId;
  String? _tokenToConfirm;

  Future<void> _generateReferralLink() async {
    if (_userId == null || _userId!.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final shortLink = await referral.createShortLink(referrerId: _userId!);
      
      setState(() {
        _generatedLink = shortLink;
        _isLoading = false;
      });

      if (shortLink != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Referral link generated: $shortLink'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate referral link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmInstall() async {
    if (_tokenToConfirm == null || _tokenToConfirm!.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await referral.confirmInstall(token: _tokenToConfirm!);
      
      setState(() {
        _lastConfirmation = result != null 
            ? 'Success! Referral confirmed: ${result.toString()}'
            : 'Failed to confirm referral';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result != null ? 'Referral confirmed!' : 'Failed to confirm referral'),
          backgroundColor: result != null ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _lastConfirmation = 'Error: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _shareLink(String link) {
    // In a real app, you'd implement sharing functionality
    // For now, just copy to clipboard
    Clipboard.setData(ClipboardData(text: 'Check out this app! $link'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard for sharing')),
    );
  }

  @override
  void dispose() {
    // Stop the link listener when the app is disposed
    referral.stopLinkListener();
    super.dispose();
  }
}
