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
}
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UIImageView *myImageview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    isFullScreen = NO;
    if (!ta) {
        ta = [self.storyboard instantiateViewControllerWithIdentifier:@"TABLE"];
    }
    libary = [[ALAssetsLibrary alloc] init];
    arr = [NSMutableArray array];
    array = [NSMutableArray array];
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self becomeFirstResponder];
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

- (void)viewDidDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    w = self.myImageview.frame.size.width;
    h = self.myImageview.frame.size.height;
    x = self.myImageview.frame.origin.x;
    y = self.myImageview.frame.origin.y;
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

- (IBAction)pushyem:(id)sender {
    if (array.count > 0) {
        ta.arra = [NSArray arrayWithArray:array];
        ta.delegate = self;
        [self.navigationController pushViewController:ta animated:YES];
    }
    else {
        [self getImageWithCout:0 andMore:NO];
    }
    
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

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    self.myLabel.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.myLabel.text = myTextField.text ? myTextField.text : @"shanshan";
        self.myLabel.font = [UIFont systemFontOfSize:20.0];
        self.secondLabel.text = myTextField1.text ? myTextField1.text : @"i love you so much !";
        self.secondLabel.hidden = NO;
    } completion:nil];
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
    [self saveImage:img withName:@"currentImage.jpg"];
    self.myImageview.image =img;
    isFullScreen = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}

- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName {
    NSData *imgData = UIImageJPEGRepresentation(currentImage, 0.5);
    NSString *imgPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    [imgData writeToFile:imgPath atomically:NO];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    isFullScreen = !isFullScreen;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    if (CGRectContainsPoint(self.myImageview.frame, touchPoint)) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        
        if (isFullScreen) {
            self.myImageview.frame = CGRectMake(x,y, w, h);
        }
        else {
            self.myImageview.frame = CGRectMake(w/4, h/4, w/2, h/2);
        }
        [UIView commitAnimations];
    }
}
@end
