# Google Calendar — an Omarchy bar widget

Your next Google Calendar event in the Omarchy bar. Click it for everything coming up.

[日本語](README.ja.md)

- The bar shows the next timed event that hasn't ended: `13:00 Standup`, `now Standup` while it runs, `9/26 08:30 …` when it is on a later day
- The panel lists upcoming events grouped by day, all-day ones included; the one running now is highlighted
- Clicking an event opens its Google Meet link if it has one, otherwise the event in Google Calendar
- Every account registered in `gcal` is merged into one list

## Requirements

[gcal](https://github.com/polidog/gcal) 0.2.0 or later, logged in (`gcal init`, `gcal login`).
The widget looks for it on `PATH`, `~/.cargo/bin` and `~/.local/bin`.

## Install

```bash
omarchy plugin add https://github.com/polidog/omarchy-gcal.git --enable
```

Plugins run unsandboxed inside `omarchy-shell`, so read the code first — it is one QML file and one JS file.

## Settings

| Key | Default | What it does |
|-----|---------|--------------|
| `days` | `7` | How many days ahead the panel lists. |
| `refreshMinutes` | `5` | How often `gcal list` runs. |

## Keys

Left-click opens the panel · right-click refreshes · `r` refresh · `Esc` close.

## Development

```bash
TZ=Asia/Tokyo node test.js
```

MIT.
