import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/widgets/app_cards.dart';
import '../../data/models/resource.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  const ResourceCard({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    final type = AppColorUtils.parseResourceType(resource.type);
    final color = AppColorUtils.getResourceColor(type);
    final icon = AppColorUtils.getResourceIcon(type);
    final label = AppColorUtils.getResourceLabel(type);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: AppIconContainer(icon: icon, color: color),
        title: Text(
          resource.description,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.75),
            fontSize: AppSizes.fontSM,
          ),
        ),
        trailing: const Icon(Icons.open_in_new, color: AppTheme.primaryTeal),
        onTap: () => _launchUrl(resource.url, context),
      ),
    );
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }
}
