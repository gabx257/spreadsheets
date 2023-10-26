import 'base_elements.dart';
import 'cell.dart';
import 'col.dart';
import 'row.dart';

/// to-do:
/// fazer testes para os novos metodos
/// implementar o modulo nos projetos

/// sempre deve ser inicializado com pelo menos 2 linhas, os headers e a com os valores
class Sheet2 {
  int keyColumn;
  int headerPosition;
  late List<Col> _cols;
  late List<Row> _rows;

  List<Col> get cols => _cols;
  List<Row> get rows => _rows;

  set cols(List<Col> cols) {
    _cols = cols;
    _rows = _fromColsToRows(cols);
  }

  set rows(List<Row> rows) {
    _rows = rows;
    _cols = _fromRowsToCols(rows);
  }

  /// retorna a coluna com o colIndex correspondente
  Col getCol(Comparable keyorIndex) => _cols.firstWhere((element) =>
      element.header == keyorIndex || element.colIndex == keyorIndex);

  /// retorna a linha com o rowIndex correspondente
  Row getRow(int index) => _rows.firstWhere((row) => row.rowIndex == index);

  Cell getCell(int row, int col) => _rows[row][col];

  Sheet2(
      {this.keyColumn = 0,
      required List<List<dynamic>> data,
      this.headerPosition = 0}) {
    _rows = _toRows(data);
    _cols = _fromRowsToCols(_rows);
  }

  Sheet2._copy(this._cols, this._rows, this.headerPosition, this.keyColumn);

  Sheet2.fromMap(Map<String, List<Comparable>> data,
      {this.keyColumn = 0, this.headerPosition = 0}) {
    _cols = data.entries.map((e) => Col.fromMap({e.key: e.value})).toList();
    _rows = _fromColsToRows(_cols);
  }

  List<Col> _fromRowsToCols(List<Row> rows) {
    List<Col> cols = [];
    if (rows.isEmpty) return cols;
    for (var i = 0; i < rows[headerPosition].cells.length; i++) {
      cols.add(Col(rows[headerPosition].keys.elementAt(i), [], i));
      for (var j = 0; j < rows.length; j++) {
        cols[i].add(_rows[j].values.elementAt(i));
      }
    }
    return cols;
  }

  List<Row> _fromColsToRows(List<Col> cols) {
    List<Row> rows = [];
    List header = cols.removeAt(headerPosition).cells;
    for (var i = 0; i < cols.length; i++) {
      rows.add(Row({}, i));
      for (var j = 0; j < header.length; j++) {
        rows[i].add(header[j].value as String, cols[i].cells[j]);
      }
    }
    return rows;
  }

  List<Col> _toCols(List<List<dynamic>> data) {
    List<Col> cols = [];
    for (var i = 0; i < data[headerPosition].length; i++) {
      cols.add(Col(data[headerPosition][i], [], i));
      for (var j = 0; j < data.length; j++) {
        //
        if (j == headerPosition) continue;

        cols[i].add(data[j][i]);
      }
    }
    return cols;
  }

  List<Row> _toRows(List<List<dynamic>> data) {
    List<Row> rows = [];
    List header = data.removeAt(headerPosition);
    for (var i = 0; i < data.length; i++) {
      rows.add(Row({}, i));
      for (var j = 0; j < header.length; j++) {
        rows[i].add(header[j], data[i][j]);
      }
    }
    return rows;
  }

  /// adicional uma nova linha no final da planilha
  ///
  /// [values.length] deve ser igual ou menor que o numero de colunas da planilha
  ///
  /// caso [values.length] seja menor que o numero de colunas, as celulas vazias serão preenchidas com [String] vazia
  void addRow({List<dynamic>? values}) {
    values ??= [];
    assert(values.length <= cols.length);
    while (values.length < cols.length) {
      values.add('');
    }

    Row r = Row.copy(rows.last, rows.length);
    for (var i = 0; i < cols.length; i++) {
      r[i] = values[i];
      cols[i].add(r[i]);
    }
    rows.add(r);
  }

  /// adicional uma nova coluna no final da planilha
  void addCol(String header, {List<Comparable>? values}) {
    values ??= [];
    cols.add(Col(header, [], cols.length));
    while (values.length > rows.length) {
      addRow();
    }

    while (values.length < rows.length) {
      values.add('');
    }

    for (var i = 0; i < rows.length; i++) {
      cols.last.add(values[i]);
      rows[i].add(header, cols.last.last);
    }
  }

  /// remove a linha selecionada
  void removeRow(int index) {
    rows.removeWhere((row) => row.rowIndex == index);
    for (var col in cols) {
      col.removeWhere((cell) => cell.rowIndex == index);
    }
  }

  /// remove a coluna selecionada
  void removeCol(Comparable keyorIndex) {
    cols.removeWhere(
        (col) => col.colIndex == keyorIndex || col.header == keyorIndex);

    for (var row in rows) {
      row.removeWhere(
          (key, value) => key == keyorIndex || value.colIndex == keyorIndex);
    }
  }

  /// atualiza a linha selecionada, é uma forma de editar multiplas celulas de uma vez
  void updateRow(int index, List<Comparable> value) {
    if (value.length != cols.length) {
      value.addAll(List.generate(rows.length - value.length, (index) => ''));
    }

    Row row = rows.firstWhere((row) => row.rowIndex == index);
    for (var cell in row.values) {
      cell.value = value[cell.colIndex];
    }
  }

