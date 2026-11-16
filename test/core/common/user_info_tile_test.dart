import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vit_ap_student_app/core/common/widget/user_info_tile.dart';

Future<void> pumpTile(WidgetTester tester, Widget tile) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Column(children: [tile])),
    ),
  );
}

void main() {
  group('UserInfoTile', () {
    testWidgets('a copyable row is pressable and shows a copy control', (
      tester,
    ) async {
      await pumpTile(
        tester,
        const UserInfoTile('Registration Number', '21BCE1234', copyable: true),
      );

      expect(find.byType(InkWell), findsWidgets);
      expect(find.byTooltip('Copy Registration Number'), findsOneWidget);
    });

    testWidgets('a plain row carries no control and no ink', (tester) async {
      // Not every value is worth pasting somewhere; an icon on each of eight
      // rows stops signalling anything.
      await pumpTile(tester, const UserInfoTile('Blood Group', 'O+'));

      expect(find.byType(InkWell), findsNothing);
      expect(find.byTooltip('Copy Blood Group'), findsNothing);
    });

    testWidgets(
      // The long press used to be offered on every row and silently did nothing
      // when there was no value — so the one time somebody discovered the
      // gesture, it might not work.
      'a missing value is visibly inert, not silently inert',
      (tester) async {
        await pumpTile(
          tester,
          const UserInfoTile('Cabin', 'N/A', copyable: true),
        );

        expect(find.byType(InkWell), findsNothing);
        expect(find.byTooltip('Copy Cabin'), findsNothing);
      },
    );

    testWidgets('an empty value is treated the same as N/A', (tester) async {
      await pumpTile(
        tester,
        const UserInfoTile('Cabin', '   ', copyable: true),
      );

      expect(find.text('N/A'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('tapping a copyable row puts the value on the clipboard', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pumpTile(
        tester,
        const UserInfoTile(
          'Email',
          ' someone@vitapstudent.ac.in ',
          copyable: true,
        ),
      );
      await tester.tap(find.text('someone@vitapstudent.ac.in'));
      await tester.pump();

      expect(copied, 'someone@vitapstudent.ac.in');
    });

    testWidgets(
      // Copying a phone number so you can paste it into the dialer is a worse
      // version of tapping Call, so the action owns the row's tap.
      'a row with an action runs the action on tap, not the copy',
      (tester) async {
        var called = 0;
        await pumpTile(
          tester,
          UserInfoTile(
            'Mobile Number',
            '+91 90000 00000',
            copyable: true,
            action: UserInfoAction(
              icon: Icons.call,
              tooltip: 'Call',
              onTap: () => called++,
            ),
          ),
        );

        await tester.tap(find.text('+91 90000 00000'));
        await tester.pump();

        expect(called, 1);
        // Copy is still offered alongside it.
        expect(find.byTooltip('Copy Mobile Number'), findsOneWidget);
        expect(find.byTooltip('Call'), findsOneWidget);
      },
    );

    testWidgets('an action on a missing value is not offered', (tester) async {
      var called = 0;
      await pumpTile(
        tester,
        UserInfoTile(
          'Mobile Number',
          'N/A',
          copyable: true,
          action: UserInfoAction(
            icon: Icons.call,
            tooltip: 'Call',
            onTap: () => called++,
          ),
        ),
      );

      expect(find.byTooltip('Call'), findsNothing);
      expect(called, 0);
    });
  });
}
