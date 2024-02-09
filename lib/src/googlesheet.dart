import 'spreadsheet.dart';
import 'APIs/gsheets.dart';

class GoogleSheet extends Sheet {
  String sheetId;
  String title;
  List<String> tabs;

  GoogleSheet._(
      {super.keyColumn,
      required this.tabs,
      required this.title,
      required super.data,
      required this.sheetId,
      super.headerPosition});

  Future<GoogleSheet> create({
    required SheetsAPI sheetsClient,
    required String sheetId,
    int headerPosition = 0,
    int keyColumn = 0,
  }) async =>
      GoogleSheet._(
          sheetId: sheetId,
          title: await sheetsClient.getTitle(sheetId, 'A1', returnRaw: true),
          tabs: await sheetsClient.getTabs(sheetId, 'A1', returnRaw: true),
          headerPosition: headerPosition,
          keyColumn: keyColumn,
          data: await sheetsClient.getSpreadsheet(sheetId, 'A1',
              returnRaw: true));
}
