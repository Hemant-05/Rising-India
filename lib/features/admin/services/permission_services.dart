import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionServices {
  static Future<bool> requestNecessaryPermissions() async {
    List<Permission> permissionsToRequest = [];

    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();

      if (sdkInt >= 33) {
        permissionsToRequest = [
          Permission.camera,
          Permission.photos, // for gallery in Android 13+
          Permission.locationWhenInUse,
          Permission.notification, // optional but recommended
        ];
      } else {
        permissionsToRequest = [
          Permission.camera,
          Permission.storage, // for gallery pre-Android 13
          Permission.locationWhenInUse,
        ];
      }
    } else if (Platform.isIOS) {
      permissionsToRequest = [
        Permission.camera,
        Permission.photos,
        Permission.locationWhenInUse,
      ];
    }

    final statuses = await permissionsToRequest.request();

    final allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      final permanentlyDenied = statuses.values.any(
        (status) => status.isPermanentlyDenied,
      );
      if (permanentlyDenied) {
        await openAppSettings();
      }
    }

    return allGranted;
  }

  static Future<int> _getAndroidSdkInt() async {
    try {
      final result = await Permission
          .photos
          .status; // safe way to access something Android 13+ has
      return result.toString().contains("restricted") ? 33 : 32;
    } catch (_) {
      return 32;
    }
  }
}
