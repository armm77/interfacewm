
#
# GNUmakfile for IWMExtensions library
#

include $(GNUSTEP_MAKEFILES)/common.make

GNUSTEP_INSTALLATION_DIR=		$(GNUSTEP_USER_ROOT)
PACKAGE_NAME=				interfacewm
LIBRARY_NAME=				libIWMExtensions

${LIBRARY_NAME}_HEADER_FILES_INSTALL_DIR=	InterfaceWM
${LIBRARY_NAME}_HEADER_FILES_DIR=	.

ADDITIONAL_INCLUDE_DIRS+=		-I..

srcdir=					.

${LIBRARY_NAME}_HEADER_FILES=		NSArrayExt.h		\
					NSDictionaryExt.h

${LIBRARY_NAME}_OBJC_FILES=		NSArrayExt.m		\
					NSDictionaryExt.m

-include ../GNUmakefile.preamble
-include ../GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/library.make

-include GNUmakefile.postamble

