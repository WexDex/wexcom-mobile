plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.wexcom.wexcom_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.wexcom.wexcom_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

fun releaseApkFileName(originalName: String, variantName: String): String {
  val abi = Regex("""^app-(.+)-release\.apk$""")
    .matchEntire(originalName)
    ?.groupValues
    ?.getOrNull(1)
  return when {
    abi != null -> "WexCom-$abi.apk"
    variantName == "release" -> "WexCom.apk"
    else -> "WexCom-$variantName.apk"
  }
}

// Release-only: renaming/deleting APKs breaks `flutter run` (expects app-debug.apk).
androidComponents {
    onVariants(selector().withBuildType("release")) { variant ->
        val capitalizedName = variant.name.replaceFirstChar { it.uppercase() }
        val renameTask = tasks.register("renameApk$capitalizedName") {
            doLast {
                val outputDirs = listOf(
                    layout.buildDirectory.dir("outputs/flutter-apk").get().asFile,
                    layout.buildDirectory.dir("outputs/apk/${variant.name}").get().asFile,
                )
                outputDirs.forEach { dir ->
                    if (!dir.exists()) return@forEach
                    dir.listFiles()
                        ?.filter { it.isFile && it.extension == "apk" }
                        ?.forEach { apk ->
                            val newName = releaseApkFileName(apk.name, variant.name)
                            val dest = dir.resolve(newName)
                            if (apk.absolutePath != dest.absolutePath) {
                                apk.copyTo(dest, overwrite = true)
                                apk.delete()
                            }
                        }
                }
            }
        }
        afterEvaluate {
            tasks.named("assemble$capitalizedName").configure {
                finalizedBy(renameTask)
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
