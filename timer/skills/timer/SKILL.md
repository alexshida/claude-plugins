---
name: timer
description: Use this skill when the user wants to delay or schedule a prompt to run after a time duration, such as "in 30 minutes do X", "after 1 hour run Y", "schedule this prompt for later", or "wait N minutes then ask Z". Invokes the /timer command.
---

# Timer Skill

When a user wants to schedule a prompt to fire after a delay, use the `/timer` command:

```
/timer <duration> <prompt>
```

Examples:
- User: "in 30 minutes, check if the server is up" → `/timer 30m check if the server is up`
- User: "after 2 hours remind me to push my changes" → `/timer 2h remind me to push my changes`
- User: "wait an hour then summarize what we've done" → `/timer 1h summarize what we've done in this session`
