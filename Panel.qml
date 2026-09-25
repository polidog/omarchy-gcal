import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import "Model.js" as Model

Panel {
  id: root
  moduleName: "io.github.polidog.gcal"
  ipcTarget: "io.github.polidog.gcal"

  readonly property int days: Math.max(1, setting("days", 7))
  readonly property int refreshMs: Math.max(1, setting("refreshMinutes", 5)) * 60000

  property var events: []
  property string error: ""
  property date now: new Date()

  readonly property var next: Model.nextEvent(events, now)
  readonly property var groups: Model.groupByDay(events, now)

  function refresh() {
    if (!fetchProc.running) fetchProc.running = true
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onCompleted: refresh()
  onOpenedChanged: if (opened) refresh()

  Timer {
    interval: root.refreshMs
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  // Keeps "now" / ended-event filtering current between fetches.
  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }

  Process {
    id: fetchProc
    // The shell's PATH usually lacks ~/.cargo/bin, where `cargo install` puts gcal.
    command: ["sh", "-c", "PATH=\"$HOME/.cargo/bin:$HOME/.local/bin:$PATH\" exec gcal list --json -d \"$1\"", "sh", String(root.days)]
    stdout: StdioCollector { id: out; waitForEnd: true }
    stderr: StdioCollector { id: err; waitForEnd: true }
    onExited: function(code) {
      root.now = new Date()
      if (code !== 0) {
        root.error = String(err.text || "").trim() || ("gcal exited with " + code)
        return
      }
      try {
        root.events = Model.parse(String(out.text || "[]"))
        root.error = ""
      } catch (e) {
        root.error = "gcal の出力を読めませんでした: " + e
      }
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰃰" + (root.next ? " " + Model.barText(root.next, root.now, 20) : "")
    tooltipText: root.error
    active: root.error !== ""
    onPressed: function(b) {
      if (b === Qt.RightButton) root.refresh()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panelColumn.implicitHeight, Style.space(560))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) { if (t === "r") root.refresh() }

      ScrollView {
        id: scrollArea
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
          id: panelColumn
          width: scrollArea.availableWidth
          spacing: Style.space(10)

          Text {
            text: "Google Calendar"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.title
            font.bold: true
          }

          Text {
            visible: root.error !== "" || root.groups.length === 0
            width: parent.width
            wrapMode: Text.WordWrap
            text: root.error !== "" ? root.error : (fetchProc.running ? "読み込み中…" : root.days + " 日以内の予定はありません")
            color: root.error !== "" ? root.bar.urgent : Qt.darker(root.bar.foreground, 1.4)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.body
          }

          Repeater {
            model: root.groups

            delegate: Column {
              id: group
              required property var modelData
              width: panelColumn.width
              spacing: Style.space(4)

              PanelSeparator { foreground: root.bar.foreground }

              Text {
                text: group.modelData.label
                color: Qt.darker(root.bar.foreground, 1.4)
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.2
              }

              Repeater {
                model: group.modelData.events

                delegate: CursorSurface {
                  id: row
                  required property var modelData
                  width: group.width
                  implicitHeight: rowText.implicitHeight + Style.spacing.md
                  hasCursor: rowMouse.containsMouse
                  foreground: root.bar.foreground
                  fill: Style.hoverFillFor(root.bar.foreground, Color.accent)

                  Row {
                    id: rowText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Style.space(8)
                    anchors.rightMargin: Style.space(8)
                    spacing: Style.space(10)

                    Text {
                      id: timeText
                      text: row.modelData.time
                      width: Style.space(90)
                      color: row.modelData.ongoing ? Color.accent : Qt.darker(root.bar.foreground, 1.4)
                      font.family: root.bar.fontFamily
                      font.pixelSize: Style.font.body
                    }

                    Text {
                      text: row.modelData.title
                      width: rowText.width - timeText.width - rowText.spacing
                      elide: Text.ElideRight
                      color: row.modelData.ongoing ? Color.accent : root.bar.foreground
                      font.family: root.bar.fontFamily
                      font.pixelSize: Style.font.body
                      font.bold: row.modelData.ongoing
                    }
                  }

                  MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: row.modelData.link ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: if (row.modelData.link) { Qt.openUrlExternally(row.modelData.link); root.close() }
                  }
                }
              }
            }
          }

          Text {
            width: parent.width
            text: "クリックで Meet / Google Calendar を開く · r 再読み込み"
            color: Qt.darker(root.bar.foreground, 1.6)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            horizontalAlignment: Text.AlignHCenter
          }
        }
      }
    }
  }
}
