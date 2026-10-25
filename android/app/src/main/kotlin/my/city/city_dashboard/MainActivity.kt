package my.city.city_dashboard

import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "my.city.dashboard/device")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "launch" -> {
                            val pkg = when (call.argument<String>("app")) {
                                "maps" -> "com.google.android.apps.maps"
                                "waze" -> "com.waze"
                                "spotify" -> "com.spotify.music"
                                else -> null
                            }
                            val intent = pkg?.let { packageManager.getLaunchIntentForPackage(it) }
                            if (intent == null) result.success(false)
                            else { startActivity(intent); result.success(true) }
                        }
                        "settings" -> {
                            val action = when (call.argument<String>("page")) {
                                "wifi" -> Settings.ACTION_WIFI_SETTINGS
                                "bluetooth" -> Settings.ACTION_BLUETOOTH_SETTINGS
                                else -> Settings.ACTION_SETTINGS
                            }
                            startActivity(Intent(action))
                            result.success(true)
                        }
                        else -> result.notImplemented()
                    }
                } catch (_: ActivityNotFoundException) {
                    result.success(false)
                } catch (_: SecurityException) {
                    result.error("UNAVAILABLE", "This device restricts that action", null)
                }
            }
    }
}
