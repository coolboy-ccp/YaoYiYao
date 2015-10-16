//
//  PlayMusicViewController.m
//  YaoYiYao
//
//  Created by liqunfei on 15/10/14.
//  Copyright © 2015年 chuchengpeng. All rights reserved.
//

#import "PlayMusicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "WebViewController.h"
#import "MusicListTableViewController.h"
#import "LysicCell.h"
@interface PlayMusicViewController ()<MusicListTableViewControllerDelegate,UITableViewDataSource>
{
    BOOL isPause;
    NSUInteger a;
    NSData *imageData;
    NSMutableDictionary *LRCDictionary;
    NSMutableArray *timeArray;
    NSInteger lrcLineNumber;
}
@property (weak, nonatomic) IBOutlet UITableView *lysicTabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UISlider *mySlider;
@property (weak, nonatomic) IBOutlet UIImageView *pauseImage;
@property (strong,nonatomic) AVAudioPlayer *audioPlayer;
@property (strong,nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lowestBackImagev;
@property (strong,nonatomic) NSArray *listArray;
@end

@implementation PlayMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    AVAudioSession *avsession = [AVAudioSession sharedInstance];
    [avsession setActive:YES error:nil];
    [avsession setCategory:AVAudioSessionCategoryPlayback error:nil];
    a = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastList"] ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastList"] unsignedIntegerValue] : 0;
    self.mySlider.userInteractionEnabled = self.audioPlayer?YES:NO;
    isPause = YES;
    self.pauseImage.hidden = YES;
    [self.mySlider setMinimumTrackImage:[UIImage imageNamed:@"slider_1"] forState:UIControlStateNormal];
    [self.mySlider setMaximumTrackImage:[UIImage imageNamed:@"slider_2"] forState:UIControlStateNormal];
    [self.mySlider setThumbImage:[UIImage imageNamed:@"slide_3"] forState:UIControlStateNormal];
    [self.mySlider setThumbImage:[UIImage imageNamed:@"slide_3"] forState:UIControlStateHighlighted];
    NSString *str = self.listArray[a];
    self.songNameLabel.text = [[str componentsSeparatedByString:@"YaoYiYao.app/"] lastObject];
    self.headImage.layer.masksToBounds = YES;
    self.headImage.layer.cornerRadius = 10.0;
    self.lowestBackImagev.image = [UIImage imageNamed:@"back"];
   [self setBackGroundImage];
    [self initLRC];
}

- (void)setBackGroundImage {
    NSArray *arr = @[@"back1",@"back2",@"back3",@"back4"];
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSString *str in arr) {
        UIImage *image = [UIImage imageNamed:str];
        [mutableArray addObject:image];
    }
    [self.headImage setAnimationImages:mutableArray];
    [self.headImage setAnimationDuration:12.0];
    [self.headImage startAnimating];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return timeArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LysicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LysicCell"];
    cell.lysicLabel.text = LRCDictionary[timeArray[indexPath.row]];
    if (lrcLineNumber == indexPath.row) {
        cell.lysicLabel.textColor =[UIColor colorWithRed:247.0/255 green:44.0/255 blue:48.0/255 alpha:1.0];
    }
    else {
        cell.lysicLabel.textColor = [UIColor colorWithRed:147.0/255 green:244.0/255 blue:48.0/255 alpha:1.0];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0;
}

