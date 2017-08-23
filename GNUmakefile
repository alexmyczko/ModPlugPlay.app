include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = ModPlugPlay
ADDITIONAL_LDFLAGS += -lmodplug -lao
ADDITIONAL_OBJCFLAGS += -I/usr/include/libmodplug -I/usr/include/ao
ModPlugPlay_HEADERS = 
ModPlugPlay_OBJC_FILES = main.m Controller.m
ModPlugPlay_RESOURCE_FILES = ModPlugPlayInfo.plist ModPlugPlay.gorm Settings.gorm ModPlugPlay.tiff
ModPlugPlay_MAIN_MODEL_FILE = ModPlugPlay.gorm

include $(GNUSTEP_MAKEFILES)/application.make
