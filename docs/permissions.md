# Commands Only — TouchGuard Sequoia (LaunchAgent) / 只有指令版

> Copy & paste blocks as needed. No explanations inside this file.

## 1) Restart TouchGuard (LaunchAgent)
```bash
launchctl kickstart -k gui/$(id -u)/org.amanagr.TouchGuard
```

## 2) Verify it is running
```bash
launchctl print gui/$(id -u)/org.amanagr.TouchGuard | egrep 'state =|pid =|last exit code|runs ='
pgrep -ax TouchGuard
```

## 3) Check TouchGuard log
```bash
tail -n 120 /tmp/TouchGuard.log
```

## 4) Check TCC logs (permission issues)
```bash
log show --last 30m --predicate '(subsystem == "com.apple.TCC") AND (eventMessage CONTAINS[c] "TouchGuard")' --info
```
