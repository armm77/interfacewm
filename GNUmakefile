
#
#  $Id: GNUmakefile,v 1.13 2003/12/12 04:34:03 copal Exp $
#
#  This file is part of Interface WM.
#
#  Copyright (C) 2002, Ian Mondragon
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#  
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#  
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

############################################################################

include $(GNUSTEP_MAKEFILES)/common.make

GNUSTEP_INSTALLATION_DIR=	$(GNUSTEP_USER_ROOT)

SUBPROJECTS=			IWMExtensions IWMGraphics IWMComponent

PACKAGE_NAME=			interfacewm
TOOL_NAME=      		$(PACKAGE_NAME)

ADDITIONAL_INCLUDE_DIRS+=	-IIWMExtensions -IIWMGraphics -IIWMComponent
ADDITIONAL_LDFLAGS+=		-lIWMExtensions -lIWMGraphics -lIWMComponent

# header files
$(TOOL_NAME)_HEADER_FILES=	IWMCoreUtilities.h \
				IWMClient.h \
				IWMDebug.h \
				IWMTheme.h \
				IWMScreen.h \
				IWMWindow.h \
				IWMTitlebar.h \
				IWMResizebar.h \
				IWMIcon.h \
				IWMWindowManager.h \
				InterfaceWM.h

# objective-c files
$(TOOL_NAME)_OBJC_FILES=	IWMCoreUtilities.m \
				IWMClient.m \
				IWMDebug.m \
				IWMTheme.m \
				IWMScreen.m \
				IWMWindow.m \
				IWMTitlebar.m \
				IWMResizebar.m \
				IWMIcon.m \
				IWMWindowManager.m \
				IWMWindowManager+Event.m \
				IWMWindowManager+Notification.m \
				IWMController.m


-include GNUmakefile.preamble
-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/tool.make

-include GNUmakefile.postamble
