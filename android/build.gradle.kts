import com.android.build.api.dsl.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// flutter_webrtc pins compileSdkVersion 31, but its AndroidX dependencies
// require compileSdk >= 34. Force library plugin modules to >= 34.
subprojects {
    fun raiseCompileSdk() {
        if (pluginManager.hasPlugin("com.android.library")) {
            extensions.configure<LibraryExtension>("android") {
                if (compileSdk != null && compileSdk!! < 34) {
                    compileSdk = 34
                }
            }
        }
    }
    if (state.executed) {
        raiseCompileSdk()
    } else {
        afterEvaluate { raiseCompileSdk() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
