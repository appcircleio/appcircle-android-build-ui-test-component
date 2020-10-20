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
    status = nil
    stdout_str = nil
    stderr_str = nil

    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdout.each_line do |line|
            puts line
        end
        stdout_str = stdout.read
        stderr_str = stderr.read
        status = wait_thr.value
    end

    unless status.success?
        puts stderr_str
        raise stderr_str
    end
    return stdout_str
end

gradlew_folder_path = ""
if Pathname.new("#{ac_project_path}").absolute?
    gradlew_folder_path = ac_project_path
else
    gradlew_folder_path = File.expand_path(File.join(ac_repo_path, ac_project_path))
end

build_output_folder = File.join(gradlew_folder_path,"#{ac_module}/build/outputs/apk/androidTest")

command = "cd #{gradlew_folder_path} && chmod +x ./gradlew && ./gradlew clean #{ac_module}:assembleDebug #{ac_module}:assembleAndroidTest"
run_command(command)

puts "Filtering artifacts: #{build_output_folder}/**/*.apk"

apks = Dir.glob("#{build_output_folder}/**/*.apk")
FileUtils.cp apks, "#{ac_output_folder}"
apks = Dir.glob("#{ac_output_folder}/**/*.apk").join("|")

puts "Exporting AC_TEST_APK_PATH=#{apks}"

open(ENV['AC_ENV_FILE_PATH'], 'a') { |f|
    f.puts "AC_TEST_APK_PATH=#{apks}"
}

exit 0
