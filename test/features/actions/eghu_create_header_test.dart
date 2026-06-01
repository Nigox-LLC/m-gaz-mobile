import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/create/eghu_create_header.dart';

void main() {
  group('EghuCreateHeader', () {
    for (final config in const [
      _HeaderConfig(
        buttonKey: 'eghu-create-help-button',
        tooltipKey: 'eghu-create-help-tooltip',
      ),
      _HeaderConfig(
        buttonKey: 'eghu-indicator-help-button',
        tooltipKey: 'eghu-indicator-help-tooltip',
      ),
      _HeaderConfig(
        buttonKey: 'eghu-detach-help-button',
        tooltipKey: 'eghu-detach-help-tooltip',
      ),
    ]) {
      testWidgets('toggles ${config.tooltipKey}', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EghuCreateHeader(
                title: 'EGHU',
                helpText: 'Help text',
                helpButtonKey: Key(config.buttonKey),
                helpTooltipKey: Key(config.tooltipKey),
              ),
            ),
          ),
        );

        expect(find.byKey(Key(config.tooltipKey)), findsNothing);

        await tester.tap(find.byKey(Key(config.buttonKey)));
        await tester.pump();

        expect(find.byKey(Key(config.tooltipKey)), findsOneWidget);
        expect(find.text('Help text'), findsOneWidget);

        await tester.tap(find.byKey(Key(config.buttonKey)));
        await tester.pump();

        expect(find.byKey(Key(config.tooltipKey)), findsNothing);
      });
    }
  });
}

class _HeaderConfig {
  const _HeaderConfig({required this.buttonKey, required this.tooltipKey});

  final String buttonKey;
  final String tooltipKey;
}
