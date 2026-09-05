import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart' as helper;

void downloadFileFromBytes(List<int> bytes, String filename) {
  helper.downloadFile(bytes, filename);
}

String createBlobUrlFromBytes(List<int> bytes) {
  return helper.createBlobUrl(bytes);
}

void openPdfUrlInNewTab(String url) {
  helper.openUrlInNewTab(url);
}
