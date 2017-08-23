#ifndef __GLOBAL_H
#define __GLOBAL_H

#include <modplug.h>
#include <ao.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

#define VERSION "1.8"
#define BUF_SIZE 4096

extern int cursong;
extern NSMutableArray *songs;
extern ModPlug_Settings settings;

#endif
