import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../data/models/article.dart';
import '../../providers/activity_provider.dart';
import '../../utils/image_cache_manager.dart';
import '../../widgets/app_toast.dart';
import 'bottom_sheet_menu.dart';

/// 封面图管理器
class CoverImageManager {
  final BuildContext context;
  final Article article;
  final ImagePicker imagePicker;
  final ImageCacheManager imageCacheManager;
  final Function(Article) onArticleUpdated;

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

      // 将图片保存到缓存目录
      final imageFile = File(image.path);
      final cachedPath = await imageCacheManager.saveLocalImage(imageFile);

      if (cachedPath != null) {
        // 更新文章的封面图
        await activityProvider.updateArticleCoverImage(article.id, cachedPath);

        if (context.mounted) {
          onArticleUpdated(article.copyWith(coverImage: cachedPath));
          AppToast.showSuccess('封面图已更新');
        }
      } else {
        if (context.mounted) {
          AppToast.showError('保存图片失败');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError('选择图片失败: $e');
      }
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
          onArticleUpdated(article.copyWith(coverImage: cachedPath));
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

    // 删除网络图片的缓存（如果原始是 URL）
    if (article.coverImage != null && article.coverImage!.startsWith('http')) {
      await imageCacheManager.deleteCachedImage(article.coverImage!);
    }

    // 更新文章（删除 coverImage）
    await activityProvider.updateArticleCoverImage(article.id, null);

    if (context.mounted) {
      onArticleUpdated(article.copyWith(coverImage: null));
      AppToast.showSuccess('封面图已删除');
    }
  }
}
