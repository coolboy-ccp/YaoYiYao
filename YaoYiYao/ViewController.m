//
//  ViewController.m
//  YaoYiYao
//
//  Created by liqunfei on 15/9/25.
//  Copyright © 2015年 chuchengpeng. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PlayMusicViewController.h"
@interface ViewController ()<TableViewControllerDelegate,UIActionSheetDelegate>
{
    UITextField *myTextField;
    UITextField *myTextField1;
    NSMutableArray *arr;
    NSMutableArray *array;
    TableViewController *ta;
    ALAssetsLibrary *libary;
    UIImage *image1;
    UIImage *image2;
    NSString *type;
    BOOL isFullScreen;
    CGFloat w;
    CGFloat h;
    CGFloat x;
    CGFloat y;
    NSInteger i;
    CGFloat r;
    CGFloat scaleInt;
    YaoYiYaoBaseRequest *request;
    CGRect newRect;
    CGSize sizeO;
}
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UIImageView *myImageview;
@property (weak, nonatomic) IBOutlet UIScrollView *myScroll;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    request = [[YaoYiYaoBaseRequest alloc] init];
    i = 0;
    self.view.layer.contents = (id)[UIImage imageNamed:@"backimg"].CGImage;
    isFullScreen = NO;
    if (!ta) {
        ta = [self.storyboard instantiateViewControllerWithIdentifier:@"TABLE"];
    }
    libary = [[ALAssetsLibrary alloc] init];
    arr = [NSMutableArray array];
    array = [NSMutableArray array];
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self becomeFirstResponder];
    NSString *extension = @"jpg";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *fileName in contents) {
        if ([[fileName pathExtension] isEqualToString:extension]) {
            [fileManager removeItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil];
        }
    }
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 2;
    self.myImageview.userInteractionEnabled = YES;
    [self.myImageview addGestureRecognizer:pin];
    [self.myImageview addGestureRecognizer:pan];
    [self.myImageview addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeBackgroundImageWithImage:(NSInteger)image {
    if (arr) {
        UIImage *img = arr[image];
        self.myImageview.image = img;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    w = self.myImageview.frame.size.width;
    h = self.myImageview.frame.size.height;
    x = self.myImageview.frame.origin.x;
    y = self.myImageview.frame.origin.y;
    r = self.view.bounds.size.width/self.view.bounds.size.height;
    [self addObserver:self forKeyPath:@"myImageview.bounds" options:NSKeyValueObservingOptionNew |
     NSKeyValueObservingOptionOld context:nil];
}

- (void)getMoreImageWithNum:(NSInteger)num {
    ta.arra = [NSArray arrayWithArray:array];
    [self getImageWithCout:num andMore:YES];
}

- (void)getImageWithCout:(NSInteger)cout andMore:(BOOL)more {
    NSInteger __block blockcout = 0;
    [libary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
          
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result == nil) {
                }
                else {
                    if (index > cout) {
                        *stop = (blockcout++ > 18);
                        ALAssetRepresentation *rap = [result defaultRepresentation];
                        image1 = [UIImage imageWithCGImage:[rap fullScreenImage]];
                        image2 = [UIImage imageWithCGImage:[result thumbnail]];
                        type = [result valueForProperty:ALAssetPropertyType];
                        if ([type isEqualToString:ALAssetTypePhoto]) {
                            type = @"photos";
                        }
                        else if ([type isEqualToString:ALAssetTypeVideo]) {
                            type = @"videos";
                        }
                        else if ([type isEqualToString:ALAssetTypeUnknown]) {
                            type = @"unknown";
                        }
                        NSDictionary *dic = @{@"TYPE":type,@"IMAGE":image2};
                        [array addObject:dic];
                        [arr addObject:image1];
                    }
                }
            }];
            if (more) {
                
            }
            else {
                ta.allCout = [group numberOfAssets];
                ta.arra = [NSArray arrayWithArray:array];
                ta.delegate = self;
                [self.navigationController pushViewController:ta animated:YES];
            }
        }
    } failureBlock:^(NSError *error) {
        
    }];

}

