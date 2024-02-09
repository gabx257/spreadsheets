import 'package:googleapis/drive/v2.dart';
import 'package:googleapis/sheets/v4.dart' hide Sheet;
import 'package:googleapis_auth/auth_io.dart';
import 'package:spreadsheets/spreadsheets.dart';

class SheetsAPI {
  final List<String> _scope = [
    SheetsApi.spreadsheetsScope,
    DriveApi.driveScope
  ];
  AutoRefreshingAuthClient? client;
  late SheetsApi _sheetsApi;

  Future<AutoRefreshingAuthClient> initialize(String credentials) async {
    final identifier = ServiceAccountCredentials.fromJson(credentials);
    client = await clientViaServiceAccount(identifier, _scope);
    _sheetsApi = SheetsApi(client!);
    return client!;
  }

  Future<Spreadsheet> createSpreadsheet(String title) async {
    final spreadsheet = Spreadsheet();
    spreadsheet.properties = SpreadsheetProperties();
    spreadsheet.properties!.title = title;
    return await _sheetsApi.spreadsheets.create(spreadsheet);
  }

  Future<dynamic> getSpreadsheet(String id, String range,
      {String? majorDimension,
      int headerPosition = 0,
      int keyColumn = 0,
      bool returnRaw = false}) async {
    var raw = await _sheetsApi.spreadsheets.values
        .get(id, range, majorDimension: majorDimension);

    if (returnRaw) return raw;
    return Sheet(
        data: raw.values ?? [],
        headerPosition: headerPosition,
        keyColumn: keyColumn);
  }

  Future<UpdateValuesResponse> updateSpreadsheet(String id,
      {required List<List<dynamic>> newValues, required String range}) async {
    return _sheetsApi.spreadsheets.values.update(
        ValueRange(values: newValues), id, range,
        valueInputOption: 'USER_ENTERED', includeValuesInResponse: true);
  }

  /// o mapa deve ter o intervalo na notacaoA1 como chave e os valores no formato List<List<dynamic>> (Linha como majorDimension)
  Future<BatchUpdateValuesResponse> batchUpdateSpreadsheet(String id,
      {Map<String, List<String>>? fromMap,
      List<ValueRange>? fromValueRange}) async {
    assert(fromMap != null || fromValueRange != null);
    if (fromMap != null && fromValueRange == null) {
      fromValueRange = fromMap.entries
          .map((e) => ValueRange(range: e.key, values: [e.value]))
          .toList();
    }
    return _sheetsApi.spreadsheets.values.batchUpdate(
        BatchUpdateValuesRequest(
            data: fromValueRange, valueInputOption: 'USER_ENTERED'),
        id);
  }

  Future<AppendValuesResponse> appendSpreadsheet(String id,
      {required List<List<dynamic>> newValues, required String range}) async {
    return _sheetsApi.spreadsheets.values.append(
      ValueRange(values: newValues),
      id,
      range,
      valueInputOption: 'USER_ENTERED',
      includeValuesInResponse: true,
    );
  }

  Future<BatchUpdateValuesResponse> deleteRow(String id, int rowNumber) async {
    final spreadsheet = await _sheetsApi.spreadsheets.get(id);
    final sheet = spreadsheet.sheets![0];
    final columnCount = sheet.properties!.gridProperties!.columnCount ?? 0;

    columnCount == 0 ? throw Exception('Sheet has no columns') : null;

    final range = 'A$rowNumber:${intToA1Notation(columnCount)}$rowNumber';

    return await batchUpdateSpreadsheet(id, fromValueRange: [
      ValueRange(range: range, values: [List.filled(columnCount, '')])
    ]);
  }
}

String intToA1Notation(int number) {
  final int base = 26;
  final int asciiOffset = 65;
  String out = '';

  while (number > 0) {
    int remainder = (number - 1) % base;
    out = '${String.fromCharCode(asciiOffset + remainder)}$out';
    number = (number - 1) ~/ base;
  }

  return out;
}