  /// atualiza a coluna selecionada, é uma forma de editar multiplas celulas de uma vez
  void updateCol(Comparable keyorIndex, List<Comparable> value) {
    if (value.length != rows.length) {
      value.addAll(List.generate(rows.length - value.length, (index) => ''));
    }

    Col col = cols.firstWhere(
        (col) => col.colIndex == keyorIndex || col.header == keyorIndex);

    for (var cell in col) {
      cell.value = value[cell.rowIndex];
    }
  }

  /// atualiza a celula selecionada com novos valores
  void updateCell(int row, int col, Comparable value) {
    rows
        .firstWhere((element) => element.rowIndex == row)
        .firstWhere((element) => element.colIndex == col)
        .value = value;
  }

  /// inverte a ordem das linhas,
  Sheet2 get reversed {
    _rows = rows.reversed.toList();
    for (var col in _cols) {
      col.cells = col.cells.reversed.toList();
    }
    return this;
  }

  void sortBy(String by) => _rows.sort((a, b) => a[by].value!.compareTo(b[by]));

  /// filtra a planilha, mantendo apenas as linhas que contem o valor passado na coluna especificada.
  ///
  /// [by] pode ser [int] ou [String].
  Sheet2 filterFrom(Comparable by, Comparable value) {
    Sheet2 newSheet = Sheet2(data: [], headerPosition: headerPosition);
    int index = _rows.firstWhere((row) => row[by].value == value).rowIndex;
    newSheet.rows = _rows.sublist(index);
    return newSheet;
  }

  /// similar ao [filterFrom], mas ao invez de um valor recebe uma funcao bool para filtrar.
  ///
  /// [T] pode ser [Row], [Col] ou [Cell] e é o tipo do elemento que será filtrado
  ///
  /// se [T] não for especificado, a funcao assume que [T] é [Row]
  ///
  /// retorna uma nova planilha com as linhas filtradas
  Sheet2 filterFromCondition<T extends SheetSubElement>(
      bool Function(T e) condition,
      [Comparable? by]) {
    Sheet2 newSheet = Sheet2(data: [], headerPosition: headerPosition);
    if (T == Col) {
      Col col = _cols.firstWhere(condition as bool Function(Col));
      int index = col.colIndex;
      newSheet.cols = _cols.sublist(index);
      newSheet._fromColsToRows(cols);
    } else if (T == Cell) {
      Cell cell = _rows
          .expand((row) => row.cells.values)
          .firstWhere(condition as bool Function(Cell));
      int index = cell.colIndex;
      newSheet.cols = _cols.sublist(index);
      newSheet._fromColsToRows(cols);
    } else {
      Row row = _rows.firstWhere(condition as bool Function(Row));
      int index = row.rowIndex;
      newSheet.rows = _rows.sublist(index);
      newSheet._fromRowsToCols(rows);
    }
    return newSheet;
  }

  /// filtra a planilha por uma coluna e um valor, e retorna apenas linhas com esse valor
  ///
  /// [by] pode ser [int] ou [String].
  ///
  /// retorna uma nova planilha com as linhas filtradas
  Sheet2 filterOnly(Comparable by, Comparable value) {
    Sheet2 newSheet = Sheet2(data: [], headerPosition: headerPosition);
    newSheet.rows = _rows.where((row) => row[by].value == value).toList();
    return newSheet;
  }

  /// filtra a planilha de acordo com uma condição
  /// [T] pode ser [Row], [Col] ou [Cell] e é o tipo do elemento que será removido
  ///
  /// [condition] é uma função que recebe um [SheetSubElement] e retorna um [bool]
  ///
  /// caso o tipo [T] não seja especificado, a função assume que [T] é [Row]
  ///
  /// remover uma celula passa o valor da celula para uma [String] vazia, para manter as dimensões da planilha
  void removeFromCondition<T extends SheetSubElement<T>>(
      bool Function(T e) condition) {
    if (T == Col) {
      Col col = _cols.firstWhere(condition as bool Function(Col));
      var i = _cols.indexOf(col);

      _cols.removeWhere((element) => element.colIndex == col.colIndex);

      for (var row in _rows) {
        row.removeWhere((key, value) => value.colIndex == col.colIndex);
      }

      for (Col element in _cols.skip(i)) {
        element.colIndex -= 1;
      }

      //
    } else if (T == Cell) {
      //
      Cell cell = _rows
          .expand((row) => row.cells.values)
          .firstWhere(condition as bool Function(Cell));
      updateCell(cell.rowIndex, cell.colIndex, '');
      //
    } else {
      Row row = _rows.firstWhere(condition as bool Function(Row));
      var i = _rows.indexOf(row);

      _rows.removeWhere((element) => element.rowIndex == row.rowIndex);

      for (var col in _cols) {
        col.removeWhere((cell) => cell.rowIndex == row.rowIndex);
      }

      for (var element in _rows.skip(i)) {
        element.rowIndex -= 1;
      }
    }
  }

  /// retorna a primeira linha que contem o valor passado,
  ///
  /// [by] pode ser [int] ou [String].
  ///
  /// caso [by] não seja especificado, a funçao itera sobre todas as celulas da planilha.
  ///
  /// caso [by] seja especificado, a funçao itera apenas sobre as celulas da coluna especificada.
  Row searchFor(Comparable value, [Comparable? by]) {
    if (by == null) {
      return _rows.firstWhere((row) => row.values.contains(value));
    } else {
      return _rows.firstWhere((row) => row[by].value == value);
    }
  }

  /// retorna uma copia da planilha
  Sheet2 get copy => Sheet2._copy(
      _cols.map((e) => Col(e.header, e.cells, e.colIndex)).toList(),
      _rows.map((e) => Row(e.cells, e.rowIndex)).toList(),
      headerPosition,
      keyColumn);

  @override
  String toString() {
    return '_cols: $_cols,\n_rows: $_rows';
  }
}
