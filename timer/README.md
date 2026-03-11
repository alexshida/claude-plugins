# timer

A Claude Code plugin that delays a prompt by a given duration before submitting it.

## Usage

```
/timer <duration> <prompt>
```

## Examples

```
/timer 1hr write a summary of today's work
/timer 30m check if the build is passing
/timer 2h30m run the full test suite
/timer 1d remind me to review the PR
```

## Duration Formats

| Format | Example | Meaning |
|--------|---------|---------|
| `s` | `30s` | 30 seconds (minimum 1 minute) |
| `m` / `min` | `15m`, `15min` | 15 minutes |
| `h` / `hr` / `hrs` | `2h`, `2hr`, `2hrs` | 2 hours |
| `d` | `1d` | 1 day |
| Combined | `1h30m`, `1d6h` | 1 hour 30 minutes, 1 day 6 hours |

## How It Works

1. Parses the duration from the first argument
2. Computes the exact target time (`now + delay`)
3. Schedules the prompt as a one-shot cron job via `CronCreate`
4. Confirms the scheduled time and job ID — use the ID to cancel with `CronDelete` if needed

Scheduled jobs are session-only and fire once, then auto-delete.

## Cancelling a Timer

When `/timer` confirms the scheduled prompt, it returns a job ID. Pass that ID to cancel:

```
/timer 1hr do something
# → Scheduled for 3:45 PM. Job ID: abc-123

# To cancel:
CronDelete abc-123
```