void soundCompleteCallback(SystemSoundID soundId,void *clientData) {
    AudioServicesRemoveSystemSoundCompletion(soundId);
    UIImageView *name = (__bridge UIImageView *)clientData;
    [name stopAnimating];
    
}

- (void)playSoundEffectWithName:(NSString *)name {
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    SystemSoundID soundId = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundId);
    AudioServicesAddSystemSoundCompletion(soundId, NULL, NULL, soundCompleteCallback, (__bridge void *)self.myImageview);
    if (SIMULATOR) {
        AudioServicesPlaySystemSound(soundId);
    }
    else {
       AudioServicesPlayAlertSound(soundId);
    }
}

- (IBAction)pushyem:(id)sender {
    [self playSoundEffectWithName:@"sound1.wav"];
    [self.myImageview stopAnimating];
    NSMutableArray *arr1 = [NSMutableArray array];
    for (int j = 1; j<5; j++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"ani_%d",j]];
        [arr1 addObject:image];
    }
    [self.myImageview setAnimationDuration:0.5];
    [self.myImageview setAnimationImages:arr1];
    [self.myImageview startAnimating];
//    NSDictionary *dic = @{@"phoneno":@"18705183215",@"cardnum":@"5",@"key":@"ef69b42e243251b78799716036173c5d"};
//    dic = @{@"url":@"CBx-6iBHdZlqwcOKG4E4otIH5obGepVJXPaBC8u_WgtAVjhsRuLb_9mKzeP0BVf2aZSohiEMbTmNifBE2s1D0uuoI843qjxeSGQP_ZIlBZC"};
//    [request serviceRequestWithPostURL:@"http://zhidao.baidu.com/link" parameters:dic successBlock:^(id response) {
//        NSLog(@"response-----%@",response[@"reason"]);
//    } failureBlock:^(NSString *errInfo) {
//
//        NSLog(@"errInfo------%@",errInfo);
//    }];
//    if (array.count > 0) {
//        ta.arra = [NSArray arrayWithArray:array];
//        ta.delegate = self;
//        [self.navigationController pushViewController:ta animated:YES];
//    }
//    else {
//        [self getImageWithCout:0 andMore:NO];
//    }
    
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    self.myLabel.hidden = YES;
    self.secondLabel.hidden = YES;
}




- (IBAction)myclick:(id)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"input" message:@"please input your girl's name" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.myLabel.text = myTextField.text;
        self.secondLabel.text = alertVC.textFields.lastObject.text;
    }];
    action1.enabled = NO;
    [alertVC addAction:action1];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Your lover's name";
    }];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Something you want to say";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldChanged:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    [self presentViewController:alertVC animated:YES completion:nil];

}

- (void)alertTextFieldChanged:(NSNotification *)notification {
    UIAlertController *alet = (UIAlertController *)self.presentedViewController;
    if (alet) {
        
        UIAlertAction *ok = alet.actions.lastObject;
        myTextField = alet.textFields.firstObject;
        myTextField1 = alet.textFields.lastObject;
        ok.enabled = YES;
    }
}
- (IBAction)playMusic:(UIButton *)sender {
    PlayMusicViewController *palyMusicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayView"];
    [self.navigationController pushViewController:palyMusicVC animated:YES];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [self.myImageview stopAnimating];
    NSMutableArray *arr1 = [NSMutableArray array];
    for (int j = 1; j<8; j++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"ani_0%d",j]];
        [arr1 addObject:image];
    }
    [self.myImageview setAnimationDuration:0.5];
    [self.myImageview setAnimationImages:arr1];
    [self.myImageview startAnimating];
}

