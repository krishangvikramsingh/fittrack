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

// Some third-party plugins (e.g. flutter_timezone) declare their Java and
// Kotlin compile targets inconsistently for their Android module (Java via
// the plain `java {}` block, which AGP ignores for library modules, so it
// silently falls back to a newer default than the Kotlin side declares).
// Newer AGP/Kotlin Gradle Plugin versions treat that mismatch as a hard
// build error. Rather than patch each plugin's cached source, force every
// subproject's Java and Kotlin compile tasks to the same target the app
// itself uses (see app/build.gradle.kts).
subprojects {
    // Skip :app - it sets its own compileOptions directly in
    // app/build.gradle.kts, and by this point in the build AGP has already
    // finalized that property, so touching it again here throws
    // "sourceCompatibility has been finalized". `afterEvaluate` (rather than
    // `plugins.withId`) is needed for the other, plugin library modules
    // because several of them (e.g. pedometer) set their own compileOptions
    // later in their own build script than the point a plugin-applied
    // callback would fire, which would otherwise silently overwrite ours.
    if (path == ":app") return@subprojects
    afterEvaluate {
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
