import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../../data/models/article.dart';
import '../../providers/activity_provider.dart';
import '../../utils/image_cache_manager.dart';
import '../../widgets/app_toast.dart';
import '../../core/theme/app_colors.dart';
import 'bottom_sheet_menu.dart';

/// 封面图管理器
class CoverImageManager {
  final BuildContext context;
  final Article article;
  final ImagePicker imagePicker;
  final ImageCacheManager imageCacheManager;
  final Function(Article, {String? newImagePath}) onArticleUpdated;

  CoverImageManager({
    required this.context,
    required this.article,
    required this.imagePicker,
    required this.imageCacheManager,
    required this.onArticleUpdated,
  });

  /// 显示封面图选项菜单
  Future<void> showOptions() async {
    final result = await showCustomBottomSheet<String>(
      context: context,
      items: [
        BottomSheetMenuItem(
          icon: Icons.photo_library_outlined,
          label: '从相册选择',
          onTap: () => Navigator.pop(context, 'gallery'),
        ),
        BottomSheetMenuItem(
          icon: Icons.link_outlined,
          label: '从 URL 添加',
          onTap: () => Navigator.pop(context, 'url'),
        ),
        if (article.coverImage != null)
          BottomSheetMenuItem(
            icon: Icons.delete_outline,
            label: '删除背景',
            onTap: () => Navigator.pop(context, 'delete'),
            isDestructive: true,
          ),
      ],
    );

    if (result == null) return;

    switch (result) {
      case 'gallery':
        await _pickImageFromGallery();
        break;
      case 'url':
        await _inputImageUrl();
        break;
      case 'delete':
        await _deleteCoverImage();
        break;
    }
  }

  /// 从相册选择图片
  Future<void> _pickImageFromGallery() async {
    final activityProvider = context.read<ActivityProvider>();

    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      // 裁切图片
      final croppedFile = await _cropImage(image.path);
      if (croppedFile == null) return;

      // 保存裁切后的图片
      final imageFile = File(croppedFile.path);
      final cachedPath = await imageCacheManager.saveLocalImage(imageFile);

      if (cachedPath != null) {
        // 更新文章的封面图
        await activityProvider.updateArticleCoverImage(article.id, cachedPath);

        if (context.mounted) {
          onArticleUpdated(article.copyWith(coverImage: cachedPath), newImagePath: cachedPath);
          AppToast.showSuccess('封面图已更新');
        }
      } else {
        if (context.mounted) {
          AppToast.showError('保存图片失败');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('选择图片失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      if (context.mounted) {
        AppToast.showError('选择图片失败: ${e.toString()}');
      }
    }
  }

  /// 裁切图片
  /// 使用固定高度120的裁切框
  Future<CroppedFile?> _cropImage(String sourcePath) async {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    const coverHeight = 200.0;

    // 计算宽高比（宽度 : 高度），转换为 x:y 格式
    // 例如：屏幕宽度 390，高度 120，比例 = 390/120 = 3.25 = 13:4
    final aspectRatio = screenWidth / coverHeight;

    // 将比例转换为整数形式（避免精度问题）
    // 使用 10 作为基数来避免小数
    final ratioX = screenWidth * 10;
    final ratioY = coverHeight * 10;

    debugPrint('屏幕宽度: $screenWidth, 封面高度: $coverHeight, 宽高比: $aspectRatio ($ratioX:$ratioY)');

    // 获取当前主题
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        aspectRatio: CropAspectRatio(ratioX: ratioX, ratioY: ratioY),
        uiSettings: [
          // Android 样式配置
          AndroidUiSettings(
            // 工具栏
            // toolbarTitle: '裁切封面图',
            // toolbarColor: AppColors.primary,
            // toolbarWidgetColor: Colors.white,

            // 裁切框样式
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            activeControlsWidgetColor: AppColors.primary,

            // 裁切网格和边框
            showCropGrid: false,
            cropFrameColor: AppColors.primary,

            // 宽高比锁定
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,

            // 底部控件
            hideBottomControls: false,
          ),

          // iOS 样式配置
          IOSUiSettings(
            title: '裁切封面图',
            doneButtonTitle: '完成',
            cancelButtonTitle: '取消',

            // 宽高比
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,

            // 样式
            rotateButtonsHidden: true, // 隐藏旋转按钮
            showCancelConfirmationDialog: true, // 取消时显示确认对话框
          ),
        ],
      );

      return croppedFile;
    } catch (e) {
      debugPrint('裁切图片失败: $e');
      if (context.mounted) {
        AppToast.showError('裁切图片失败: $e');
      }
      return null;
    }
  }

  /// 输入图片 URL
  Future<void> _inputImageUrl() async {
    final activityProvider = context.read<ActivityProvider>();
    final TextEditingController urlController = TextEditingController();

    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入图片 URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, urlController.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (url == null || url.isEmpty) return;

    try {
      // 下载并缓存图片
      AppToast.showInfo('正在下载图片...');
      final cachedPath = await imageCacheManager.getImage(url);

      if (cachedPath != null) {
        // 更新文章的封面图
        await activityProvider.updateArticleCoverImage(article.id, cachedPath);

        if (context.mounted) {
          onArticleUpdated(article.copyWith(coverImage: cachedPath), newImagePath: cachedPath);
          AppToast.showSuccess('封面图已更新');
        }
      } else {
        if (context.mounted) {
          AppToast.showError('下载图片失败');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError('下载图片失败: $e');
      }
    }
  }

  /// 删除封面图
  Future<void> _deleteCoverImage() async {
    final activityProvider = context.read<ActivityProvider>();

    // 删除缓存文件
    if (article.coverImage != null) {
      if (article.coverImage!.startsWith('http')) {
        
        // 网络图片：删除 URL 对应的缓存
        await imageCacheManager.deleteCachedImage(article.coverImage!);
      } else {
        // 本地图片：删除本地缓存文件
        await imageCacheManager.deleteCachedFile(article.coverImage!);
      }
    }

    // 更新文章（删除 coverImage）
    await activityProvider.updateArticleCoverImage(article.id, null);

    if (context.mounted) {
      onArticleUpdated(article.copyWith(clearCoverImage: true));
      AppToast.showSuccess('封面图已删除');
    }
  }
}
