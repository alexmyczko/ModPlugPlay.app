/* All Rights reserved */

#include <AppKit/AppKit.h>
#include <AppKit/NSButton.h>
#include "global.h"
#include "Controller.h"

void checksongnumber(void)
{
    if (cursong < 0)
	cursong = [songs count]-1;

    if (cursong >= [songs count])
	cursong = 0;
	/* cursong = [songs count]-1; */

    NSLog(@"%d/%d\n",1+cursong,[songs count]);
}

int get_byteorder(void)
/* 0 LE little endian (intel)
   1 BE big endian (sparc, powerpc, motorola)
   2 unknown
*/
{
    int ival;
#define sz sizeof(ival)
    char s[sz];
    char t[sz];
    int i, lit, big;

    for (i=0; i<sz; i++) s[i] = i;
    ival = *(int *)s;
    big = lit = 0;
    for (i=0; i<sz; i++) {
        char c = ival&0xff;
        ival >>= 8;
        if (s[i] == c) lit++;
        if (s[sz-i-1] == c) big++;
        t[i] = c;
    }
    if (lit == sz && big == 0) {
        return 0;
    } else if (big == sz && lit == 0) {
        return 1;
    } else {
        return 2;
    }
}


@implementation Controller

- (void) nextSong: (id)sender
{
  NSString *songname;
  NSFileHandle *filehandle;
  NSData *content;
  int len;

    gettimeofday(&tvstart,NULL);
    
  if (!(isplaying && !ispause)) {
    printf("");
  } else {
    [timer invalidate];
  }

  isplaying = 0;

  cursong++;
  checksongnumber();
  songname = [songs objectAtIndex:cursong];

  filehandle = [NSFileHandle fileHandleForReadingAtPath:songname];
  if (!filehandle) {
    [self nextSong:nil];
    return;
  }

  content = [filehandle readDataToEndOfFile];

  [filehandle closeFile];
 
    if (modfile!=NULL) ModPlug_Unload(modfile);
  modfile = ModPlug_Load([content bytes], [content length]);
  if (!modfile) {
    [self nextSong:nil];

    return;
  }
  modlen=ModPlug_GetLength(modfile)/1000.0;

  [window setTitle:[songname lastPathComponent]];
  [fileLabel setStringValue:[NSString stringWithCString:ModPlug_GetName(modfile)]]; 

  mlen = ModPlug_Read(modfile, audio_buffer, BUF_SIZE);
  ao_play(device, audio_buffer, mlen);
  /*if ((len = write(audio_fd, audio_buffer, mlen)) == -1) {
    perror("audio write");
    exit(1);
  }*/

  isplaying = 1;
  ispause = 0;

  timer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self \
      selector:@selector(continuePlay) userInfo:nil repeats:YES ];

  return;
}

- (void) prevSong: (id)sender
{
  NSString *songname;
  NSFileHandle *filehandle;
  NSData *content;
  int len;

    gettimeofday(&tvstart,NULL);
    
  if (!(isplaying && !ispause)) {
    printf("");
  } else {
    [timer invalidate];
  }

  isplaying = 0;

  cursong--;
  checksongnumber();
  songname = [songs objectAtIndex:cursong];

  filehandle = [NSFileHandle fileHandleForReadingAtPath:songname];
  if (!filehandle) {
    [self prevSong:nil];
    return;
  }

  content = [filehandle readDataToEndOfFile];

  [filehandle closeFile];

   if (modfile!=NULL) ModPlug_Unload(modfile); 
  modfile = ModPlug_Load([content bytes], [content length]);
  if (!modfile) {
    [self prevSong:nil];
    return;
  }
  modlen=ModPlug_GetLength(modfile)/1000.0;

  [window setTitle:[songname lastPathComponent]];
  /* [fileLabel setStringValue:[songname lastPathComponent]]; */
  [fileLabel setStringValue:[NSString stringWithCString:ModPlug_GetName(modfile)]]; 

  mlen = ModPlug_Read(modfile, audio_buffer, BUF_SIZE);
  ao_play(device, audio_buffer, mlen);
/*  if ((len = write(audio_fd, audio_buffer, mlen)) == -1) {
    perror("audio write");
    exit(1);
  }*/
  
  isplaying = 1;
  ispause = 0;

  timer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self \
      selector:@selector(continuePlay) userInfo:nil repeats:YES ];

  return;
}

