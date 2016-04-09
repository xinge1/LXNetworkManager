//
//  ViewController.m
//  LXNetworkingDemo
//
//  Created by 刘鑫 on 16/4/9.
//  Copyright © 2016年 liuxin. All rights reserved.
//

#import "ViewController.h"
#import "LXNetworking.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *progressLab;
- (IBAction)startDownload:(id)sender;

- (IBAction)suspend:(id)sender;

- (IBAction)resume:(id)sender;


@property (nonatomic,strong)LXURLSessionTask *task;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)startDownload:(id)sender {
    
    NSString *path=[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/image.jpg"]];
    _task = [LXNetworking downloadWithUrl:@"http://www.aomy.com/attach/2012-09/1347583576vgC6.jpg" saveToPath:path progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        //封装方法里已经回到主线程，所有这里不用再调主线程了
        _progressLab.text=[NSString stringWithFormat:@"进度==%.2f",1.0 * bytesProgress/totalBytesProgress];
        
    } success:^(id response) {
        NSLog(@"---------%@",response);
        _progressLab.text=@"下载完成";
    } failure:^(NSError *error) {
        
    } showHUD:NO];

    
}

- (IBAction)suspend:(id)sender {
    [_task suspend];
}
- (IBAction)resume:(id)sender {
    [_task resume];
}
@end
