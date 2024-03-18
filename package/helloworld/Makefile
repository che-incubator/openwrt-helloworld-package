include $(TOPDIR)/rules.mk

# This is the name, version and release of the program. It is used to create the package name.
PKG_NAME:=helloworld
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION).$(PKG_RELEASE)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_MAINTAINER:=Oleksii Orel <oorel@redhat.com>
PKG_LICENSE:=EPL-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

# This is the package section. It specifies the package details.
define Package/$(PKG_NAME)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=helloworld printing program in C++
  DEPENDS:= +libc +libstdcpp
endef

# This is the build section. It specifies the package details.
define Package/helloworldcxx/description
 It is a helloworld.
endef

# Specify what needs to be done to prepare for building the package.
# The default uses the PKG_SOURCE_URL and the PKG_SOURCE to download the source from the web.
# In our case, we need to copy the source files to the build directory. This is done
# by creating a Build/Prepare directive. The first line creates the build directory
# if it does not already exist. The second line copies all the files from the src
# directory to the build directory. The $(CP) command is a built-in command that
# copies files.  The $(PKG_BUILD_DIR) variable contains the path to the build directory.
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

# Specify what needs to be done to configure the program. In our case, we don't
# need to do anything, so this directive is empty.
define Build/Configure
endef

# Specify what needs to be done to compile the program. In our case, we need to
# call the make command to compile the program. The $(MAKE) variable contains the
# command to run the make program. The -C option tells make to change to the
# specified directory before running. The $(PKG_BUILD_DIR) variable contains the
# path to the build directory. The $(TARGET_CONFIGURE_OPTS) variable contains
# options that need to be passed to the make program.
define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)
endef

# Specify where and how to install the program. Since we only have one file,
# the helloworld executable, install it by copying it to the /bin directory on
# the router. The $(1) variable represents the root directory on the router running
# OpenWrt. The $(INSTALL_DIR) variable contains a command to prepare the install
# directory if it does not already exist.  Likewise $(INSTALL_BIN) contains the
# command to copy the binary file from its current location (in our case the build
# directory) to the install directory.
define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/helloworldpp $(1)/bin/
endef

# This line executes the necessary commands to compile our program.
# The above define directives specify all the information needed, but this
# line calls BuildPackage which in turn actually uses this information to
# build a package.
$(eval $(call BuildPackage,$(PKG_NAME)))
