# all paths have to be in the absolute path form 
# otherwise the soft links won't be found
set SCRIPT_PATH [file normalize [info script]]
set SCRIPT_FOLDER [file dirname $SCRIPT_PATH]

set SOURCE_PATH  $SCRIPT_FOLDER/../src
set INCLUDE_PATH $SCRIPT_FOLDER/../inc 
set HWDIR $SCRIPT_FOLDER/../../syn/
puts $HWDIR 

set XSA [glob $HWDIR*.xsa]
set PROC psu_cortexa53_0
set ARCH 64-bit
set OS standalone
set NAME mcoi_app
set PLATFORM mcoi_platform

# check if Vivado exported hardware description (xsa) exists
if ![file exists $XSA] {
  puts "### no xsa file exists!"
  exit 0
} 

# Remove old and Set the new build directory
file delete -force build 
setws build 

# platform create -name $PLATFORM \
#     -hw $XSA \
#     -arch $ARCH \
#     -fsbl-target $PROC

# domain create -name {standalone_psu_cortexa53_0} \
#     -display-name {standalone_psu_cortexa53_0} \
#     -os {standalone} \
#     -proc $PROC \
#     -runtime {cpp} \
#     -arch $ARCH \
#     -support-app {empty_application}

# platform active $PLATFORM
# domain active {standalone_psu_cortexa53_0}

# app create -name $NAME \
#     -platform $PLATFORM \
#     -domain {standalone_psu_cortexa53_0} \
#     -template "Empty Application(C)"

app create -name $NAME \
    -hw $XSA \
    -proc $PROC \
    -os $OS \
    -template "Empty Application(C)"

app config -name $NAME -add include-path $INCLUDE_PATH
importsources -name $NAME -path $SOURCE_PATH -soft-link 

platform generate 
app build -name mcoi_app
