require 'yaml'
require 'open3'
require 'fileutils'
require 'pathname'

def get_env_variable(key)
	return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

ac_module = get_env_variable("AC_MODULE") || abort('Missing module.')
ac_repo_path = get_env_variable("AC_REPOSITORY_DIR") || abort('Missing repo path.')
ac_output_folder = get_env_variable("AC_OUTPUT_DIR") || abort('Missing output folder.')
ac_project_path = get_env_variable("AC_PROJECT_PATH") || "."

def capitalize_first_char(str) 
    str[0] = str[0].capitalize
    return str
end

def run_command(command)
    puts "@@[command] #{command}"
    unless system(command)
      exit $?.exitstatus
    end
end

gradlew_folder_path = ""
if Pathname.new("#{ac_project_path}").absolute?
    gradlew_folder_path = ac_project_path
else
    gradlew_folder_path = File.expand_path(File.join(ac_repo_path, ac_project_path))
end

build_output_folder = File.join(gradlew_folder_path,"#{ac_module}/build/outputs/apk")

command = "cd #{gradlew_folder_path} && chmod +x ./gradlew && ./gradlew clean #{ac_module}:assembleDebug #{ac_module}:assembleAndroidTest"
run_command(command)

puts "Filtering artifacts: #{build_output_folder}/androidTest/**/*.apk"
puts "Filtering artifacts: #{build_output_folder}/**/debug/**/*.apk"

test_apks = Dir.glob("#{build_output_folder}/androidTest/**/*.apk")
apks = Dir.glob("#{build_output_folder}/**/debug/**/*.apk")

FileUtils.cp apks, "#{ac_output_folder}"
apks = Dir.glob("#{ac_output_folder}/**/*.apk").join("|")

FileUtils.cp test_apks, "#{ac_output_folder}"
test_apks = Dir.glob("#{ac_output_folder}/**/*androidTest.apk").join("|")

puts "Exporting AC_TEST_APK_PATH=#{test_apks}"
puts "Exporting AC_APK_PATH=#{apks}"

open(ENV['AC_ENV_FILE_PATH'], 'a') { |f|
    f.puts "AC_APK_PATH=#{apks}"
    f.puts "AC_TEST_APK_PATH=#{test_apks}"
}

exit 0
