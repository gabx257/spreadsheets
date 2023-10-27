import 'dart:collection';

import 'base_elements.dart';
import 'cell.dart';

class Column with ListMixin<Cell> implements SheetSubElement<Column> {
  String header;
  List<Cell> cells;
  int _colIndex;

  @override
  int get length => cells.length;

  @override
  set length(int newLength) {}

  Column(this.header, this.cells, this._colIndex) {
    length = cells.length;
  }

  int get colIndex => _colIndex;

  set colIndex(int value) {
    _colIndex = value;
    for (var cell in cells) {
      cell.colIndex = value;
    }
  }

  Column.copy(Column col, [int? colIndex])
      : header = col.header,
        cells = List<Cell>.from(col.cells),
        _colIndex = colIndex ?? col._colIndex;

  Column.fromMap(Map<String, List<Comparable>> data, [int? colIndex])
      : header = data.keys.first,
        cells = data.values.first
            .map((e) => Cell(data.values.first.indexOf(e), colIndex ?? 0, e))
            .toList(),
        _colIndex = colIndex ?? 0;

  @override
  Cell operator [](int index) =>
      cells.firstWhere((cell) => cell.rowIndex == index);

  @override
  operator []=(int index, dynamic value) =>
      cells[index].value = value; // <<<=== !!!!!!!

  @override
  bool contains(Object? element) => cells.map((e) => e.value).contains(element);

  @override
  void add(dynamic element) => cells
      .add(element is Cell ? element : Cell(cells.length, _colIndex, element));

  @override
  void addAll(Iterable<Comparable> iterable) {
    for (var element in iterable) {
      add(element);
    }
  }

  @override
  void removeWhere(bool Function(Cell) test) => cells.removeWhere(test);

  @override
  String toString() =>
      cells.map((e) => 'v: ${e.value}, i: ${e.colIndex}').toList().toString();

  @override
  int compareTo(other) => _colIndex.compareTo(other._colIndex);
}
