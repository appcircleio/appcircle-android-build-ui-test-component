# Android Build for UI Testing

Builds your Test applications with gradlew. Runs `./gradlew clean ${module}:assembleAndroidTest`.

Required Input Variables
- `$AC_REPOSITORY_DIR`: Cloned git repository path
- `$AC_MODULE`: Project module to be built

Optional Input Variables
- `$AC_PROJECT_PATH`: Specifies the project path

Output Variables
- `$AC_APK_PATH`: Path for the generated .apk file
- `$AC_TEST_APK_PATH`: Path for the generated *androidTest.apk file