- (void) awakeFromNib
{
    ao_info *default_info;
    modfile=NULL;

    gettimeofday(&tvstart,NULL);
    [window setTitle:[[songs objectAtIndex:0] lastPathComponent]];
    [progressBar setDoubleValue:0.0];
    [songPosition setStringValue:@""];
    /* [fileLabel setStringValue:[NSString stringWithCString:ModPlug_GetName(modfile)]];*/

    /* 
    integrate this into defaults db
    
    outputDriver=@"oss";
    outputFreq=44100;
    outputBits=16
    outputChannels=2; */

    ao_initialize();
    default_driver=ao_default_driver_id();
    
    aoformat.bits=16;
    aoformat.channels=2;
    aoformat.rate=44100;
    if (get_byteorder()==1) {
	aoformat.byte_format = AO_FMT_BIG;
    } else {
	aoformat.byte_format = AO_FMT_LITTLE;
    }
    device = ao_open_live(default_driver, &aoformat, NULL /* no options */);
    default_info=ao_driver_info(ao_default_driver_id());

    if (device == NULL) {
	NSRunCriticalAlertPanel(@"Error opening device", \
    	[NSString stringWithFormat:@"Could not open %s device.", default_info->short_name], \
	@"OK", nil, nil);
							
	exit(1);
    } else {
        printf("Using %s for playback\n",default_info->short_name);
    }
}

- (void) stop: (id)sender
{
    if (isplaying && !ispause) printf(""); /* close(audio_fd);*/
    if (isplaying) [timer invalidate];

    isplaying = ispause = 0;

    /* cursong = 0; */
    /* [fileLabel setStringValue:[[songs objectAtIndex:0] lastPathComponent]]; */
    gettimeofday(&tvstart,NULL);
    [progressBar setDoubleValue:0.0];
    [songPosition setStringValue:@""];
    [playPause setImage: [NSImage imageNamed: @"Resources/ModPlugPlay.gorm/gnustep-play.png"]];
}

- (void) pause: (id)sender
{
    /* are we playing a song? */
    if (!(isplaying && !ispause))
	return;

    ispause = 1;
    /*close(audio_fd);*/

    [playPause setImage: [NSImage imageNamed: @"Resources/ModPlugPlay.gorm/gnustep-pause.png"]];
}

- (void) forward: (id)sender
{
    if (isplaying) {
	if ((tv.tv_sec-tvstart.tv_sec+10) < modlen ) {
	    ModPlug_Seek(modfile,((tv.tv_sec-tvstart.tv_sec)*1000+10000) );
    	    tvstart.tv_sec-=10;
	} else {
	    [self nextSong:nil];
	}
    }
}

- (void) backward: (id)sender
{
    if (isplaying) {
	ModPlug_Seek(modfile,((tv.tv_sec-tvstart.tv_sec)*1000-10000) );
	if ((tv.tv_sec-tvstart.tv_sec-10) > 0 ) {
	    tvstart.tv_sec+=10;
	} else {
    	    gettimeofday(&tvstart,NULL);
        }
    }
}

