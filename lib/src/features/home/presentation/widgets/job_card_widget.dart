import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../shared/models/v2/job/job_details_dto.dart';
import '../../../../core/theme/app_colors.dart';

class JobCardWidget extends StatelessWidget {
  final JobDetailsDTO job;
  final VoidCallback? onTap;
  final VoidCallback? onApplyTap;
  final bool isApplied;
  final bool isApplying;
  final String? statusBadge; // For Jobs tab: 'pending', 'accepted', 'rejected', etc.

  const JobCardWidget({
    super.key,
    required this.job,
    this.onTap,
    this.onApplyTap,
    this.isApplied = false,
    this.isApplying = false,
    this.statusBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Subtle shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: _buildStackChildren(),
      ),
    );
  }

  List<Widget> _buildStackChildren() {
    final children = <Widget>[
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row: Logo, Title, Bookmark
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        
                      ),
                      child: Icon(Icons.work_outline_outlined,color: AppColors.primaryBlue,),
                    ),
                    const SizedBox(width: 12),

                    // Title and Org
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.hiringFor ?? 'Job Title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.orgName ?? 'Organization',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Apply/Applied icon
                    GestureDetector(
                      onTap: isApplying ? null : onApplyTap,
                      child: isApplying
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryBlue,
                                ),
                              ),
                            )
                          : Icon(
                              isApplied ? Icons.bookmark : Icons.bookmark_border_outlined,
                              color: isApplied ? Colors.green : AppColors.primaryBlue,
                              size: 24,
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 12),

                // Details Row (Salary, Type, Time)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Salary
                    _buildMetaItem(
                      icon: Icons.account_balance_wallet_outlined,
                      text: job.getSalaryDisplay(),
                    ),
                    // Type
                    _buildMetaItem(
                      icon: Icons.work_outline,
                      text: job.getJobTypeDisplay(),
                    ),
                    // Time
                    _buildMetaItem(
                      icon: Icons.access_time,
                      text: job.createdAt != null
                          ? timeago.format(job.createdAt!)
                          : 'Recently',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ];

    // Add status badge if present
    if (statusBadge != null) {
      children.add(
        Positioned(
          top: 8,
          right: 8,
          child: _buildStatusBadge(statusBadge!),
        ),
      );
    }

    return children;
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String badgeText;

    switch (status.toLowerCase()) {
      case 'accepted':
        badgeColor = const Color(0xFF4CAF50); // Green
        badgeText = 'Accepted';
        break;
      case 'rejected':
        badgeColor = const Color(0xFFF44336); // Red
        badgeText = 'Rejected';
        break;
      case 'reviewed':
        badgeColor = const Color(0xFF2196F3); // Blue
        badgeText = 'Reviewed';
        break;
      case 'pending':
      default:
        badgeColor = const Color(0xFFFFC107); // Amber
        badgeText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetaItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}