- (IBAction)takePhoto:(UIButton *)sender {
    UIActionSheet *sheeet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sheeet = [[UIActionSheet alloc] initWithTitle:@"select" delegate:self cancelButtonTitle:@"cancle" destructiveButtonTitle:nil otherButtonTitles:@"take photo",@"photoLibrary", nil];
    }
    else {
        sheeet = [[UIActionSheet alloc] initWithTitle:@"select" delegate:self cancelButtonTitle:@"cancle" destructiveButtonTitle:nil otherButtonTitles:@"photoLibrery", nil];
    }
    sheeet.tag = 255;
    [sheeet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = 0;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    return;
                    break;
                    
                default:
                    break;
            }
        }
        else {
            switch (buttonIndex) {
                case 0:
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 1:
                    return;
                    break;
                    
                default:
                    break;
            }
        }
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = (id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = sourceType;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
   }

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self saveImage:img withName:[NSString stringWithFormat:@"img%ld.jpg",(long)i++]];
    self.myImageview.image =img;
    isFullScreen = NO;
    
    [self createScrollImgWithNum:i];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createScrollImgWithNum:(NSInteger)num {
    int a = 0;
    CGFloat sH = self.myScroll.frame.size.height;
    CGFloat sW = sH*r;
    NSData *imgData;
    UIImage *img = [UIImage imageNamed:@"firstimg"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changCharge:)];
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sW, sH)];
    imgview.image = img;
    imgview.userInteractionEnabled = YES;
    [imgview addGestureRecognizer:tap];
    if (num == -1) {
        
    }
    else {
         [self.myScroll addSubview:imgview];
    }
     newRect = [self.view convertRect:imgview.frame fromView:self.myScroll];
    while (num-- > 0) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changCharge:)];
         NSString *imgPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"img%ld.jpg",(long)a++]];
        imgData = [NSData dataWithContentsOfFile:imgPath];
        img = [UIImage imageWithData:imgData];
        UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(a*sW, 0, sW, sH)];
        imgview.image = img;
        self.myScroll.contentSize = CGSizeMake(sW*num, sH);
        [imgview addGestureRecognizer:tap];
        imgview.userInteractionEnabled = YES;
      newRect = [self.view convertRect:imgview.frame fromView:imgview];
        [self.myScroll addSubview:imgview];
    }
    
}

- (void)changCharge:(UITapGestureRecognizer *)tapa {
    UIImageView *imgV = (UIImageView *)tapa.view;
    self.myImageview.image = imgV.image;
    [self.myImageview stopAnimating];
}


//- (UIImage *)thumbnailWithImage:(UIImage *)image frame:(CGRect)aframe
//{
//    UIImage *newImage;
//    if (image) {
//        UIGraphicsBeginImageContext(aframe.size);
//        [image drawInRect:aframe];
//        newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    return newImage;
//}

- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName {
    NSData *imgData = UIImageJPEGRepresentation(currentImage, 0.5);
    NSString *imgPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    [imgData writeToFile:imgPath atomically:NO];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    isFullScreen = !isFullScreen;
//    UITouch *touch = [touches anyObject];
//    
//    CGPoint touchPoint = [touch locationInView:self.view];
//    if (CGRectContainsPoint(self.myImageview.frame, touchPoint)) {
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:1.0];
//        self.myImageview.frame = CGRectMake(w/4, h/4, w/2, h/2);
//        [UIView commitAnimations];
//    }
    
}

- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        scaleInt = pinchGestureRecognizer.scale;
        pinchGestureRecognizer.scale = 1.0;
    }
}

- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    self.myImageview.transform = CGAffineTransformIdentity;
    CGPoint translation = [recognizer translationInView:self.view];
    CGRect rect = recognizer.view.frame;
    if (rect.size.width > self.view.frame.size.width/3.0) {
        rect.size.width -= 10;
        rect.size.height -= 10/r;
        self.myImageview.bounds = rect;
    }
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
   
    
    [recognizer setTranslation:CGPointZero inView:self.view];

  
}

- (void)tapView:(UITapGestureRecognizer *)tap {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.myImageview.transform = CGAffineTransformIdentity;
    self.myImageview.frame = self.view.frame;
    [UIView commitAnimations];
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
        if (self.myImageview.frame.size.width < self.view.frame.size.width/1.0) {
            if (self.myImageview.frame.size.width < self.view.frame.size.width/1.5) {
                if (CGRectIntersectsRect(self.myImageview.frame, self.myScroll.frame)) {
                    [self createScrollImgWithNum:i];
                    self.myImageview.image = nil;
                }
                
            }
               //self.myImageview.frame = self.view.frame;
        }
}

@end
