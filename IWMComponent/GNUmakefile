
#
#  $Id: GNUmakefile,v 1.3 2003/12/12 04:33:28 copal Exp $
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

include $(GNUSTEP_MAKEFILES)/common.make

GNUSTEP_INSTALLATION_DIR=		$(GNUSTEP_USER_ROOT)
# PACKAGE_NAME=				interfacewm
# LIBRARY_VAR=				INTERFACEWM

LIBRARY_NAME=				libIWMComponent

${LIBRARY_NAME}_HEADER_FILES_INSTALL_DIR=	InterfaceWM
${LIBRARY_NAME}_HEADER_FILES_DIR=	.

ADDITIONAL_INCLUDE_DIRS+=		-I..

srcdir=					.

${LIBRARY_NAME}_HEADER_FILES=		IWMNotifications.h \
					IWMComponent.h \
					IWMComponentManager.h

${LIBRARY_NAME}_OBJC_FILES=		IWMNotifications.m \
					IWMComponent.m \
					IWMComponentManager.m

-include ../GNUmakefile.preamble
-include ../GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/library.make

-include GNUmakefile.postamble

