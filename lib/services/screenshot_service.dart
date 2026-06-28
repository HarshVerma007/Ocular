import 'package:photo_manager/photo_manager.dart';

/// Service for accessing device screenshots via photo_manager.
class ScreenshotService {
  ScreenshotService._();
  static final ScreenshotService instance = ScreenshotService._();

  bool _hasPermission = false;

  /// Request gallery/photo access permission.
  Future<bool> requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    _hasPermission = ps.isAuth || ps.hasAccess || ps == PermissionState.limited || ps == PermissionState.authorized;
    
    if (!_hasPermission && ps != PermissionState.notDetermined) {
      // Access was denied or restricted. Redirect to app settings.
      await PhotoManager.openSetting();
    }
    return _hasPermission;
  }

  /// Check current permission status without prompting.
  Future<bool> checkPermission() async {
    final PermissionState ps = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    _hasPermission = ps.isAuth || ps.hasAccess || ps == PermissionState.limited || ps == PermissionState.authorized;
    return _hasPermission;
  }

  /// Check if permission is already granted.
  bool get hasPermission => _hasPermission;

  /// Fetch the most recent [count] screenshots from the device.
  /// Strictly queries the "Screenshots" album or filters by filename.
  Future<List<AssetEntity>> getRecentScreenshots({int count = 20}) async {
    if (!_hasPermission) {
      final granted = await requestPermission();
      if (!granted) return [];
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    AssetPathEntity? screenshotAlbum;
    for (final album in albums) {
      if (album.name.toLowerCase().contains('screenshot')) {
        screenshotAlbum = album;
        break;
      }
    }

    if (screenshotAlbum != null) {
      return await screenshotAlbum.getAssetListPaged(
        page: 0,
        size: count,
      );
    }

    // Fallback: If no explicit Screenshots album is found, query "Recent"
    // but strictly filter items containing "screenshot" in their title.
    final fallbackAlbum = albums.isNotEmpty ? albums.first : null;
    if (fallbackAlbum == null) return [];

    final List<AssetEntity> rawAssets = await fallbackAlbum.getAssetListPaged(
      page: 0,
      size: count * 5, // fetch more to filter down
    );

    return rawAssets.where((asset) {
      final title = asset.title?.toLowerCase() ?? '';
      return title.contains('screenshot');
    }).take(count).toList();
  }

  /// Fetch screenshots within a date range.
  Future<List<AssetEntity>> getScreenshotsByDateRange({
    required DateTime start,
    required DateTime end,
    int count = 50,
  }) async {
    if (!_hasPermission) {
      final granted = await requestPermission();
      if (!granted) return [];
    }

    final filterOption = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      createTimeCond: DateTimeCond(min: start, max: end),
      orders: [
        const OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
    );

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filterOption,
    );

    if (albums.isEmpty) return [];

    AssetPathEntity? screenshotAlbum;
    for (final album in albums) {
      if (album.name.toLowerCase().contains('screenshot')) {
        screenshotAlbum = album;
        break;
      }
    }

    if (screenshotAlbum != null) {
      return await screenshotAlbum.getAssetListPaged(
        page: 0,
        size: count,
      );
    }

    // Fallback: Filter by title containing "screenshot"
    final fallbackAlbum = albums.first;
    final List<AssetEntity> rawAssets = await fallbackAlbum.getAssetListPaged(
      page: 0,
      size: count * 5,
    );

    return rawAssets.where((asset) {
      final title = asset.title?.toLowerCase() ?? '';
      return title.contains('screenshot');
    }).take(count).toList();
  }
}
