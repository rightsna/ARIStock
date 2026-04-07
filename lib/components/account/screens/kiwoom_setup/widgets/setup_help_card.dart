import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aristock/shared/theme.dart';

class SetupHelpCard extends StatelessWidget {
  const SetupHelpCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppTheme.primaryBlue, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '키움증권 Open API 홈페이지에서\nApp Key와 App Secret을 발급받을 수 있습니다.',
                      style: TextStyle(
                        color: AppTheme.textMain.withValues(alpha: 0.6),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => launchUrl(
                  Uri.parse('https://openapi.kiwoom.com/main/home'),
                  mode: LaunchMode.externalApplication,
                ),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.open_in_new_rounded,
                          color: AppTheme.primaryBlue, size: 14),
                      SizedBox(width: 8),
                      Text(
                        'openapi.kiwoom.com',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
