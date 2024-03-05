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
set OS freertos10_xilinx
set NAME mcoi_app
set PLATFORM mcoi_platform
set DOMAIN mcoi_domain 

# check if Vivado exported hardware description (xsa) exists
if ![file exists $XSA] {
  puts "### no xsa file exists!"
  exit 0
} 

# Remove old and Set the new build directory
file delete -force build 
setws build 

repo -set $SCRIPT_FOLDER/embeddedsw
# puts [repo -get]

platform create -name $PLATFORM \
    -hw $XSA \
    -proc $PROC \
    -arch $ARCH \
    -os $OS \
    -fsbl-target $PROC
platform active $PLATFORM

domain create -name $DOMAIN \
    -display-name $DOMAIN \
    -proc $PROC \
    -arch $ARCH \
    -os $OS
domain active $DOMAIN

bsp setlib -name lwip213

bsp config api_mode SOCKET_API 
bsp config dhcp_does_arp_check true
bsp config lwip_dhcp true
bsp write

platform generate 

app create -name $NAME \
    -platform $PLATFORM \
    -domain $DOMAIN \
    -proc $PROC \
    -os $OS \
    -template "Empty Application(C)"
    # -template "FreeRTOS lwIP Echo Server" 
    # -template "FreeRTOS Hello World"

app config -name $NAME -add include-path $INCLUDE_PATH
importsources -name $NAME -path $SOURCE_PATH -soft-link 
app build -name mcoi_app

puts [platform report]
puts [bsp getlibs]
puts [bsp getos]
puts [bsp getdrivers]
# puts [bsp listparams -lib lwip213]
