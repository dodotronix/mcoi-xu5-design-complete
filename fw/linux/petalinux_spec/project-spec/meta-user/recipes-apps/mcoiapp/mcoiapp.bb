#
# This file is the mcoiapp recipe.
#

SUMMARY = "Simple mcoiapp application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://Makefile \
    file://mcoicore.c \
    file://mcoiapp \
    file://mcoiapp.service \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

S = "${WORKDIR}"

inherit update-rc.d systemd
INITSCRIPT_NAME = "mcoiapp"
INITSCRIPT_PARAMS = "start 99 S ."

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "mcoiapp.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_compile() {
    oe_runmake
}

do_install() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${S}/mcoiapp ${D}${sysconfdir}/init.d/
    fi

    install -d ${D}${bindir}
    install -m 0755 ${S}/mcoiapp ${D}${bindir}/
    install -m 0755 ${S}/mcoicore ${D}${bindir}/
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/mcoiapp.service ${D}${systemd_system_unitdir}

}

FILES:${PN} += "${@bb.utils.contains('DISTRO_FEATURES','sysvinit','${sysconfdir}/*', '', d)}"
