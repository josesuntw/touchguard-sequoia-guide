---
title: "TouchGuard Not Working on macOS Sequoia? The Real Fix (2026)"
description: "TouchGuard does nothing on macOS Sequoia? Sequoia silently resets TCC permissions on reboot. Learn the LaunchAgent fix that actually sticks."
---

# TouchGuard Not Working on macOS Sequoia? The Real Fix (2026)

You installed TouchGuard, rebooted, and your cursor is still jumping around like nothing happened. If TouchGuard is not working on macOS Sequoia, you're not doing it wrong — and it's not a version mismatch. Sequoia has a quiet mechanism that strips TouchGuard's accessibility permissions on login without telling you.

Everything below is the exact fix. The LaunchAgent config file is also available at the [touchguard-sequoia-guide repo](https://github.com/josesuntw/touchguard-sequoia-guide) if you want to skip ahead.

---

## Why TouchGuard Appears to Install Successfully But Does Nothing

The confusing part is that the installation flow looks normal. TouchGuard moves to `/Applications`, the Accessibility prompt appears, you click Allow — and then after a reboot, the cursor problem is back.

What happened is not that TouchGuard forgot your settings. What happened is that macOS revoked the permission it granted, silently, between sessions.

This behavior is specific to Sequoia (macOS 15). Earlier versions of macOS handled Accessibility grants more permissively for apps launched via LaunchAgent. Sequoia tightened that — and no one sent you a notification.

---

## The Root Cause: How macOS Sequoia Changed TCC Permission Handling

TCC (Transparency, Consent, and Control) is the macOS subsystem that manages sensitive permissions: Accessibility, Full Disk Access, Camera, and others.

In Sequoia, TCC ties an Accessibility grant to a specific combination of: the app binary's path, its code signature (or lack of one), and the process identity that made the request.

When TouchGuard launches through a LaunchAgent — which runs as your user account but in a different execution context than a manually launched app — the TCC record from your manual grant does not always match what Sequoia expects at login. The result: the permission is present in System Settings, but it is not applied at runtime.

This is why every "just re-grant the permission" answer you found on Reddit only works until the next reboot. It treats the symptom, not the mismatch.

This behavior is particularly inconsistent for unsigned apps requesting accessibility permission on Sequoia — apps that haven't gone through Apple's notarization process are subject to stricter TCC enforcement after each login event.

---

## Step 1: Verify TouchGuard Is Actually Running (Terminal Check)

Before adjusting anything, confirm whether TouchGuard is running at all.

Open Terminal and run:

```bash
pgrep -l TouchGuard
```

**If TouchGuard is running, you'll see something like:**
```
1847 TouchGuard
```

**If nothing is returned**, TouchGuard is not running. The LaunchAgent either failed to start it, or the binary path in the plist is wrong.

To check the LaunchAgent status directly:

```bash
launchctl list | grep -i touchguard
```

**Expected output when loaded correctly:**
```
1847    0    com.josesun.touchguard
```

If the first column shows `-` instead of a PID, the process is not running. If the second column shows a non-zero number (like `1` or `256`), the process launched but exited with an error.

---

## Step 2: Grant Accessibility Permission for Unsigned Apps the Correct Way in Sequoia 15

The permission dialog behavior changed in Sequoia. Clicking Allow in the pop-up that appears at install time is often not sufficient. You need to verify the grant is recorded for the correct binary.

1. Open **System Settings → Privacy & Security → Accessibility**
2. Look for TouchGuard in the list
3. If it is listed but toggled off, toggle it on
4. If it is not listed at all, click the `+` button and navigate to `/Applications/TouchGuard.app`

After adding it, do not reboot yet. First, run this command to confirm the grant is recorded in TCC:

```bash
tccutil reset Accessibility com.josesun.touchguard 2>/dev/null; echo "Reset complete"
```

Then re-add TouchGuard in System Settings as described above. This forces a fresh TCC record rather than relying on a potentially stale one.

---

## Step 3: Why macOS Accessibility Permission Keeps Getting Removed After Reboot

The core issue is that macOS Sequoia TCC permission resets after update or reboot for apps outside the App Store. This isn't a bug — it's an intentional security posture change in Sequoia 15.

The most common reason permissions disappear on reboot is a mismatch between how the LaunchAgent launches the binary and how TCC recorded the grant.

Check your LaunchAgent plist path:

```bash
cat ~/Library/LaunchAgents/com.josesun.touchguard.plist
```

The `ProgramArguments` key should point to the exact binary, not a wrapper or symlink:

```xml
<key>ProgramArguments</key>
<array>
    <string>/Applications/TouchGuard.app/Contents/MacOS/TouchGuard</string>
</array>
```

If the path shows anything else (a symlink in `/usr/local/bin`, a shell wrapper, or a relative path), that is your problem. Sequoia's TCC checks the resolved binary path, and a symlink resolves to a different identity.

Also verify the plist is in the correct location and owned by your user:

```bash
ls -la ~/Library/LaunchAgents/com.josesun.touchguard.plist
```

**Expected output:**
```
-rw-r--r--  1 yourname  staff  412 Apr 10 09:22 /Users/yourname/Library/LaunchAgents/com.josesun.touchguard.plist
```

If the owner is `root`, the LaunchAgent will not load correctly for your user session.

---

## The Permanent Fix: LaunchAgent Method for TouchGuard Accessibility Permission on Sequoia

> The LaunchAgent plist used in this section is available at [touchguard-sequoia-guide on GitHub](https://github.com/josesuntw/touchguard-sequoia-guide). You can download it directly instead of copying from the code block below.

Once you have verified the plist path and re-granted the permission correctly, reload the LaunchAgent so you don't have to reboot to test:

```bash
launchctl unload ~/Library/LaunchAgents/com.josesun.touchguard.plist
launchctl load ~/Library/LaunchAgents/com.josesun.touchguard.plist
```

Then confirm it loaded:

```bash
launchctl list | grep -i touchguard
```

You should now see a PID in the first column and `0` in the second.

After a macOS update, Sequoia sometimes resets the TCC database for third-party Accessibility grants. If TouchGuard stops working again after an OS update, the fastest recovery is:

```bash
tccutil reset Accessibility com.josesun.touchguard
```

Then re-add it in System Settings. Takes about 30 seconds.

---

## Troubleshooting: TouchGuard Apple Silicon M1 M2 Permission Issues

### TouchGuard Apple Silicon M1/M2 Permission: Additional Restrictions

On Apple Silicon Macs (M1 through M4), there is one additional requirement: the binary must be allowed to run under Gatekeeper before TCC will honor its Accessibility grant.

If you installed TouchGuard from outside the Mac App Store and have not explicitly allowed it, run:

```bash
xattr -dr com.apple.quarantine /Applications/TouchGuard.app
```

This removes the quarantine flag that Gatekeeper attaches to downloaded apps. Without this step, Sequoia may silently block the binary at launch even if the LaunchAgent loads successfully.

To confirm Gatekeeper is not blocking it:

```bash
spctl --assess --verbose /Applications/TouchGuard.app
```

**If it's clear:**
```
/Applications/TouchGuard.app: accepted
```

**If it's blocked:**
```
/Applications/TouchGuard.app: rejected
source=no usable signature
```

In the blocked case, run the `xattr` command above, then repeat the TCC reset and re-grant steps from Step 2.

---

## Frequently Asked Questions

**Q: Why does TouchGuard stop working after a macOS update?**

macOS updates can reset the TCC database entries for third-party Accessibility grants. After any update, open System Settings → Privacy & Security → Accessibility and verify TouchGuard is still listed and enabled. If it is missing, re-add it. If it is listed but not working, run `tccutil reset Accessibility com.josesun.touchguard` and re-grant.

**Q: How do I grant accessibility permission to an unsigned app on macOS Sequoia?**

First, remove the quarantine attribute: `xattr -dr com.apple.quarantine /Applications/TouchGuard.app`. Then open System Settings → Privacy & Security → Accessibility, click `+`, and add the app manually.

**Q: Does TouchGuard work on Apple Silicon Macs?**

Yes, with the quarantine step described in the Troubleshooting section. Apple Silicon machines are stricter about Gatekeeper enforcement, which is why the `xattr` command is required on M-series hardware when installing from outside the App Store.

**Q: Why does macOS Sequoia keep removing accessibility permissions?**

Sequoia removes Accessibility permissions when: the app binary changes (after an update), the TCC record becomes inconsistent with the current code signature state, or a background OS process determines the grant is attached to a quarantined or unverified binary.

---

Found this useful or hit an issue not covered here? [Open a discussion on GitHub](https://github.com/josesuntw/touchguard-sequoia-guide/discussions) — edge cases from real setups help improve this guide.
