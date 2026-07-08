import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/network_image_view.dart';
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _avatarController = TextEditingController(text: widget.user.avatarUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    if (!mounted) return;

    final controller = context.read<ProfileController>();
    final success = await controller.uploadAvatar(pickedFile.path);

    if (!mounted) return;

    if (success) {
      _avatarController.text = controller.profile?.avatarUrl ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('profileUpdated')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(controller.error ?? 'photoUpdateFailed')),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = context.read<ProfileController>();

    final success = await controller.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarUrl: _avatarController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('profileUpdated')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(controller.error ?? context.tr('profileUpdateFailed')),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProfileController>().isSaving;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('editProfile'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.lg,
            AppSizes.lg,
            AppSizes.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileEditHero(
                user: widget.user,
                avatarUrlController: _avatarController,
                nameController: _nameController,
                onPickImage: _pickImage,
              ),
              const SizedBox(height: AppSizes.lg),
              AppCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.tr('accountInformation'),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('accountInformationDesc'),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      AppTextField(
                        label: context.tr('fullName'),
                        hint: context.tr('enterFullName'),
                        controller: _nameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr('nameRequired');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        label: context.tr('phoneNumber'),
                        hint: context.tr('optional'),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        label: context.tr('pastePublicImageUrl'),
                        hint: context.tr('optionalImageUrl'),
                        controller: _avatarController,
                        keyboardType: TextInputType.url,
                        prefixIcon: Icons.link_rounded,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      AppButton(
                        text: context.tr('saveChanges'),
                        icon: Icons.save_rounded,
                        isLoading: isSaving,
                        onPressed: isSaving ? null : _save,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileEditHero extends StatelessWidget {
  final UserModel user;
  final TextEditingController avatarUrlController;
  final TextEditingController nameController;
  final VoidCallback? onPickImage;

  const _ProfileEditHero({
    required this.user,
    required this.avatarUrlController,
    required this.nameController,
    this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      hasBorder: false,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: AppColors.tealGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.22),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: avatarUrlController,
              builder: (context, _) {
                final url = avatarUrlController.text.trim();

                return Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: url.isEmpty
                        ? Center(
                            child: Text(
                              user.initials,
                              style: const TextStyle(
                                color: AppColors.primaryTeal,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        : NetworkImageView(
                            imageUrl: url,
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                            borderRadius: 100,
                          ),
                  ),
                );
              },
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: nameController,
                    builder: (context, _) {
                      final displayName = nameController.text.trim().isEmpty
                          ? user.fullName
                          : nameController.text.trim();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('profile'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  InkWell(
                    onTap: onPickImage,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.tr('changePhoto'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
