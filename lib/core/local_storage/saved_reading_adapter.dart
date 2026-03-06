/// DreamBrew AI — SavedReading Hive TypeAdapter
///
/// build_runner bağımlılığı eklemeden elle yazılmış TypeAdapter.
/// [SavedReading] nesnelerini Hive ikili formatına dönüştürür
/// ve geri okur.
library;

import 'package:hive/hive.dart';
import 'saved_reading.dart';

/// [SavedReading] için Hive TypeAdapter implementasyonu.
///
/// TypeId: 0 — projedeki ilk ve birincil adapter.
/// Alan sırası:
///   0 → id (String)
///   1 → type (int — SavedReadingType.index)
///   2 → date (DateTime — millisecondsSinceEpoch)
///   3 → title (String)
///   4 → content (String)
///   5 → isFavorite (bool)
class SavedReadingAdapter extends TypeAdapter<SavedReading> {
  @override
  final int typeId = 0;

  @override
  SavedReading read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return SavedReading(
      id: fields[0] as String,
      type: SavedReadingType.values[fields[1] as int],
      date: DateTime.fromMillisecondsSinceEpoch(fields[2] as int),
      title: fields[3] as String,
      content: fields[4] as String,
      isFavorite: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SavedReading obj) {
    writer
      ..writeByte(6) // alan sayısı
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type.index)
      ..writeByte(2)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.isFavorite);
  }
}
