import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../theme/app_colors.dart';
import 'campus_card.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.saved,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final typeStr =
        opportunity.type.isNotEmpty ? opportunity.type : opportunity.category;
    final accent = AppColors.opportunityAccent(typeStr);

    return CampusCard(
      onTap: onTap,
      color: AppColors.opportunitySurface(typeStr),
      borderColor: accent.withOpacity(.18),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.11),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(opportunity.icon, color: accent, size: 19),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  typeStr.toUpperCase(),
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cocoa.withOpacity(.10),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${opportunity.fit}% Fit',
                  style: const TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onSave,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: saved ? AppColors.hue : AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            opportunity.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            opportunity.organizer,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 12,
            runSpacing: 7,
            children: [
              _meta(Icons.calendar_today_outlined, opportunity.date),
              _meta(Icons.location_on_outlined, opportunity.location),
              _meta(Icons.language_outlined, opportunity.mode),
              _meta(Icons.payments_outlined, opportunity.fee),
            ],
          ),
          if (opportunity.registrationText.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              opportunity.registrationText,
              style: const TextStyle(
                color: AppColors.hue,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 9),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: opportunity.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withOpacity(.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }).toList(),
          ),
          if (opportunity.reason.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              opportunity.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSoft,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.secondary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}