- (void) continuePlay
{
  int len;
  gettimeofday(&tv,NULL);
  NSString *sopos=[NSString stringWithFormat:@"%0.0f/%0d\"", (float)(tv.tv_sec-tvstart.tv_sec), modlen];
  /* NSString *sopos=[NSString stringWithFormat:@"%0.1f/%0.0f\"", ((tv.tv_sec-tvstart.tv_sec)+(tv.tv_usec/100000-tvstart.tv_usec/100000)/10.0), (ModPlug_GetLength(modfile)/1000.0)]; */

  if (ispause == 0)
  {
    mlen = ModPlug_Read(modfile, audio_buffer, BUF_SIZE);
  ao_play(device, audio_buffer, mlen);
/*    if ((len = write(audio_fd, audio_buffer, mlen)) == -1) {
      perror("audio write");
      exit(1);
    }*/
    if (mlen == 0)
      [self nextSong:nil];
  }
  
  [songPosition setStringValue:sopos];
  [progressBar setDoubleValue:(435.0 / modlen * ((tv.tv_sec-tvstart.tv_sec)+(tv.tv_usec/10000-tvstart.tv_usec/10000)/100.0))];
  usleep(1);
  
  return;
}

- (void) loopUnloop: (id)sender
{
    static int lstate;
    
    lstate++;
    if (lstate & 1) {
	[loopSong setImage: [NSImage imageNamed: @"Resources/ModPlugPlay.gorm/gnustep-loop-not.png"]];
    } else {
	[loopSong setImage: [NSImage imageNamed: @"Resources/ModPlugPlay.gorm/gnustep-loop.png"]];
    }
}

- (void) play: (id)sender
{
    static int paus;
  NSFileHandle *filehandle;
  NSData *content;
  NSString *songname = [songs objectAtIndex:cursong];
  int len;
  
  paus++;

    if (ispause == 0) {
	[playPause setImage: [NSImage imageNamed: @"Resources/ModPlugPlay.gorm/gnustep-pause.png"]];
    } else {
	[playPause setImage: [NSImage imageNamed: @"Resources/ModPlugPlay.gorm/gnustep-play.png"]];
    }
    
  /* we're already playing */
  if (isplaying == 1 && ispause == 0)
    return;

    gettimeofday(&tvstart,NULL);

  if (ispause == 1) {
    ispause = 0;
    return;
  }


 filehandle = [NSFileHandle fileHandleForReadingAtPath: songname];

 if (!filehandle) {
   /* try the next song */
   cursong++;
  checksongnumber();
   [self play:nil];

   return;
 }

  content = [filehandle readDataToEndOfFile];

  [filehandle closeFile];
 
   if (modfile!=NULL) ModPlug_Unload(modfile);
    modfile = ModPlug_Load([content bytes], [content length]);
  if (!modfile) {
    /*NSRunCriticalAlertPanel(@"This is not a valid audio file", \
        [NSString stringWithFormat:@"%@", songname], @"OK", nil, nil); 
    close(audio_fd);*/

    /* try the next song */
    cursong++;
  checksongnumber();
    [self play:nil];

    return;
  }
  modlen=ModPlug_GetLength(modfile)/1000.0;

  settings.mResamplingMode = MODPLUG_RESAMPLE_FIR;  /* RESAMP */
    /* int mChannels; */      /* Number of channels - 1 for mono or 2 for stereo    /* int mBits; */          /* Bits per sample - 8, 16, or 32 */
  settings.mChannels = 2;
  settings.mBits = 16;
    /* int mFrequency; */     /* Sampling rate - 11025, 22050, or 44100 */
  settings.mFrequency = 44100;

  ModPlug_SetSettings(&settings);

  /* [fileLabel setStringValue:[songname lastPathComponent]]; */
  [window setTitle:[songname lastPathComponent]];
  [fileLabel setStringValue:[NSString stringWithCString:ModPlug_GetName(modfile)]]; 

  mlen = ModPlug_Read(modfile, audio_buffer, BUF_SIZE);
  ao_play(device, audio_buffer, mlen);

  timer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self \
      selector:@selector(continuePlay) userInfo:nil repeats:YES ];

  ispause = 0;
  isplaying = 1;
}

- (void) settings: (id)sender
{
    /* [self stop:nil]; */
    
    /*
    [NSBundle loadNibNamed:@"Settings" owner:self];
    [window makeKeyAndOrderFront: self];
    */
}

@end
