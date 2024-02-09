import 'spreadsheet.dart';
import 'APIs/gsheets.dart';
import 'package:dotenv/dotenv.dart';
import 'row.dart';

class GoogleSheet extends Sheet {
  int sheetId;
  late String title;
  late List<String> tabs;

  dynamic fetchSpreadsheet(String id) async {
    final sheetsClient = SheetsAPI();
    var sheet = await sheetsClient.getSpreadsheet(id, 'A1', returnRaw: true);
    title = sheet.title;
    tabs = sheet.sheets!.map((e) => e.properties!.title!).toList();
    return sheet.values ?? [];
  }

  GoogleSheet(
    {super.keyColumn = 0,
    required this.sheetId,
    super.headerPosition = 0}
  ) : data = fetchSpreadsheet(this.sheetId), super(data: data);

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
}