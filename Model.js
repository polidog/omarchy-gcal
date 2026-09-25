// Pure helpers for `gcal --json list` output. Test: node test.js

function startOf(e) { return new Date(e.start.dateTime || e.start.date + "T00:00:00") }
function endOf(e) { return new Date(e.end.dateTime || e.end.date + "T00:00:00") }
function isAllDay(e) { return !e.start.dateTime }

function pad(n) { return (n < 10 ? "0" : "") + n }
function hm(d) { return pad(d.getHours()) + ":" + pad(d.getMinutes()) }

function parse(text) {
  var list = JSON.parse(text)
  return list.slice().sort(function(a, b) { return startOf(a) - startOf(b) })
}

// First timed event that hasn't ended yet (ongoing counts).
function nextEvent(events, now) {
  for (var i = 0; i < events.length; i++) {
    var e = events[i]
    if (!isAllDay(e) && endOf(e) > now) return e
  }
  return null
}

function barText(e, now, maxLen) {
  if (!e) return ""
  var title = e.summary || "(無題)"
  if (title.length > maxLen) title = title.substring(0, maxLen - 1) + "…"
  var s = startOf(e)
  if (s <= now) return "now " + title
  var sameDay = s.toDateString() === now.toDateString()
  return (sameDay ? "" : (s.getMonth() + 1) + "/" + s.getDate() + " ") + hm(s) + " " + title
}

var WEEK = ["日", "月", "火", "水", "木", "金", "土"]

function toRow(e, now) {
  var s = startOf(e)
  return {
    time: isAllDay(e) ? "終日" : hm(s) + "–" + hm(endOf(e)),
    title: e.summary || "(無題)",
    link: e.hangoutLink || e.htmlLink || "",
    account: e.account || "",
    ongoing: !isAllDay(e) && s <= now && endOf(e) > now
  }
}

// [{label, events:[row]}], ended events dropped.
function groupByDay(events, now) {
  var groups = []
  var byKey = {}
  for (var i = 0; i < events.length; i++) {
    var e = events[i]
    if (endOf(e) <= now) continue
    var s = startOf(e)
    var d = s < now ? now : s
    var key = d.toDateString()
    if (!byKey[key]) {
      byKey[key] = { label: (d.getMonth() + 1) + "/" + d.getDate() + " (" + WEEK[d.getDay()] + ")", events: [] }
      groups.push(byKey[key])
    }
    byKey[key].events.push(toRow(e, now))
  }
  return groups
}

if (typeof module !== "undefined")
  module.exports = { parse: parse, nextEvent: nextEvent, barText: barText, groupByDay: groupByDay }
