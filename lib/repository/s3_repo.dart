import 'dart:math';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:wakmusic/amplifyconfiguration.dart';

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
      final storage = AmplifyStorageS3();
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugins([storage, auth]);

      // await Amplify.configure(amplifyconfig);
    } catch (e) {
      _error = true;
      print(e);
    }

    return !_error;
  }

  Future<String> uploadStorage(PlatformFile file) async {
    final uploaded = await Amplify.Storage.uploadFile(
      localFile: AWSFile.fromStream(file.readStream!, size: file.size),
      key: '${_randString(5)}_${DateFormat('yyyyMMddhhmmss').format(_now)}',
      onProgress: (progress) {
        print('Uploading | ${file.name} :: ${progress.fractionCompleted}');
      },
    ).result;
    final fileName = uploaded.uploadedItem.key;
    print('Uploaded  | ${file.name} => $fileName');
    return fileName;
  }
}

DateTime get _now => DateTime.now();
const _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
String _randString(int length) {
  var rand = Random().nextInt;
  return List.generate(length, (_) => _chars[rand(_chars.length)]).join();
}
