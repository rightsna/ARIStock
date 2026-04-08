import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var launchedHeadless: Bool {
    ProcessInfo.processInfo.arguments.contains("--headless")
  }

  private var shouldRevealOnActivate = false
  private var switchedToForegroundMode = false

  private func revealMainWindow() {
    guard let window = NSApp.windows.first else { return }

    NSApp.unhide(nil)
    window.alphaValue = 1
    window.ignoresMouseEvents = false
    window.center()
    window.orderFrontRegardless()
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
    shouldRevealOnActivate = false
    switchedToForegroundMode = true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)

    guard launchedHeadless else { return }

    NSApp.windows.forEach { window in
      window.alphaValue = 0
      window.ignoresMouseEvents = true
      window.orderOut(nil)
    }
    shouldRevealOnActivate = true
  }

  override func applicationDidBecomeActive(_ notification: Notification) {
    super.applicationDidBecomeActive(notification)

    guard launchedHeadless, shouldRevealOnActivate else { return }
    revealMainWindow()
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
    guard launchedHeadless else { return true }

    shouldRevealOnActivate = true
    revealMainWindow()
    return true
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return !launchedHeadless || switchedToForegroundMode
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
