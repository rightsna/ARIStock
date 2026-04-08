import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let launchedHeadless = ProcessInfo.processInfo.arguments.contains("--headless")
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    if launchedHeadless {
      alphaValue = 0
      ignoresMouseEvents = true
      orderOut(nil)
    }

    super.awakeFromNib()
  }
}
