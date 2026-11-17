# Name and logo policy

The source code of VITAP Student is licensed under the GNU GPL, version 3
(see `LICENSE` and `NOTICE`). That license covers the code. It does not
cover the app's identity.

## The name

"VITAP Student" is the name the app is published under on Google Play and
the App Store. No trademark is claimed in it: "VIT-AP" belongs to VIT-AP
University, and the name only describes who the app is for.

VITAP Student is an independent project, built by a student for other
students. It is not affiliated with, endorsed by, or operated by VIT-AP
University.

Even so, section 7(c) of the GPL terms in `NOTICE` forbids presenting a
modified version as this app. A fork must not be published as
"VITAP Student", or under a name close enough to be mistaken for it.

## The logo and icons

The app icon is built on "Mortarboard icons created by Magnific -
Flaticon" (https://www.flaticon.com/free-icon/mortarboard_3845897), used
under the Flaticon license. The GPL in this repository does not cover it,
and this project cannot license it to anyone else. This applies to:

- `assets/images/logo/`
- the launcher icons generated from it, in `android/app/src/main/res/mipmap-*/`
  and `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Section 7(c) of the GPL terms in `NOTICE` requires forks to use a
different icon, so these files must be replaced in any fork.

## Allowed without asking

- Saying that a project is based on VITAP Student, or works with it, as
  long as that statement is accurate. `NOTICE` requires this attribution
  in forks.
- Building and running the unmodified app from this repository for
  personal use.

## Forks

Forks are welcome under the terms of the license. Before publishing one:

1. Choose a new name and a new icon.
2. Change the Android `applicationId` and namespace, the iOS bundle
   identifier, and the app group identifiers. Two apps cannot share the
   package name `com.udhay.vitapstudentapp`.
3. Keep the attribution required by `NOTICE`, both in the app and in the
   README.
4. Use your own Firebase project, API keys and backend endpoints. The
   services this project runs are for its official builds only.
