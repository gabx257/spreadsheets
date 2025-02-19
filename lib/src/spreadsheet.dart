import 'cell.dart';
import 'column.dart';
import 'row.dart';

/// sempre deve ser inicializado com pelo menos 2 linhas, uma de headers pelo menos uma de valores
class Sheet {
  int keyColumn;
  int headerPosition;
  late List<Column> _cols;
  late List<Row> _rows;

  List<Column> get cols => _cols;
  List<Row> get rows => _rows;
  List<String> get header => _cols.map((e) => e.header).toList();

  set cols(List<Column> cols) {
    _cols = cols;
    _rows = _fromColsToRows(cols);
  }

  set rows(List<Row> rows) {
    _rows = rows;
    _cols = _fromRowsToCols(rows);
  }

  int get length => rows.length;

  int get lastRow => length + 2;

  /// retorna a coluna com o colIndex correspondente
  Column getCol(Comparable keyorIndex) => _cols.firstWhere((element) =>
      element.header == keyorIndex || element.colIndex == keyorIndex);

  /// retorna a linha com o rowIndex correspondente
  Row getRow(int index) => _rows.firstWhere((row) => row.rowIndex == index);

  Cell getCell(int row, int col) => _rows[row][col];

  Sheet(
      {this.keyColumn = 0,
      required List<List<dynamic>> data,
      this.headerPosition = 0}) {
    if (data.isEmpty) {
      _rows = [];
      _cols = [];
      return;
    }

    _rows = _toRows(data);
    _cols = _fromRowsToCols(_rows);
  }

  Sheet._empty(this.keyColumn, this.headerPosition)
      : _cols = [],
        _rows = [];

  Sheet._copy(this._cols, this._rows, this.headerPosition, this.keyColumn);

  Sheet.fromMap(Map<String, List<Comparable>> data,
      {this.keyColumn = 0, this.headerPosition = 0}) {
    _cols = data.entries.map((e) => Column.fromMap({e.key: e.value})).toList();
    _rows = _fromColsToRows(_cols);
  }

  List<Column> _fromRowsToCols(List<Row> rows) {
    List<Column> cols = [];
    if (rows.isEmpty) return cols;
    for (var i = 0; i < rows[headerPosition].cells.length; i++) {
      cols.add(Column(rows[headerPosition].keys.elementAt(i), [], i));
      for (var j = 0; j < rows.length; j++) {
        cols[i].add(_rows[j].values.elementAt(i));
      }
    }
    return cols;
  }

  List<Row> _fromColsToRows(List<Column> cols) {
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

  // ignore: unused_element
  List<Column> _toCols(List<List<dynamic>> data) {
    List<Column> cols = [];
    for (var i = 0; i < data[headerPosition].length; i++) {
      cols.add(Column(data[headerPosition][i], [], i));
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
        try {
          rows[i].add(header[j], data[i][j]);
        } on RangeError {
          rows[i].add(header[j], '');
        }
      }
    }
    return rows;
  }

  /// pode usar esse metodo para fixar o tipo de valor das celulas
  ///
  /// só pode ser usado caso seja garantido que todas as celulas da planilha são do mesmo tipo
  ///
  /// retorna a planilha com o tipo de valor das celulas definido
  ///
  /// caso alguma celula não seja do tipo especificado, retorna um erro
  Sheet implyType<T extends Comparable<T>>() {
    for (var col in cols) {
      for (var cell in col) {
        cell.value = cell.value as T;
      }
    }
    return this;
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
    cols.add(Column(header, [], cols.length));
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
      value.addAll(List<String>.filled(rows.length - value.length, ''));
    }