//获取mp3的信息
-(void)getMp3Information:(NSString *)str
{
    //    NSURL *url = [NSURL fileURLWithPath:str];
    //    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:url options:nil];
    //    for (NSString *format in [mp3Asset availableMetadataFormats]) {
    //
    //        NSLog(@"-------format:%@",format);
    //
    //        for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
    //
    //            NSLog(@"commonKey:%@",metadataItem.commonKey);
    //
    //            if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
    //               // NSData *data = [(NSDictionary *)metadataItem.value objectForKey:@"data"];
    //                NSString *mime = [(NSDictionary *)metadataItem.value objectForKey:@"MIME"];
    //              // self.headImage.image = [UIImage imageWithData:data];
    //                NSLog(@"mime: %@",mime);
    //                break;
    //            }
    //            }
    //            
    //  }
    //  [self getMp3Information:str];
    NSURL *fileUrl = [NSURL fileURLWithPath:str];
   // AudioFileTypeID fileTypeHint = kAudioFileMP3Type;
    NSString *fileExtension = [[fileUrl path] pathExtension];
    if ([fileExtension isEqualToString:@"mp3"]) {
        AudioFileID fileID = nil;
        OSStatus error = noErr;
        
        error = AudioFileOpenURL((__bridge CFURLRef)fileUrl, kAudioFileReadPermission, 0, &fileID);
        if (error != noErr) {
            NSLog(@"open error");
        }
        
        UInt32 id3DataSize = 0;
        error = AudioFileGetPropertyInfo(fileID, kAudioFilePropertyID3Tag, &id3DataSize, NULL);
        if (error != noErr) {
            NSLog(@"AudioFileGetPropertyInfo Failed!");
        }
        
        NSDictionary *piDict = nil;
        UInt32 piDataSize = sizeof(piDict);
        error = AudioFileGetProperty(fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict);
        if (error != noErr) {
            NSLog(@"AudioFileGetProperty Failed!");
        }
        
        CFDataRef albumPic = nil;
        UInt32 picDataSize = sizeof(albumPic);
        error = AudioFileGetProperty(fileID, kAudioFilePropertyAlbumArtwork, &picDataSize, &albumPic);
        if (error != noErr) {
            NSLog(@"AudioFileGetProperty failed!(album)");
        }
        
        NSData *imageDataE = (__bridge NSData *)albumPic;
        UIImage *imgA = [UIImage imageWithData:imageDataE];
        self.headImage.image = imgA;
        
        NSString *album = [(NSDictionary *)piDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Album]];
        NSString *artlist = [(NSDictionary *)piDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Artist]];
        NSString *title = [(NSDictionary *)piDict objectForKey:@kAFInfoDictionary_Title];
        
        NSLog(@"album: %@\nartList: %@,Title: %@",album,artlist,title);
        NSLog(@"mp3Dic: %@",piDict);
    }
}


- (NSArray *)findAllArtistlist {
    NSMutableArray *artistList = [[NSMutableArray alloc] init];
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
        // 读取条件
        MPMediaPropertyPredicate *albumNamePredicate =
        [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeMusic ] forProperty: MPMediaItemPropertyMediaType];
        [everything addFilterPredicate:albumNamePredicate];
    
        NSLog(@"Logging items from a generic query...");
        NSArray *itemsFromGenericQuery = [everything items];
        for (MPMediaItem *song in itemsFromGenericQuery) {
            NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
            NSLog (@"%@", songTitle);
        }
    return artistList;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}
