import 'dart:async';

import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import '../services/pro_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_action_button.dart';
import '../widgets/app_screen.dart';
import '../widgets/app_section_card.dart';

class ProPage extends StatefulWidget {
  const ProPage({super.key, this.service});
  final ProService? service;
  @override
  State<ProPage> createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  late final _pro = widget.service ?? ProService.instance;
  @override
  void initState() {
    super.initState();
    unawaited(_pro.initialize());
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => AppLocalizations.text(context, key);
    return ListenableBuilder(
      listenable: _pro,
      builder: (context, _) {
        final statusKey = switch (_pro.state) {
          ProPurchaseState.checking => 'proChecking',
          ProPurchaseState.pending => 'proPending',
          ProPurchaseState.canceled => 'proCanceled',
          ProPurchaseState.error => 'proError',
          ProPurchaseState.noPurchases => 'proNoPurchases',
          ProPurchaseState.unavailable => 'proUnavailable',
          _ => _pro.hasPro ? 'proActive' : 'proTagline',
        };
        return AppScreen(
          titleText: t('proTitle'),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            children: [
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: AppColors.accent(context),
              ),
              const SizedBox(height: 12),
              Text(
                t('proTagline'),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              for (final feature in [
                (Icons.block, 'proAdFree', 'proAdFreeDesc'),
                (Icons.tune, 'proCustomTimes', 'proCustomTimesDesc'),
                (Icons.bookmarks_outlined, 'proPresets', 'proPresetsDesc'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppSectionCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        feature.$1,
                        color: AppColors.accent(context),
                      ),
                      title: Text(t(feature.$2)),
                      subtitle: Text(t(feature.$3)),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(t(statusKey), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 20),
              AppPrimaryButton(
                onPressed: _pro.canPurchase
                    ? () => unawaited(_pro.purchase())
                    : null,
                label: _pro.hasPro
                    ? t('proActive')
                    : _pro.product == null
                    ? t('proPurchaseUnavailable')
                    : t(
                        'proUpgradePrice',
                      ).replaceAll('{price}', _pro.product!.localizedPrice),
              ),
              TextButton(
                onPressed: _pro.canRestore
                    ? () => unawaited(_pro.restore())
                    : null,
                child: Text(t('proRestore')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t('proKeepFree')),
              ),
            ],
          ),
        );
      },
    );
  }
}
