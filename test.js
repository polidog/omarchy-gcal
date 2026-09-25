const assert = require("assert")
const M = require("./Model.js")
const ev = (summary, s, e) => ({ summary, start: { dateTime: s, date: null }, end: { dateTime: e, date: null }, htmlLink: "x", account: "a" })
const allDay = { summary: "休み", start: { dateTime: null, date: "2026-09-25" }, end: { dateTime: null, date: "2026-09-26" } }
const events = M.parse(JSON.stringify([
  ev("後", "2026-09-26T10:00:00+09:00", "2026-09-26T11:00:00+09:00"),
  ev("過去", "2026-09-25T08:00:00+09:00", "2026-09-25T09:00:00+09:00"),
  allDay,
  ev("会議", "2026-09-25T13:00:00+09:00", "2026-09-25T14:00:00+09:00"),
]))
const now = new Date("2026-09-25T12:00:00+09:00")
assert.strictEqual(M.nextEvent(events, now).summary, "会議")
assert.strictEqual(M.barText(M.nextEvent(events, now), now, 20), "13:00 会議")
assert.strictEqual(M.barText(M.nextEvent(events, new Date("2026-09-25T13:30:00+09:00")), new Date("2026-09-25T13:30:00+09:00"), 20), "now 会議")
assert.strictEqual(M.barText(events[3], now, 20), "9/26 10:00 後")
assert.strictEqual(M.barText(ev("abcdefghij", "2026-09-25T13:00:00+09:00", "2026-09-25T14:00:00+09:00"), now, 5), "13:00 abcd…")
const g = M.groupByDay(events, now)
assert.deepStrictEqual(g.map(x => x.events.map(e => e.title)), [["休み", "会議"], ["後"]])
assert.strictEqual(g[0].label, "9/25 (金)")
assert.strictEqual(M.nextEvent([], now), null)

const meet = Object.assign(ev("MTG", "2026-09-25T15:00:00+09:00", "2026-09-25T16:00:00+09:00"), { hangoutLink: "https://meet.google.com/abc" })
assert.strictEqual(M.groupByDay([meet], now)[0].events[0].link, "https://meet.google.com/abc")
assert.strictEqual(M.groupByDay(events, now)[0].events[1].link, "x")
console.log("ok")