- (IBAction)backToHome:(UIButton *)sender {
    self.audioPlayer = nil;
    [self.timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)selectASongWithTag:(NSInteger)tag {
    self.audioPlayer = nil;
    a = tag;
    isPause = YES;
    NSString *str = self.listArray[a];
    self.songNameLabel.text = [[str componentsSeparatedByString:@"YaoYiYao.app/"] lastObject];
    [self playBtn:nil];
}

- (IBAction)moveToCurrentTime:(UISlider *)sender {
    [self.audioPlayer setCurrentTime:sender.value*self.audioPlayer.duration];
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)updateLrcTableView:(NSInteger)lineNumber {
    lrcLineNumber = lineNumber;
    [self.lysicTabel reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lineNumber inSection:0];
    [self.lysicTabel selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
   
}

- (void)displaySondWord:(NSUInteger)time {
    //    NSLog(@"time = %u",time);
    for (int i = 0; i < [timeArray count]; i++) {
        
        NSArray *array = [timeArray[i] componentsSeparatedByString:@":"];//把时间转换成秒
        NSUInteger currentTime = [array[0] intValue] * 60 + [array[1] intValue];
        if (i == [timeArray count]-1) {
            //求最后一句歌词的时间点
            NSArray *array1 = [timeArray[timeArray.count-1] componentsSeparatedByString:@":"];
            NSUInteger currentTime1 = [array1[0] intValue] * 60 + [array1[1] intValue];
            if (time > currentTime1) {
                [self updateLrcTableView:i];
                break;
            }
        } else {
            //求出第一句的时间点，在第一句显示前的时间内一直加载第一句
            NSArray *array2 = [timeArray[0] componentsSeparatedByString:@":"];
            NSUInteger currentTime2 = [array2[0] intValue] * 60 + [array2[1] intValue];
            if (time < currentTime2) {
                [self updateLrcTableView:0];
                //                NSLog(@"马上到第一句");
                break;
            }
            //求出下一步的歌词时间点，然后计算区间
            NSArray *array3 = [timeArray[i+1] componentsSeparatedByString:@":"];
            NSUInteger currentTime3 = [array3[0] intValue] * 60 + [array3[1] intValue];
            if (time >= currentTime && time <= currentTime3) {
                [self updateLrcTableView:i];
                break;
            }
            
        }
    }
}

- (void)initLRC {
    lrcLineNumber = 0;
    timeArray = [NSMutableArray array];
    LRCDictionary = [NSMutableDictionary dictionary];
    NSString *musiclrc = self.listArray[a];
    NSString * name = [musiclrc lastPathComponent];
    NSString *fileName = [[name componentsSeparatedByString:@".mp3"] firstObject];
    NSString *LRCPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"lrc"];
    NSString *contentStr = [NSString stringWithContentsOfFile:LRCPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [contentStr componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [array count]; i++) {
        NSString *linStr = [array objectAtIndex:i];
        NSArray *lineArray = [linStr componentsSeparatedByString:@"]"];
        if ([lineArray[0] length] > 8) {
            NSString *str1 = [linStr substringWithRange:NSMakeRange(3, 1)];
            NSString *str2 = [linStr substringWithRange:NSMakeRange(6, 1)];
            if ([str1 isEqualToString:@":"] && [str2 isEqualToString:@"."]) {
                NSString *lrcStr = [lineArray objectAtIndex:1];
                NSString *timeStr = [[lineArray objectAtIndex:0] substringWithRange:NSMakeRange(1, 5)];//分割区间求歌词时间
                //把时间 和 歌词 加入词典
                [LRCDictionary setObject:lrcStr forKey:timeStr];
                [timeArray addObject:timeStr];//timeArray的count就是行数
            }
        }
    }
}


- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        NSString *str = [[self.listArray[a] componentsSeparatedByString:@"YaoYiYao.app/"] lastObject];
        NSString *urlStr = [[NSBundle mainBundle] pathForResource:str ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:urlStr];
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        _audioPlayer.delegate = (id<AVAudioPlayerDelegate>)self;
        [_audioPlayer prepareToPlay];
        if (error) {
            return nil;
        }
    }
    return _audioPlayer;
}


- (NSArray *)listArray {
    if (!_listArray) {
        _listArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"mp3" inDirectory:nil];
    }
    return _listArray;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:a] forKey:@"lastList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (IBAction)getMoreMusic:(UIButton *)sender {
    MusicListTableViewController *ListTable = [self.storyboard instantiateViewControllerWithIdentifier:@"MusicList"];
    ListTable.songsList = self.listArray;
    ListTable.delegate = self;
    [self.navigationController pushViewController:ListTable animated:YES];

}

- (IBAction)backBtn:(UIButton *)sender {
    self.audioPlayer = nil;
    a = (a > 0) ? (a-1):0;
    NSString *str = self.listArray[a];
    _songNameLabel.text = [[str componentsSeparatedByString:@"YaoYiYao.app/"] lastObject];
    [self playBtn:nil];
}

- (IBAction)playBtn:(UIButton *)sender {
    [self initLRC];
    self.mySlider.userInteractionEnabled = YES;
    isPause = !isPause;
    self.pauseImage.hidden = isPause;
    if (!isPause) {
        [self.audioPlayer play];
        self.timer.fireDate = [NSDate distantPast];
    }
    else {
        [self.audioPlayer pause];
        self.timer.fireDate = [NSDate distantFuture];
    }
    
}

- (IBAction)goBtn:(UIButton *)sender {
    self.audioPlayer = nil;
    isPause = YES;
    a = (a < self.listArray.count-1) ? (a+1) : 0;
    NSString *str = self.listArray[a];
    _songNameLabel.text = [[str componentsSeparatedByString:@"YaoYiYao.app/"] lastObject];
    [self playBtn:nil];
}

- (void)updateProgress {
    float progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
    [self.mySlider setValue:progress animated:YES];
    [self displaySondWord:self.audioPlayer.currentTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        isPause = YES;
        self.pauseImage.hidden = isPause;
    }
    else {
        NSLog(@"failed");
    }
}


@end
