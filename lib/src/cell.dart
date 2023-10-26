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
  int compareTo(Cell other) => value!.compareTo(other);
}
