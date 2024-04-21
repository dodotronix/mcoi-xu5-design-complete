#
# This file is the mcoiapp recipe.
#

SUMMARY = "Simple mcoiapp application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://Makefile \
    file://mcoicore.c \
    file://mcoipycore \
    file://mcoiapp \
    file://mcoi_xu5_devkit_ch1_ch2_120mhz_low_jitter_on_1ch_25mhz_ref_lvds_clk_source1_in5_in6_from_pcb_rev1.h \
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

# RDEPENDS_${PN} += "mcoiapp"
# RDEPENDS_${PN} += "python3 pytho3-setuptools python3-native python3-core"

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
    install -m 0755 ${S}/mcoipycore ${D}${bindir}/
    install -d ${D}${sysconfdir}/mcoi_config
    install -m 0755 ${S}/mcoi_xu5_devkit_ch1_ch2_120mhz_low_jitter_on_1ch_25mhz_ref_lvds_clk_source1_in5_in6_from_pcb_rev1.h ${D}${sysconfdir}/mcoi_config/
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/mcoiapp.service ${D}${systemd_system_unitdir}

}

FILES:${PN} += "${@bb.utils.contains('DISTRO_FEATURES','sysvinit','${sysconfdir}/*', '', d)}"

