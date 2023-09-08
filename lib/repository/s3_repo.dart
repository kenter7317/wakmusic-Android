import 'dart:io';
import 'dart:math';

@Deprecated('suggest :: s3 -> mailto')
class S3Repository {
  static bool _error = false;
  bool get hasError => _error;

  S3Repository();

  /// configure amplify storage and returns status
  ///
  /// if returns `true`, successfully initialized
  ///
  /// if returns `false`, failed initializing with error
  Future<bool> configure() async {
    try {
      // final auth = AmplifyAuthCognito();
      // final storage = AmplifyStorageS3();
      // await Amplify.addPlugins([auth, storage]);

      // await Amplify.configure(amplifyconfig);
    } catch (e) {
      _error = true;
      print(e);
    }

    return !_error;
  }

  Future<String> uploadStorage(File file) async {
    throw 0;
    // final uploaded = await Amplify.Storage.uploadFile(
    //   localFile: AWSFile.fromStream(file.openRead(), size: file.lengthSync()),
    //   key: '${_randString(5)}_${DateFormat('yyyyMMddhhmmss').format(_now)}.jpg',
    //   onProgress: (progress) {
    //     // print('Uploading | ${progress.fractionCompleted * 100}%');
    //   },
    // ).result;
    // final fileName = await getUrl(uploaded.uploadedItem.key);
    // print('Uploaded from | ${file.path} =>\nUploaded to   | $fileName');
    // return fileName;
  }

  Future<String> getUrl(String fileName) async {
    throw 0;
    // final result = await Amplify.Storage.getUrl(key: fileName).result;
    // return '${result.url}'.split('?').first;
  }
}

DateTime get _now => DateTime.now();
const _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
String _randString(int length) {
  var rand = Random().nextInt;
  return List.generate(length, (_) => _chars[rand(_chars.length)]).join();
}
