import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/image/circle_shape_image.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/profile/controller/profile_controller.dart';
import 'package:flutex_admin/features/profile/repo/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final controller = Get.put(ProfileController(profileRepo: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(mounted) {
         controller.loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: controller.isLoading
            ? const CustomLoader()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context, controller),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionHeader(context, "Contact Information"),
                        const SizedBox(height: 16),
                        _buildContactInfo(context, controller),
                        
                        const SizedBox(height: 32),
                        _buildSectionHeader(context, "Account Actions"),
                        const SizedBox(height: 16),
                         _buildActionCard(
                          context,
                          'Edit Profile',
                          Icons.edit_outlined,
                          () => Get.toNamed(RouteHelper.editProfileScreen),
                          ColorResources.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        _buildActionCard(
                          context,
                          'Change Password',
                          Icons.lock_reset_outlined,
                           () {
                             // RouteHelper.changePasswordScreen; // TODO: Implement route
                           },
                          ColorResources.primaryColor,
                        ),
                         const SizedBox(height: 50),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ProfileController controller) {
    return SliverAppBar(
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      backgroundColor: ColorResources.primaryColor,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
             color: Colors.white.withValues(alpha: 0.2),
             borderRadius: BorderRadius.circular(8),
           ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
            onPressed: () => Get.toNamed(RouteHelper.settingsScreen),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorResources.primaryColor,
                ColorResources.secondaryColor,
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
               // Abstract Shapes
              Positioned(
                top: -50,
                right: -50,
                 child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: Colors.white.withValues(alpha: 0.05),
                  ),
                 ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                 child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: Colors.white.withValues(alpha: 0.05),
                  ),
                 ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleImageWidget(
                        imagePath: controller.profileModel.data?.profileImage ?? '',
                        isAsset: false,
                        isProfile: true,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${controller.profileModel.data?.firstName ?? ''} ${controller.profileModel.data?.lastName ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.profileModel.data?.role ?? 'Staff Member', 
                       style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: ColorResources.primaryColor.withValues(alpha: 0.8),
        letterSpacing: 1.0,
      ).copyWith(fontFeatures: [const FontFeature.enable('smcp')]), // Small caps if supported
    );
  }

  Widget _buildContactInfo(BuildContext context, ProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            context,
            Icons.email_outlined,
            'Email Address',
            controller.profileModel.data?.email ?? '',
            () => _launchUrl('mailto:${controller.profileModel.data?.email}'),
          ),
          Divider(height: 1, indent: 60, color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
          _buildInfoTile(
            context,
            Icons.phone_outlined,
            'Phone Number',
            controller.profileModel.data?.phoneNumber ?? '',
            () => _launchUrl('tel:${controller.profileModel.data?.phoneNumber}'),
          ),
          if (controller.profileModel.data?.skype != null && controller.profileModel.data!.skype!.isNotEmpty) ...[
             Divider(height: 1, indent: 60, color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
             _buildInfoTile(
              context,
              Icons.chat_bubble_outline_rounded,
              'Skype',
              controller.profileModel.data?.skype ?? '',
              null,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value, VoidCallback? onTap) {
    return ListTile(
      onTap: onTap,
       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorResources.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: ColorResources.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
           fontWeight: FontWeight.w600,
           color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: onTap != null 
          ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: ColorResources.hintColor)
          : null,
    );
  }
  
  Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: color.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(10),
               ),
               child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: ColorResources.hintColor),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
