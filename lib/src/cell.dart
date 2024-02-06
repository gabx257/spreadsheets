import 'base_elements.dart';

class Cell implements SheetSubElement<Cell> {
  Comparable? value;
  int rowIndex;
  int colIndex;

  Cell(this.rowIndex, this.colIndex, [this.value]) {
    value ??= '';
  }

  @override
  String toString() => value.toString();

  @override
  int compareTo(Cell other) => value!.compareTo(other.value);

  bool isValue(Comparable compare) => value == compare;

  bool isRow(int row) => rowIndex == row;

  bool isColumn(int col) => colIndex == col;

  @override
  bool operator ==(Object other) => other is Cell && value == other.value;

  @override
  int get hashCode => value.hashCode;

  bool get isEmpty => value == null || value == '';

  bool get isNotEmpty => !isEmpty;
}
