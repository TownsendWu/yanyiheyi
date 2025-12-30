import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/user_profile.dart';
import '../core/theme/app_colors.dart';
import '../widgets/page_container.dart';

/// 用户信息编辑页面
class UserProfileEditPage extends StatefulWidget {
  final UserProfile initialProfile;

  const UserProfileEditPage({
    super.key,
    required this.initialProfile,
  });

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  File? _avatarFile; // 本地头像文件

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.initialProfile.nickname);
    _emailController = TextEditingController(text: widget.initialProfile.email);
    _bioController = TextEditingController(text: widget.initialProfile.bio ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // 保存修改
  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProfile = widget.initialProfile.copyWith(
        nickname: _nicknameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        avatar: _avatarFile?.path, // 使用本地文件路径
      );

      // 返回更新后的用户信息
      Navigator.pop(context, updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存成功'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 选择头像
  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  // 从相册选择图片
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image != null) {
      setState(() {
        _avatarFile = File(image.path);
      });
    }
  }

  // 从相机拍照
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image != null) {
      setState(() {
        _avatarFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人信息'),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        actions: [
          // 保存按钮
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              '保存',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: PageContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              // 头像区域
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                            backgroundImage: _avatarFile != null
                                ? FileImage(_avatarFile!)
                                : (widget.initialProfile.avatar != null
                                    ? NetworkImage(widget.initialProfile.avatar!) as ImageProvider
                                    : null),
                            child: _avatarFile == null && widget.initialProfile.avatar == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          // 编辑头像按钮
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primaryDark : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击更换头像',
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 昵称输入框
              _buildTextField(
                label: '昵称',
                controller: _nicknameController,
                hint: '请输入昵称',
                prefixIcon: Icons.person_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '昵称不能为空';
                  }
                  if (value.trim().length > 20) {
                    return '昵称不能超过20个字符';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // 邮箱输入框
              _buildTextField(
                label: '邮箱',
                controller: _emailController,
                hint: '请输入邮箱地址',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '邮箱不能为空';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // 个人简介输入框
              _buildTextField(
                label: '个人简介',
                controller: _bioController,
                hint: '介绍一下自己吧',
                prefixIcon: Icons.edit_outlined,
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.trim().length > 100) {
                    return '个人简介不能超过100个字符';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 15,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: subtitleColor),
            prefixIcon: Icon(prefixIcon, color: subtitleColor),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.primaryDark : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
