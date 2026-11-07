import 'dart:convert';

enum ArtAssetState {
  missing,
  originalReceived,
  exportValidated,
  integrated,
  qaApproved
}

enum ArtVariantType {
  environment,
  portrait,
  characterSheet,
  cardIllustration,
  logo,
  titleTreatment,
  gameplaySprite,
  hudComposite,
  collectionComposite,
  preview,
  unknown,
}

class ArtAssetRecord {
  const ArtAssetRecord({
    required this.key,
    required this.targetPath,
    required this.variantType,
    required this.state,
    required this.approvalStatus,
    this.sourceFile,
    this.sourceSha256,
    this.sourceArchiveSha256,
    this.approvalRowId,
    this.designApprovalRowId,
    this.expectedWidth,
    this.expectedHeight,
    this.drawBounds,
    this.exportSha256,
    this.exportOperation,
  });

  final String key;
  final String targetPath;
  final ArtVariantType variantType;
  final ArtAssetState state;
  final String approvalStatus;
  final String? sourceFile;
  final String? sourceSha256;
  final String? sourceArchiveSha256;
  final String? approvalRowId;
  final String? designApprovalRowId;
  final int? expectedWidth;
  final int? expectedHeight;
  final String? drawBounds;
  final String? exportSha256;
  final String? exportOperation;

  bool get productionReady => state == ArtAssetState.qaApproved;

  factory ArtAssetRecord.fromJson(Map<String, dynamic> json) => ArtAssetRecord(
        key: json['key'] as String,
        targetPath: json['targetPath'] as String,
        variantType: ArtVariantType.values.byName(
          json['variantType'] as String,
        ),
        state: ArtAssetState.values.byName(json['state'] as String),
        approvalStatus: json['approvalStatus'] as String,
        sourceFile: json['sourceFile'] as String?,
        sourceSha256: json['sourceSha256'] as String?,
        sourceArchiveSha256: json['sourceArchiveSha256'] as String?,
        approvalRowId: json['approvalRowId'] as String?,
        designApprovalRowId: json['designApprovalRowId'] as String?,
        expectedWidth: json['expectedWidth'] as int?,
        expectedHeight: json['expectedHeight'] as int?,
        drawBounds: json['drawBounds'] as String?,
        exportSha256: json['exportSha256'] as String?,
        exportOperation: json['exportOperation'] as String?,
      );
}

class ArtManifest {
  const ArtManifest({required this.records});

  final List<ArtAssetRecord> records;

  factory ArtManifest.fromJson(Map<String, dynamic> json) => ArtManifest(
        records: (json['assets'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(ArtAssetRecord.fromJson)
            .toList(growable: false),
      );

  factory ArtManifest.decode(String source) => ArtManifest.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );

  List<ArtAssetRecord> get unavailableRuntimeArt => records
      .where((record) =>
          record.state != ArtAssetState.integrated &&
          record.state != ArtAssetState.qaApproved)
      .toList(growable: false);

  /// Returns invariant violations for registry coverage and release readiness.
  List<String> validate({
    required Map<String, String> registry,
    required Set<String> declaredAssets,
    required Set<String> availableAssets,
  }) {
    final problems = <String>[];
    final keys = records.map((record) => record.key).toList();
    final paths = records.map((record) => record.targetPath).toList();
    if (keys.toSet().length != keys.length) {
      problems.add('Manifest contains duplicate art keys.');
    }
    if (paths.toSet().length != paths.length) {
      problems.add('Manifest contains duplicate target paths.');
    }
    for (final key in registry.keys) {
      if (!keys.contains(key)) {
        problems.add('Manifest is missing registry key $key.');
      }
    }
    for (final record in records) {
      if (!registry.containsKey(record.key)) {
        problems.add('Manifest contains unregistered art key ${record.key}.');
      }
      if (registry[record.key] != record.targetPath) {
        problems.add('Registry path does not match ${record.key}.');
      }
      if (record.productionReady) {
        if (record.approvalStatus != 'verified') {
          problems
              .add('${record.key} is QA approved without verified approval.');
        }
        if (!availableAssets.contains(record.targetPath)) {
          problems.add('${record.key} is QA approved but its file is missing.');
        }
        if (!declaredAssets.contains(record.targetPath)) {
          problems
              .add('${record.key} is QA approved but undeclared in pubspec.');
        }
      }
      if (record.state == ArtAssetState.integrated) {
        if (record.sourceFile == null || record.sourceSha256 == null) {
          problems
              .add('${record.key} is integrated without source traceability.');
        }
        if (record.approvalRowId == null) {
          problems.add('${record.key} is integrated without an audit row.');
        }
        if (record.expectedWidth == null || record.expectedHeight == null) {
          problems
              .add('${record.key} is integrated without validated dimensions.');
        }
        if (!availableAssets.contains(record.targetPath)) {
          problems.add('${record.key} is integrated but its file is missing.');
        }
        if (!declaredAssets.contains(record.targetPath)) {
          problems
              .add('${record.key} is integrated but undeclared in pubspec.');
        }
      }
    }
    return problems;
  }
}
