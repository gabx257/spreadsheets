import 'package:spreadsheets/src/spreadsheet.dart';
import 'package:spreadsheets/src/row.dart';
import 'package:test/test.dart';

void main() {
  group('Sheet', () {
    test('reversed returns rows in reverse order', () {
      // Arrange
      List<List<dynamic>> data = [
        ['Header1', 'Header2'],
        ['Value1', 'Value2'],
        ['Value3', 'Value4']
      ];
      Sheet sheet = Sheet(data: data);

      // Act
      Iterable<Row> reversedRows = sheet.reversed;

      print(reversedRows);
      print(sheet);

      // Assert
      expect(reversedRows.elementAt(0).cells.values.map((cell) => cell.value),
          ['Value3', 'Value4']);
      expect(reversedRows.elementAt(1).cells.values.map((cell) => cell.value),
          ['Value1', 'Value2']);
    });
  });
}
