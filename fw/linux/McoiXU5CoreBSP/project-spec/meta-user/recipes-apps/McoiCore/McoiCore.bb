#
# This file is the McoiCore recipe.
#

SUMMARY = "Simple McoiCore application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://McoiCore \
	"

S = "${WORKDIR}"

do_install() {
	     install -d ${D}/${bindir}
	     install -m 0755 ${S}/McoiCore ${D}/${bindir}
}
