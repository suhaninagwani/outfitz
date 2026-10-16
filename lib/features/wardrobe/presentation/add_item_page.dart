import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ornaments.dart';
import '../../../core/widgets/panels.dart';
import '../../../core/services/crop_service.dart';
import 'crop_page.dart';

/// Step 1 of the add flow: where does the photo come from?
class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({super.key});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final file = await _picker.pickImage(
        source: source,
        // Downscale on the way in: a 48 MP original buys us nothing but memory
        // pressure, and the crop step only keeps ~1400px anyway.
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 92,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      // Straighten the photo once, off the UI thread, before anything looks at
      // it. Everything downstream can then assume "upright".
      final upright = await normalisePhoto(bytes);
      if (!mounted) return;

      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => CropPage(source: upright)),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open that photo: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Add a piece'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(34),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: const StepBar(step: 0, labels: ['source', 'crop', 'tags']),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 40),
        children: [
          Text(
            'Photograph one piece\nat a time.',
            style: t.displayMedium,
          ),
          const SizedBox(height: 14),
          Text(
            'Outfitz crops it, reads the colour and proposes the tags. You confirm '
            'before anything lands in your wardrobe.',
            style: AppText.body,
          ),
          const SizedBox(height: 28),

          _SourceOption(
            icon: Icons.photo_library_outlined,
            eyebrow: kIsWeb ? null : 'fastest',
            title: 'Choose from gallery',
            body: kIsWeb
                ? 'Pick a photo you already have on this device.'
                : 'Already have a photo of it? Pick it from your camera roll.',
            onTap: _busy ? null : () => _pick(ImageSource.gallery),
          ),
          // Browsers only expose a live camera on mobile, so the web build skips
          // that route rather than offering a button that cannot work.
          if (!kIsWeb) ...[
            const SizedBox(height: 14),
            _SourceOption(
              icon: Icons.photo_camera_outlined,
              eyebrow: 'fastest',
              title: 'Take a photo',
              body: 'Shoot it flat on a table, or hanging against a plain wall.',
              onTap: _busy ? null : () => _pick(ImageSource.camera),
            ),
          ],

          const SizedBox(height: 30),
          const LabelledRule('for a clean scan'),
          const SizedBox(height: 16),
          const _Tip('01', 'One garment per photo. Nothing else in frame.'),
          const _Tip('02', 'Soft, even light — avoid the hard evening flash.'),
          const _Tip('03', 'A plain wall or a light bedsheet beats a busy floor.'),

          if (_busy) ...[
            const SizedBox(height: 26),
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.6),
                ),
                SizedBox(width: 12),
                MicroLabel('preparing your photo'),
              ],
            ),
          ],

          const SizedBox(height: 30),
          Row(
            children: [
              const Ornament(kind: OrnamentKind.cross, size: 10, stroke: 1.2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Photos stay on this device. Nothing is uploaded yet — the syncing '
                  'and the model come later.',
                  style: AppText.bodyMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.eyebrow,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) => Panel(
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.butterSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: AppColors.ink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    MicroLabel(eyebrow!, color: AppColors.wine, size: 8.5),
                    const SizedBox(height: 4),
                  ],
                  Text(title, style: AppText.sans(15, FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(body, style: AppText.bodyMuted),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Ornament(kind: OrnamentKind.plus, size: 11, stroke: 1.2),
          ],
        ),
      );
}

class _Tip extends StatelessWidget {
  const _Tip(this.number, this.text);

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MicroLabel(number, color: AppColors.wine, spacing: 1.4, size: 9),
            const SizedBox(width: 14),
            Expanded(
              child: Text(text, style: AppText.sans(13, FontWeight.w400, color: AppColors.ink)),
            ),
          ],
        ),
      );
}
