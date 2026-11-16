/// The FAQ, keyed by stable topic rather than by position.
///
/// Contextual links elsewhere in the app open a specific entry, so the key has
/// to survive reordering — an index-based link silently repoints at the wrong
/// answer the moment a question is inserted above it.
library;

/// A question the app links to from somewhere.
///
/// Only topics that are deep-linked need a value here; the rest are just
/// entries in [faqEntries].
enum FaqTopic {
  otpRequired,
  otpNotArriving,
  otpIncorrect,
  dataCollected,
  dataStorage,
  logout,
  changeSemester,
  updateCredentials,
  otherStudentsData,
  officialApp,
}

class FaqEntry {
  const FaqEntry({
    required this.topic,
    required this.question,
    required this.answer,
  });

  final FaqTopic topic;
  final String question;
  final String answer;
}

/// Written to answer plainly rather than defensively. Where VTOP is the cause,
/// it says so as a fact — a student who is annoyed by the OTP is better served
/// by knowing where the rule comes from than by an apology.
const List<FaqEntry> faqEntries = <FaqEntry>[
  // ── Access and security ────────────────────────────────────────────────
  FaqEntry(
    topic: FaqTopic.otpRequired,
    question: 'Why does it ask for an OTP?',
    answer:
        'Because VTOP asks for one. VIT-AP enabled two-step verification on the '
        'VTOP portal itself, so any sign-in — the website, the app, anything — '
        'has to pass that check. It is not a rule this app added, and there is '
        'no way for the app to skip it.\n\n'
        'The OTP is needed when the app opens a fresh VTOP session, not every '
        'time you open the app. Once you verify, the app carries on with '
        'whatever it was fetching, and it will keep using that session until '
        'VTOP expires it.',
  ),
  FaqEntry(
    topic: FaqTopic.otpNotArriving,
    question: "The OTP isn't arriving in my email",
    answer:
        'The OTP is sent by VTOP directly to your registered university email — '
        'it never passes through this app, so the app cannot resend it any '
        'faster or see whether it arrived.\n\n'
        'Things worth checking: your spam or junk folder, whether your network '
        'is stable, and whether you are signed in to the right email account. '
        'Delivery is often slow when the campus network is congested. Use the '
        'Resend option in the verification sheet if a couple of minutes pass '
        'with nothing.',
  ),
  FaqEntry(
    topic: FaqTopic.otpIncorrect,
    question: 'It says my OTP is incorrect',
    answer:
        'The most common cause is using an older OTP. If you requested a new '
        'one, only the latest is valid — earlier codes stop working '
        'immediately. Check that you are reading the most recent email.\n\n'
        'OTPs also expire after a short time. If yours is more than a few '
        'minutes old, request a fresh one rather than retyping the old code.',
  ),
  FaqEntry(
    topic: FaqTopic.dataStorage,
    question: 'Where is my data stored?',
    answer:
        'On your phone. Your attendance, marks, timetable, grades and course '
        'information are stored locally on your device and are not uploaded '
        'anywhere.\n\n'
        'Your VTOP username and password are held in your device\'s secure '
        'credential storage — the Keychain on iOS, the KeyStore on Android — '
        'and are used only to sign in to VTOP when the app fetches your data.',
  ),
  FaqEntry(
    topic: FaqTopic.dataCollected,
    question: 'What data do you collect about me?',
    answer:
        'None of your academic data. Your marks, attendance, timetable and '
        'grades never leave your device.\n\n'
        'The app collects anonymous usage data: which screens are opened, which '
        'features are used, and errors the app runs into (with links, email '
        'addresses and long numbers stripped out). It also records your joining '
        'year and branch — taken from the first few characters of your '
        'registration number, with the digits unique to you discarded on the '
        'device — so it is possible to know roughly who uses the app without '
        'knowing who you are.\n\n'
        'No name, no registration number, no password, and no identifier that '
        'points back to you. You can turn this off entirely: Account → Settings '
        '→ Analytics.',
  ),
  FaqEntry(
    topic: FaqTopic.logout,
    question: 'What happens to my data if I log out?',
    answer:
        'Everything goes. Logging out deletes the academic data stored on your '
        'device, removes your saved VTOP credentials from secure storage, '
        'clears the anonymous analytics identity, and cancels any scheduled '
        'notifications. Uninstalling the app does the same.\n\n'
        'Nothing is retained anywhere else, because nothing was stored anywhere '
        'else in the first place.',
  ),
  FaqEntry(
    topic: FaqTopic.otherStudentsData,
    question:
        "Why can't the app show class averages, ranks or other students' marks?",
    answer:
        'Because the app has no access to anyone but you. It works by signing '
        'in to VTOP with your own credentials and reading the pages you would '
        'see yourself — there is no server holding everyone\'s results, and no '
        'way to see another student\'s data.\n\n'
        'A class average, a rank, or a comparison against your batch would '
        'require everyone\'s marks. VTOP does not expose that, and collecting '
        'it would mean building exactly the kind of central database this app '
        'deliberately does not have.',
  ),

  // ── Using the app ──────────────────────────────────────────────────────
  FaqEntry(
    topic: FaqTopic.changeSemester,
    question: 'How do I change semester?',
    answer:
        'Go to Account → Manage Credentials, pick the semester you want from '
        'the dropdown, and press Save.\n\n'
        'The app then starts pulling data for that semester. If a screen still '
        'shows the old semester, refresh it — attendance, marks and timetable '
        'each keep a local copy until you pull to refresh or press sync.',
  ),
  FaqEntry(
    topic: FaqTopic.updateCredentials,
    question: 'How do I update my VTOP username or password?',
    answer:
        'Go to Account → Manage Credentials, change the username or password, '
        'and press Save. The new credentials are stored securely on your device '
        'and used from the next fetch onwards.\n\n'
        'If you changed your password on VTOP itself, you must update it here '
        'too, otherwise sign-in will keep failing.',
  ),
  FaqEntry(
    topic: FaqTopic.officialApp,
    question: 'Is this an official VIT-AP app?',
    answer:
        'No. This app is built and maintained independently by Udhay Adithya, a '
        'student, and has no affiliation with VIT-AP University. It is not '
        'endorsed by, connected to, or operated by the university or its VTOP '
        'team.\n\n'
        'It reads your data from VTOP using your own login, in the same way you '
        'would by visiting the portal yourself.',
  ),
];

/// The entry for [topic], or null when it is not in the list.
FaqEntry? faqEntryFor(FaqTopic topic) {
  for (final FaqEntry entry in faqEntries) {
    if (entry.topic == topic) return entry;
  }
  return null;
}

/// Position of [topic] in [faqEntries], or -1.
int faqIndexOf(FaqTopic topic) =>
    faqEntries.indexWhere((FaqEntry entry) => entry.topic == topic);
