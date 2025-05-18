// Split a List<T> into sublists of max entries maxEntries. Ie [1, 2, 3, 4] maxEntries = 1: [[1], [2], [3], [4]]
List<List<T>> chunkList<T>({required List<T> list, required int maxEntries}) {
  List<List<T>> bigTemp = [];
  for (int startIndex = 0; startIndex < list.length; startIndex += maxEntries) {
    if (startIndex + maxEntries > list.length) { // If this is true you'll have to add a chunk that isn't the maximum size
      bigTemp.add(list.sublist(startIndex, list.length));
    } else { // add a chunk of size maxEntries
      bigTemp.add(list.sublist(startIndex, startIndex + maxEntries));
    }
  }
  // [0, 1, 2, 3, 4]
  // [0, 1], [2, 3]
  return bigTemp;
}

// For code cleanliness' sake:
extension MapParsing<K, V> on Map<K, V>{
  List<MapEntry<K, V>> toList() {
    final List<MapEntry<K, V>> temp = [];
    forEach((key, value) => temp.add(MapEntry(key, value)));
    return temp;
  }
}

extension ListParsing<K, V> on List<MapEntry<K, V>> {
  Map<K, V> toMap() {
    return Map.fromEntries(this);
  }
}