    Column col = cols.firstWhere(
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
  Iterable<Row> get reversed => _rows.reversed;

  Sheet inverse() {
    _rows = _rows.reversed.toList();
    _cols = _fromRowsToCols(_rows);
    return this;
  }

  void sortBy(String by) => _rows.sort((a, b) => a[by].compareTo(b[by]));

  /// filtra a planilha, mantendo apenas as linhas que contem o valor passado na coluna especificada.
  ///
  /// [by] pode ser [int] ou [String].
  Sheet filterFrom(Comparable by, Comparable value) {
    Sheet newSheet = Sheet(data: [], headerPosition: headerPosition);
    int index = _rows.firstWhere((row) => row[by].value == value).rowIndex;
    newSheet.rows = _rows.sublist(index);
    return newSheet;
  }

  /// similar ao [filterFrom], mas ao invez de um valor recebe uma funcao bool para filtrar
  ///.
  /// [T] pode ser [Row], [Column] ou [Cell] e é o tipo do elemento que será filtrado
  ///
  /// se [T] não for especificado, a funcao assume que [T] é [Row]
  ///
  /// retorna uma nova planilha com as linhas filtradas
  ///
  /// returns this if no element is found
  Sheet filterFromCondition<T extends Comparable<T>>(
      bool Function(T e) condition,
      [Comparable? by]) {
    Sheet newSheet = Sheet._empty(keyColumn, headerPosition);
    if (T == Column) {
      Column col;
      try {
        col = _cols.firstWhere(condition as bool Function(Column));
      } catch (e) {
        return this;
      }
      int index = col.colIndex;
      newSheet.cols = _cols.sublist(index);
    } else if (T == Cell) {
      Cell cell;
      try {
        cell = _rows
            .expand((row) => row.cells.values)
            .firstWhere(condition as bool Function(Cell));
      } catch (_) {
        return this;
      }
      int index = cell.colIndex;
      newSheet.cols = _cols.sublist(index);
    } else {
      Row row = _rows.firstWhere(condition as bool Function(Row),
          orElse: () => Row({}, -1));
      if (row.rowIndex == -1) return newSheet;
      newSheet.rows = _rows.sublist(row.rowIndex);
    }
    return newSheet;
  }

  /// filtra a planilha por uma coluna e um valor, e retorna apenas linhas com esse valor
  ///
  /// [by] pode ser [int] ou [String].
  ///
  /// retorna uma nova planilha com as linhas filtradas
  Sheet filterOnly(Comparable by, Comparable value) {
    Sheet newSheet = Sheet._empty(keyColumn, headerPosition);
    newSheet.rows = _rows.where((row) => row[by].value == value).toList();
    return newSheet;
  }

  /// filtra a planilha de acordo com uma condição
  ///
  /// remove a primeira linha que satisfaz a condição
  ///
  /// [T] pode ser [Row], [Column] ou [Cell] e é o tipo do elemento que será removido
  ///
  /// [condition] é uma função que recebe um [SheetSubElement] e retorna um [bool]
  ///
  /// caso o tipo [T] não seja especificado, a função assume que [T] é [Row]
  ///
  /// remover uma celula passa o valor da celula para uma [String] vazia, para manter as dimensões da planilha
  void removeFromConditionSingle<T extends Comparable<T>>(
      bool Function(T e) condition) {
    if (T == Column) {
      Column col = _cols.firstWhere(condition as bool Function(Column));
      var i = _cols.indexOf(col);

      _cols.removeWhere((element) => element.colIndex == col.colIndex);

      for (var row in _rows) {
        row.removeWhere((key, value) => value.colIndex == col.colIndex);
      }

      for (Column element in _cols.skip(i)) {
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

  /// filtra a planilha de acordo com uma condição
  ///
  /// remove todas as linhas que atendem a condição
  ///
  /// [T] pode ser [Row], [Column] ou [Cell] e é o tipo do elemento que será removido
  ///
  /// [condition] é uma função que recebe um [SheetSubElement] e retorna um [bool]
  ///
  /// caso o tipo [T] não seja especificado, a função assume que [T] é [Row]
  ///
  /// remover uma celula passa o valor da celula para uma [String] vazia, para manter as dimensões da planilha
  void removeFromCondition<T extends Comparable<T>>(
      bool Function(T e) condition) {
    if (T == Column) {
      for (var col in _cols.where(condition as bool Function(Column))) {
        var i = _cols.indexOf(col);
        _cols.removeWhere((element) => element.colIndex == col.colIndex);

        for (var row in _rows) {
          row.removeWhere((key, value) => value.colIndex == col.colIndex);
        }

        for (Column element in _cols.skip(i)) {
          element.colIndex -= 1;
        }
      }
    } else if (T == Cell) {
      Iterable<Cell> cellsToRemove = _rows
          .expand((row) => row.cells.values)
          .where(condition as bool Function(Cell));

      for (var cell in cellsToRemove) {
        updateCell(cell.rowIndex, cell.colIndex, '');
      }
    } else {
      var count = 0;
      _rows.removeWhere(((e) {
        if (condition(e as T)) {
          count++;
          return true;
        }
        return false;
      }));
      for (var element in _rows) {
        element.rowIndex -= count;
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
  Row? searchFor(Comparable value, [Comparable? by]) {
    for (var row in _rows) {
      if (by == null) {
        if (row.contains(value)) return row;
      }
      if (row[by].value == value) return row;
    }
    return null;
  }

  /// retorna uma copia da planilha
  Sheet get copy => Sheet._copy(
      _cols.map((e) => Column(e.header, e.cells, e.colIndex)).toList(),
      _rows.map((e) => Row(e.cells, e.rowIndex)).toList(),
      headerPosition,
      keyColumn);

  @override
  String toString() {
    return '_cols: $_cols,\n_rows: $_rows';
  }
}
