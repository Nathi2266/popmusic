// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 1;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      id: fields[0] as String,
      title: fields[1] as String,
      artistId: fields[2] as String,
      totalStreams: fields[3] as double,
      weeklyListeners: fields[4] as double,
      lastWeekListeners: fields[5] as double?,
      weeksSinceRelease: fields[6] as int,
      popularityFactor: fields[7] as double,
      viralFactor: fields[8] as double,
      salesPotential: fields[9] as double,
      lastWeekRank: fields[10] as int?,
      currentRank: fields[11] as int?,
      peakRank: fields[12] as int?,
      weeksOnChart: fields[13] as int,
      isNewEntry: fields[14] as bool,
      isViral: fields[15] as bool,
      awards: (fields[16] as List).cast<String>(),
      listenerHistory: (fields[17] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artistId)
      ..writeByte(3)
      ..write(obj.totalStreams)
      ..writeByte(4)
      ..write(obj.weeklyListeners)
      ..writeByte(5)
      ..write(obj.lastWeekListeners)
      ..writeByte(6)
      ..write(obj.weeksSinceRelease)
      ..writeByte(7)
      ..write(obj.popularityFactor)
      ..writeByte(8)
      ..write(obj.viralFactor)
      ..writeByte(9)
      ..write(obj.salesPotential)
      ..writeByte(10)
      ..write(obj.lastWeekRank)
      ..writeByte(11)
      ..write(obj.currentRank)
      ..writeByte(12)
      ..write(obj.peakRank)
      ..writeByte(13)
      ..write(obj.weeksOnChart)
      ..writeByte(14)
      ..write(obj.isNewEntry)
      ..writeByte(15)
      ..write(obj.isViral)
      ..writeByte(16)
      ..write(obj.awards)
      ..writeByte(17)
      ..write(obj.listenerHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
