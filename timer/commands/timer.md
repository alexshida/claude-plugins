---
name: timer
description: Delay a prompt by a given duration before submitting it
argument-hint: "<duration> <prompt>"
allowed-tools:
  - Bash
  - CronCreate
---

# Timer Command

Schedule a prompt to be submitted after a delay.

## Usage

```
/timer <duration> <prompt>
```

**Duration formats:**
- `30s` — 30 seconds (rounded to nearest minute, minimum 1 minute)
- `15m` or `15min` — 15 minutes
- `2h` or `2hr` or `2hrs` — 2 hours
- `1h30m` — 1 hour 30 minutes
- `1d` — 1 day
- `1d6h` — 1 day and 6 hours

**Examples:**
```
/timer 1hr write a summary of today's work
/timer 30m check if the build is passing
/timer 2h30m run the full test suite
/timer 1d remind me to review the PR
```

## Execution Steps

### 1. Parse ARGUMENTS

Split ARGUMENTS into `<duration>` (first token) and `<prompt>` (everything after).

### 2. Compute target time

Run the following bash command to compute the target minute, hour, day-of-month, and month in local time:

```bash
node -e "
const arg = process.argv[1];
const match = arg.match(/^(?:(\d+)d)?(?:(\d+)h(?:rs?)?)?(?:(\d+)m(?:in)?)?(?:(\d+)s)?$/i);
if (!match) { console.error('Invalid duration: ' + arg); process.exit(1); }
const days    = parseInt(match[1] || 0);
const hours   = parseInt(match[2] || 0);
const minutes = parseInt(match[3] || 0);
const secs    = parseInt(match[4] || 0);
const totalMs = ((days * 24 + hours) * 60 + minutes) * 60000 + secs * 1000;
if (totalMs < 60000) { console.error('Minimum delay is 1 minute'); process.exit(1); }
const target = new Date(Date.now() + totalMs);
const M   = target.getMinutes();
const H   = target.getHours();
const DoM = target.getDate();
const Mon = target.getMonth() + 1;
console.log(M + ' ' + H + ' ' + DoM + ' ' + Mon + ' *');
" "<duration>"
```

Replace `<duration>` with the parsed duration token.

If the command fails (invalid format), show the user a clear error message and stop.

### 3. Schedule with CronCreate

Call CronCreate with:
- `cron`: the 5-field expression from step 2
- `prompt`: the `<prompt>` text parsed from ARGUMENTS
- `recurring`: `false`

### 4. Confirm to the user

Tell the user the prompt has been scheduled and when it will fire (human-readable local time). Include the job ID in case they want to cancel it with `/cron-cancel`.
