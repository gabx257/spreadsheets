import 'package:test/test.dart';
import 'package:spreadsheets/spreadsheets.dart'; // Make sure this import is correct
import 'package:csv/csv.dart';
import 'dart:io';

void main() {
  group('Sheet Class Transformation Tests', () {
    late Sheet sheet;
    setUp(() {
      List<List<Object?>> csv = CsvToListConverter(
        shouldParseNumbers: false,
        fieldDelimiter: ';',
      ).convert(File('mockdata/fatura.csv').readAsStringSync());
      csv.removeWhere((element) => element[0] == '');
      List<List<dynamic>> l = csv.sublist(3, csv.length - 8);
      sheet = Sheet(data: l);
    });
   test('fromRowsToCols should correctly transpose rows to columns', () {
      
      
      expect(sheet.cols.length, equals(sheet.rows[0].length));
      expect(sheet.cols[0].length, equals(sheet.rows.length));
    });
    test('FromColsToRows should correctly transpose columns to rows', () {
      List<Column> cols = sheet.cols;
      cols.removeLast();
      sheet.cols = cols; 
      expect(sheet.rows.length, equals(sheet.cols[0].length));
      expect(sheet.rows[0].length, equals(sheet.cols.length));
    });
    test('addRow should correctly add a new row', () {
      // Número inicial de linhas na planilha
      int initialRowCount = sheet.rows.length;

      // Valores para adicionar na nova linha
      List<String> newRowValues = ['Valor1', 'Valor2', 'Valor3'];
      
      // Adiciona uma nova linha com os valores fornecidos
      sheet.addRow(values: newRowValues);
      // Verifica se o número de linhas aumentou em um
      expect(sheet.rows.length, equals(initialRowCount + 1));

      // Verifica se a última linha contém os valores corretos
      
      Row lastRow = sheet.rows.last;
      for (int i = 0; i < newRowValues.length; i++) {
        expect(lastRow[i].value, equals(newRowValues[i]));
      }

      // Se a quantidade de valores fornecidos for menor que o número de colunas,
      // verifica se as células restantes foram preenchidas com strings vazias
      if (newRowValues.length < sheet.cols.length) {
        for (int i = newRowValues.length; i < sheet.cols.length; i++) {
          expect(lastRow[i], equals(''));
        }
      }
    });

    test('addCol should correctly add a new column', () {
      // Número inicial de colunas
      int initialColCount = sheet.cols.length;

      // Cabeçalho e valores para a nova coluna
      String newColHeader = 'NovaColuna';
      List<Comparable> newColValues = ['Valor1', 'Valor2', 'Valor3'];

      // Adiciona uma nova coluna com o cabeçalho e os valores fornecidos
      sheet.addCol(newColHeader, values: newColValues);

      // Verifica se o número de colunas aumentou
      expect(sheet.cols.length, equals(initialColCount + 1));

      // Verifica se a última coluna tem o cabeçalho correto
      expect(sheet.cols.last.header, equals(newColHeader));

      // Verifica se a última coluna contém os valores corretos
      for (int i = 0; i < newColValues.length; i++) {
        expect(sheet.cols.last[i].value, equals(newColValues[i]));
      }

      // Se a quantidade de valores fornecidos for menor que o número de linhas,
      // verifica se as células restantes foram preenchidas com valores padrão
      if (newColValues.length < sheet.rows.length) {
        for (int i = newColValues.length; i < sheet.rows.length; i++) {
          expect(sheet.cols.last[i].value, equals('')); // Ou o valor padrão esperado
        }
      }
    });

    //now make a test for removeCol
    test('removeCol should correctly remove a column', () {
      // Número inicial de colunas
      int initialColCount = sheet.cols.length;

      // Chave ou índice da coluna a ser removida
      var colToRemove = 10;

      // Remove a coluna especificada
      sheet.removeCol(colToRemove);

      // Verifica se o número de colunas diminuiu
      expect(sheet.cols.length, equals(initialColCount - 1));

      // Verifica se a coluna removida não está mais presente
      bool colIsRemoved = !sheet.cols.any(
          (col) => col.header == colToRemove || col.colIndex == colToRemove);
      expect(colIsRemoved, isTrue);

      // Verifica se as linhas foram atualizadas corretamente após a remoção da coluna
      for (var row in sheet.rows) {
        expect(row.containsValue(colToRemove), isFalse);
      }
    });

    test('updateRow should correctly update a specified row with new values', () {
      // Índice da linha a ser atualizada
      int rowIndex = 10; // Defina o índice da linha apropriado

      // Novos valores para atualizar na linha
      List<Comparable> newValues = ['80661839',	'RILIX BRASIL',	'77610938',	'RILIX IND COM SOFTWARE E JOGOS ELET LTDA',	'2024-01-05',	'3220',	'SEDEX CONTRATO AG',	'1',	'1216',	'32,3',	'32,3',	'762915250',	'OV762915250BR',	'0', '0',	'0', '', '00235215 - AGF BOA VISTA',	'13486971', 'LIMEIRA',	'SP',	'24456000',	'SAO GONCALO',	'RJ',	'800', '1600',	'1400', '0',	'12'];

      // Certifique-se de que o número de novos valores corresponde ao número de colunas
      if (newValues.length != sheet.cols.length) {
        throw ArgumentError('Número de valores fornecidos não corresponde ao número de colunas');
      }

      // Atualiza a linha especificada
      sheet.updateRow(rowIndex, newValues);

      // Verifica se os valores da linha foram atualizados corretamente
      Row updatedRow = sheet.getRow(rowIndex);
      for (int i = 0; i < sheet.cols.length; i++) {
        expect(updatedRow[i].value, equals(newValues[i]));
      }

      // Verifica se o tamanho da linha permaneceu o mesmo
      expect(updatedRow.length, equals(sheet.cols.length));
    });

    test('updateCol should correctly update a specified column with new values', () {
      // Chave ou índice da coluna a ser atualizada
      var colToUpdate = 10; // Defina a chave ou índice apropriado

      // Novos valores para atualizar na coluna
      List<Comparable> newColValues = ['NovoValor1', 'NovoValor2', 'NovoValor3'];
      //print(sheet.cols.length);
      // Certifique-se de que o número de novos valores corresponde ao número de linhas
      /*if (newColValues.length != sheet.rows.length) {
        throw ArgumentError('Número de valores fornecidos não corresponde ao número de linhas');
      } */

      // Atualiza a coluna especificada com os novos valores
      sheet.updateCol(colToUpdate, newColValues);

      // Obtém a coluna atualizada
      Column updatedCol = sheet.getCol(colToUpdate);

      // Verifica se os valores da coluna foram atualizados corretamente
      for (int i = 0; i < sheet.rows.length; i++) {
        expect(updatedCol[i].value, equals(newColValues[i]));
      }

      // Verifica se o tamanho da coluna permaneceu o mesmo
      expect(updatedCol.length, equals(sheet.rows.length));
    });

    /*test('updateCell should correctly update a specified cell with a new value', () {
      // Coordenadas da célula a ser atualizada
      int rowIndex = 10; // Defina o índice da linha apropriado
      int colIndex = 10; // Defina o índice da coluna apropriado

      // Novo valor para atualizar na célula
      Comparable newValue = 'NovoValor';

      // Valor original da célula antes da atualização para verificação posterior
      Comparable originalValue = sheet.getCell(rowIndex, colIndex).value;

      // Atualiza a célula especificada com o novo valor
      sheet.updateCell(rowIndex, colIndex, newValue);

      // Verifica se o valor da célula foi atualizado corretamente
      Comparable updatedValue = sheet.getCell(rowIndex, colIndex).value;
      expect(updatedValue, equals(newValue));

      // (Opcional) Verifica se o valor anterior não é mais o mesmo da célula
      expect(updatedValue, isNot(equals(originalValue)));
    });
*/


  });

  
}
