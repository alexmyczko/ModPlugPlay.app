#include <stdio.h>

#include <AppKit/NSApplication.h>
#include <Foundation/Foundation.h>

#include "global.h"

NSMutableArray *songs = nil;
int cursong = 0;
ModPlug_Settings settings;

void usage(void) {
  printf("Copyright (C) 2003, 2004, 2017 Alex Myczko and Thomas Steinacher\n");
  printf("Version %s compiled on %s at %s.\n", VERSION, __DATE__, __TIME__);
  printf("\n");
  printf("too few arguments\n");
  printf("Usage: ModPlugPlay" /*[OPTIONS] */ " [FILES]\n");
  printf("\n");
}

// int main(int argc, const char *argv[]) {
int main(int argc, const char **argv) {
  int i = 1;

  if (argc <= 1) {
    usage();
    exit(1);
  }

  /* init the songs array */
  songs = [[NSMutableArray alloc] initWithCapacity:argc-1];

  /* add the songs to the array */
  while (i < argc)
    [songs addObject:[[NSString alloc] initWithCString:argv[i++]]];

  ModPlug_GetSettings(&settings);

  return NSApplicationMain (argc, argv);
}
