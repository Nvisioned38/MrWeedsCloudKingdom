import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/art_manifest.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/art_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('art manifest covers every registered key and packaged source',
      () async {
    final manifest = ArtManifest.decode(
      await rootBundle.loadString('assets/art/manifest.json'),
    );
    final declared = <String>{};
    for (final record in manifest.records.where(
      (record) => record.state == ArtAssetState.integrated,
    )) {
      try {
        await rootBundle.load(record.targetPath);
        declared.add(record.targetPath);
      } catch (_) {
        // The manifest validator below reports an integrated asset that is not
        // actually declared in the Flutter bundle.
      }
    }
    final available = manifest.records
        .where((record) => File(record.targetPath).existsSync())
        .map((record) => record.targetPath)
        .toSet();

    expect(
      manifest.validate(
        registry: ArtRegistry.paths,
        declaredAssets: declared,
        availableAssets: available,
      ),
      isEmpty,
    );
    expect(manifest.records, hasLength(ArtRegistry.paths.length));
    expect(
      manifest.records
          .where((record) => record.state == ArtAssetState.integrated),
      hasLength(11),
    );
    expect(manifest.records.where((record) => record.productionReady), isEmpty);

    final portrait = manifest.records
        .singleWhere((record) => record.key == 'portrait_mr_weed');
    expect(portrait.state, ArtAssetState.integrated);
    expect(portrait.approvalRowId, 'CS-001');
    expect(portrait.designApprovalRowId, 'CH-001');
    expect(portrait.sourceSha256, portrait.exportSha256);
    expect(portrait.expectedWidth, 1254);
    expect(portrait.expectedHeight, 1254);
    final portraitData = await rootBundle.load(portrait.targetPath);
    final codec = await ui.instantiateImageCodec(
      portraitData.buffer.asUint8List(),
    );
    final frame = await codec.getNextFrame();
    expect(frame.image.width, portrait.expectedWidth);
    expect(frame.image.height, portrait.expectedHeight);
    frame.image.dispose();
    codec.dispose();
  });

  test('QA-approved art cannot be absent or missing from pubspec', () {
    const manifest = ArtManifest(records: [
      ArtAssetRecord(
        key: 'test_logo',
        targetPath: 'assets/art/brand/test_logo.png',
        variantType: ArtVariantType.logo,
        state: ArtAssetState.qaApproved,
        approvalStatus: 'verified',
      ),
    ]);

    final issues = manifest.validate(
      registry: const {'test_logo': 'assets/art/brand/test_logo.png'},
      declaredAssets: const {},
      availableAssets: const {},
    );

    expect(
        issues, contains('test_logo is QA approved but its file is missing.'));
    expect(
      issues,
      contains('test_logo is QA approved but undeclared in pubspec.'),
    );
  });
}
