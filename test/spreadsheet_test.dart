import 'package:spreadsheets/src/spreadsheet.dart';
import 'package:spreadsheets/src/column.dart';
import 'package:spreadsheets/src/row.dart';
import 'package:spreadsheets/src/cell.dart';
import 'package:test/test.dart';

void main() {
  group('Sheet Tests', () {
    late Sheet sheet;

    setUp(() {
      sheet = Sheet(
        data: [
          ['Header1', 'Header2'],
          ['Value1', 'Value2'],
          ['Value3', 'Value4']
        ],
      );
    });

    test('Initialization', () {
      expect(sheet.cols.length, 2);
      expect(sheet.rows.length, 2);
      expect(sheet.header, ['Header1', 'Header2']);
    });

    test('Get Column', () {
      Column col = sheet.getCol('Header1');
      expect(col.header, 'Header1');
      expect(col.cells.length, 2);
    });

    test('Get Row', () {
      Row row = sheet.getRow(0);
      expect(row.rowIndex, 0);
      expect(row.cells.length, 2);
    });

    test('Get Cell', () {
      Cell cell = sheet.getCell(0, 0);
      expect(cell.value, 'Value1');
    });

    test('Add Row', () {
      sheet.addRow(values: ['Value5', 'Value6']);
      expect(sheet.rows.length, 3);
      expect(sheet.getCell(2, 0).value, 'Value5');
    });

    test('Add Column', () {
      sheet.addCol('Header3', values: ['Value7', 'Value8']);
      expect(sheet.cols.length, 3);
      expect(sheet.getCell(0, 2).value, 'Value7');
    });

    test('Remove Row', () {
      sheet.removeRow(0);
      expect(sheet.rows.length, 1);
      expect(sheet.getCell(0, 0).value, 'Value3');
    });

    test('Remove Column', () {
      sheet.removeCol('Header1');
      expect(sheet.cols.length, 1);
      expect(sheet.getCell(0, 0).value, 'Value2');
    });

    test('Update Row', () {
      sheet.updateRow(0, ['NewValue1', 'NewValue2']);
      expect(sheet.getCell(0, 0).value, 'NewValue1');
    });

    test('Update Column', () {
      sheet.updateCol('Header1', ['NewValue1', 'NewValue3']);
      expect(sheet.getCell(0, 0).value, 'NewValue1');
    });

    test('Update Cell', () {
      sheet.updateCell(0, 0, 'UpdatedValue');
      expect(sheet.getCell(0, 0).value, 'UpdatedValue');
    });

    test('Reverse Sheet', () {
      print(sheet);
      Sheet reversedSheet = sheet.reversed;
      expect(reversedSheet.getCell(0, 0).value, 'Value3');
      print(reversedSheet);
    });

    test('Filter From', () {
      Sheet filteredSheet = sheet.filterFrom('Header1', 'Value3');
      expect(filteredSheet.rows.length, 1);
      expect(filteredSheet.getCell(0, 0).value, 'Value3');
    });

    test('Filter Only', () {
      Sheet filteredSheet = sheet.filterOnly('Header1', 'Value1');
      expect(filteredSheet.rows.length, 1);
      expect(filteredSheet.getCell(0, 0).value, 'Value1');
    });

    test('Search For', () {
      Row row = sheet.searchFor('Value1');
      expect(row.rowIndex, 0);
    });

    test('Copy Sheet', () {
      Sheet copiedSheet = sheet.copy;
      expect(copiedSheet.cols.length, sheet.cols.length);
      expect(copiedSheet.rows.length, sheet.rows.length);
    });
  });
}
