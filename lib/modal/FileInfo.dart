class FileInfo {
  String fileName;
  String filePath;
  bool isFolder;
  String fileType;
  int subCount;
  int fileLength;

  FileInfo({this.fileName, this.filePath, this.isFolder, this.fileType, this.subCount, this.fileLength});

  FileInfo.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    filePath = json['filePath'] == null ? "" : json['filePath'];
    isFolder = json['isFolder'] == null ? false : json['isFolder'];
    fileType = json['fileType'] == null ? "" : json['fileType'];
    subCount = json['subCount'] == null ? 0 : json['subCount'];
    fileLength = json['fileLength'] == null ? 0 : json['fileLength'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileName'] = this.fileName;
    data['filePath'] = this.filePath;
    data['isFolder'] = this.isFolder;
    data['fileType'] = this.fileType;
    data['subCount'] = this.subCount;
    data['fileLength'] = this.fileLength;
    return data;
  }
}
// public enum FileType {
//     folderEmpty,
//     folderFull,
//     fileArchive,
//     fileUnknown,
// }
