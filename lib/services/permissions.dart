import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readnow/services/scan.dart';

Future<void> handleStoragePermission() async {

    PermissionStatus permissionStatus =
        await Permission.manageExternalStorage.request();
    if (permissionStatus.isGranted) {
      // Permission granted for Android 11+
      var rootDirectory = await ExternalPath.getExternalStorageDirectories();
      await getFiles(rootDirectory.first);
    }
  
}
