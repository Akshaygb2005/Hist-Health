class MedicalRecord {
  final String id;
  final String filename;
  final String size;
  final String recordDate;
  final String diagnosis;
  final String bp;
  final String sugar;
  final String symptoms;
  final List<String> meds;
  final String fileUrl;
  final List<int>? rawBytes;

  MedicalRecord({
    required this.id,
    required this.filename,
    required this.size,
    required this.recordDate,
    required this.diagnosis,
    required this.bp,
    required this.sugar,
    required this.symptoms,
    required this.meds,
    required this.fileUrl,
    this.rawBytes,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    List<String> parsedMeds = [];
    if (json['meds'] != null) {
      if (json['meds'] is List) {
        parsedMeds = (json['meds'] as List).map((e) => e.toString()).toList();
      }
    }
    return MedicalRecord(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      size: json['size'] ?? '',
      recordDate: json['record_date'] ?? json['date'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      bp: json['bp'] ?? '',
      sugar: json['sugar'] ?? '',
      symptoms: json['symptoms'] ?? '',
      meds: parsedMeds,
      fileUrl: json['file_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'size': size,
        'record_date': recordDate,
        'diagnosis': diagnosis,
        'bp': bp,
        'sugar': sugar,
        'symptoms': symptoms,
        'meds': meds,
        'file_url': fileUrl,
      };
}
