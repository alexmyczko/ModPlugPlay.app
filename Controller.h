/* All Rights reserved */

#include <AppKit/AppKit.h>

@interface Controller : NSObject
{
    int isplaying, ispause;
    unsigned char audio_buffer[BUF_SIZE];
    int audio_fd;
    ModPlugFile *modfile;
    id fileLabel,loopSong,songPosition,progressBar,playPause;
    id window;
    int mlen,modlen;
    NSTimer *timer;
    struct timeval tv,tvstart,tvpause,tvunpause,tvptotal;
    id outputDriver,outputFreq,outputBits,outputChannels;
  
    ao_device *device;
    ao_sample_format aoformat;
    int default_driver;
}
- (void) pause: (id)sender;
- (void) forward: (id)sender;
- (void) backward: (id)sender;
- (void) play: (id)sender;
- (void) nextSong: (id)sender;
- (void) prevSong: (id)sender;
- (void) loopUnloop: (id)sender;
- (void) settings: (id)sender;
@end
