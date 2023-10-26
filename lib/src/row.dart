import 'dart:collection';

import 'base_elements.dart';
import 'cell.dart';

class Row with MapMixin<String, Cell> implements SheetSubElement<Row> {
  Map<String, Cell> cells;
  int _rowIndex;

  Row(this.cells, this._rowIndex);

  Row.copy(Row row, [int? rowIndex])
      : cells = Map<String, Cell>.from(row.cells),
        _rowIndex = rowIndex ?? row.rowIndex;

  set rowIndex(int value) {
    _rowIndex = value;
    for (var cell in cells.values) {
      cell.rowIndex = value;
    }
  }

  int get rowIndex => _rowIndex;

  @override
  Iterable<String> get keys => cells.keys;

  @override
  Cell operator [](Object? key) {
    if (cells.containsKey(key)) return cells[key]!;

    if (key is int) {
      return cells.entries.elementAt(key).value;
    } else {
      throw Exception('Key not found');
    }
  }

  @override
  operator []=(Comparable key, Object? value) {
    String trueKey = key is int ? cells.keys.elementAt(key) : key as String;

    cells[trueKey] = Cell(cells[trueKey]!.colIndex, cells[trueKey]!.rowIndex,
        value is Cell ? value.value : value as Comparable);
  }

  Cell get first => this[0];

  Cell get last => this[cells.length - 1];

  void add(String key, dynamic value) {
    if (cells.containsKey(key)) throw Exception('Key already exists');
    cells[key] = value is Cell ? value : Cell(rowIndex, cells.length, value);
  }

  @override
  void addAll(Map<String, Object> other) {
    assert(other is Map<String, Comparable>);
    for (var entry in other.entries) {
      add(entry.key, entry.value as Comparable);
    }
  }

  Row sublist(int start, [int? end]) => Row.copy(this)
    ..removeWhere(
        (key, value) => value.rowIndex > start && value.rowIndex < (end ?? 0));

  @override
  void clear() => cells.clear();

  @override
  Cell? remove(Object? key) => cells.remove(key);

  @override
  int compareTo(other) => rowIndex.compareTo(other.rowIndex);

  @override
  String toString() =>
      cells.values.map((e) => 'v: ${e.value}, i: ${e.rowIndex}').toString();

  Cell firstWhere(bool Function(Cell element) test) =>
      cells.values.firstWhere(test);
}
