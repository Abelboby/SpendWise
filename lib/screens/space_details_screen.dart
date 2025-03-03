import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/space_model.dart';
import '../providers/space_provider.dart';
import '../providers/auth_provider.dart';

class SpaceDetailsScreen extends StatelessWidget {
  final SpaceModel space;

  const SpaceDetailsScreen({
    super.key,
    required this.space,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final spaceProvider = Provider.of<SpaceProvider>(context);
    final isOwner = space.isOwner(authProvider.uid);

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          'Space Details',
          style: TextStyle(color: AppColors.lightGrey),
        ),
        iconTheme: IconThemeData(color: AppColors.lightGrey),
        actions: [
          if (isOwner)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppColors.lightGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Delete Space',
                      style: TextStyle(color: AppColors.navy),
                    ),
                    content: Text(
                      'Are you sure you want to delete this space? This action cannot be undone.',
                      style: TextStyle(color: AppColors.darkGrey),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.darkGrey,
                        ),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await spaceProvider.deleteSpace(space.id);
                            if (context.mounted) {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Go back to spaces list
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error deleting space: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.navy,
                  AppColors.darkGrey,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  space.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.lightGrey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  space.description,
                  style: TextStyle(
                    color: AppColors.lightGrey.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      space.isPublic ? Icons.public : Icons.lock_outline,
                      size: 16,
                      color: AppColors.lightGrey.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      space.isPublic ? 'Public Space' : 'Private Space',
                      style: TextStyle(
                        color: AppColors.lightGrey.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Members',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: space.members.length,
                  itemBuilder: (context, index) {
                    final member = space.members[index];
                    final isCurrentUser = member.userId == authProvider.uid;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.navy.withOpacity(0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            if (member.photoUrl != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(member.photoUrl!),
                                radius: 20,
                              )
                            else
                              CircleAvatar(
                                backgroundColor:
                                    AppColors.accent.withOpacity(0.1),
                                radius: 20,
                                child: Text(
                                  member.displayName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${member.displayName}${isCurrentUser ? ' (You)' : ''}',
                                        style: TextStyle(
                                          color: AppColors.navy,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (space.isOwner(member.userId)) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.star_rounded,
                                          color: AppColors.accent,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: member.role == SpaceRole.owner
                                          ? AppColors.accent.withOpacity(0.1)
                                          : member.role == SpaceRole.editor
                                              ? AppColors.navy.withOpacity(0.1)
                                              : AppColors.darkGrey
                                                  .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      member.role.toString().split('.').last,
                                      style: TextStyle(
                                        color: member.role == SpaceRole.owner
                                            ? AppColors.accent
                                            : member.role == SpaceRole.editor
                                                ? AppColors.navy
                                                : AppColors.darkGrey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isOwner && !isCurrentUser)
                              PopupMenuButton<SpaceRole>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: AppColors.darkGrey,
                                ),
                                onSelected: (SpaceRole role) {
                                  spaceProvider.updateMemberRole(
                                    space.id,
                                    member.userId,
                                    role,
                                  );
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: SpaceRole.editor,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          color: AppColors.navy,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Make Editor',
                                          style:
                                              TextStyle(color: AppColors.navy),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: SpaceRole.viewer,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.visibility_outlined,
                                          color: AppColors.navy,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Make Viewer',
                                          style:
                                              TextStyle(color: AppColors.navy),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isOwner
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppColors.lightGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          'Leave Space',
                          style: TextStyle(color: AppColors.navy),
                        ),
                        content: Text(
                          'Are you sure you want to leave this space?',
                          style: TextStyle(color: AppColors.darkGrey),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.darkGrey,
                            ),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await spaceProvider.leaveSpace(space.id);
                                if (context.mounted) {
                                  Navigator.pop(context); // Close dialog
                                  Navigator.pop(
                                      context); // Go back to spaces list
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error leaving space: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Leave'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Leave Space'),
                ),
              ),
            )
          : null,
    );
  }
}
