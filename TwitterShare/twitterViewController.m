//
//  ViewController.m
//  TwitterShare
//
//  Created by Jayati Saha on 20/09/15.
//  Copyright (c) 2015 Jayati Saha. All rights reserved.
//

#import "twitterViewController.h"
#import "FHSTwitterEngine.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "SVProgressHUD.h"
#import "OAuth+Additions.h"
#import "TWTAPIManager.h"
#define ERROR_TITLE_MSG @""
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in Settings.app to use this demo."
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS @"You need to add your Twitter app keys to Info.plist to use this demo.\nPlease see README.md for more info."
#define ERROR_OK @"OK"
@interface twitterViewController ()<FHSTwitterEngineAccessTokenDelegate,UITextFieldDelegate>{
    ACAccountStore *accountStore;
    ACAccount *twitterAccount;
    BOOL isloginwithtwitter;
     NSString *twitterloginid,*twitteraccesstoken,*twittersecretkey;
    BOOL istextpost;
}
@property (nonatomic, strong) TWTAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) IBOutlet UIImageView *uploadimageview;
@property (nonatomic, strong) IBOutlet UITextField *status;
@end

@implementation twitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isloginwithtwitter=FALSE;
    accountStore = [[ACAccountStore alloc] init];
    _apiManager = [[TWTAPIManager alloc] init];
   
    istextpost=FALSE;
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"U88a3GQR1zdgTuQegHVwQBwGh" andSecret:@"9Dz4P3x3XRvNUUFTe8ROpDcKjAubsEfPc8MAU6J4s6ecKtFKda"];
    //// twitter using reverse oauth
     [self _refreshTwitterAccounts];
    
    isloginwithtwitter=FALSE;
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    
    
    
    
    
    if(isloginwithtwitter==TRUE){
        
        /// //// twitter using reverse oauth
        [self postimageusingoauth];
//        [self performSelectorOnMainThread:@selector(postusingtwitterlogin) withObject:nil waitUntilDone:YES];
        }else{
            [SVProgressHUD dismiss];
            [self.view setUserInteractionEnabled:YES];
        }
   

}

-(void)postimageusingoauth
{
   
    
    
        [self.view setUserInteractionEnabled:YES];
        
        //        NSString *username = [[FHSTwitterEngine sharedEngine]loggedInUsername];
        
        twitterloginid= [[FHSTwitterEngine sharedEngine]loggedInID];
        twitteraccesstoken=[[FHSTwitterEngine sharedEngine]useraccesstoken];
        twittersecretkey=[[FHSTwitterEngine sharedEngine]usersecretkey];
        
        [[FHSTwitterEngine sharedEngine]clearAccessToken];
        
        isloginwithtwitter=FALSE;
        
    if(istextpost==FALSE){
        [self postimage];
    }else{
        [self posttext];
    }
    
    

}
-(void)postimage{
    [SVProgressHUD showWithStatus:@"Please wait..."];
    [self.view setUserInteractionEnabled:YES];
    
    [[FHSTwitterEngine sharedEngine] setaccesstoken:twitteraccesstoken secret_key:twittersecretkey];
    
    
    NSString *postedstring=_status.text;
    
    if(postedstring.length>117){
        postedstring=[postedstring substringToIndex:117];
    }
    
    id dic;
    if(postedstring.length>0){
        
        dic=[[FHSTwitterEngine sharedEngine]postTweet1:postedstring withImageData:UIImageJPEGRepresentation(_uploadimageview.image, .4)];
    }else{
        
        dic=[[FHSTwitterEngine sharedEngine]postTweet1:@" " withImageData:UIImageJPEGRepresentation(_uploadimageview.image, .4)];
    }
    
    
    //    [SVProgressHUD dismiss];
    if([dic isKindOfClass:[NSError class]]){
        [SVProgressHUD dismiss];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Twitter error" message:@"Image did not post on twitter." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        //        [SVProgressHUD dismiss];
    }else{
        [SVProgressHUD dismiss];
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)twitterwithreverseoauth
{
    
    
    [SVProgressHUD showWithStatus:@"Please wait"];
    
    
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:
                                      ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:accountType options:nil
                                           completion:^(BOOL granted, NSError *error)
         {
             if(granted){
                 
                 NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                 
                 
                 //exit(0);
                 twitterAccount = [accountsArray lastObject];
                 NSLog(@"twitterAccount %@",twitterAccount);
                 
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
                 NSDictionary *params = @{@"screen_name" : twitterAccount.username
                                          };
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 [request setAccount:[accountsArray lastObject]];
                 
                 [request performRequestWithHandler:^(NSData *responseData,
                                                      NSHTTPURLResponse *urlResponse,
                                                      NSError *error) {
                     if (responseData) {
                         
                         if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                             
                             
                             [self performSelectorOnMainThread:@selector(twitterdetails:)withObject:responseData waitUntilDone:NO];
                         }
                         else
                         {
                             
                             [self loginwithtwiiter];
                             
                             
                         }
                     }else
                     {
                         
                         [self loginwithtwiiter];
                         
                         
                         
                     }
                 }];
             }
             else
             {
                 
                [self loginwithtwiiter];
                 
                 
                 
             }
         }];
    }
    else
    {
        [self loginwithtwiiter];
        
        
        
        
        
    }
    
}

-(void)loginwithtwiiter{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view setUserInteractionEnabled:YES];
        [SVProgressHUD dismiss];
        [[FHSTwitterEngine sharedEngine]setDelegate:self];
        
        
        
        [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
            
            [[FHSTwitterEngine sharedEngine]loadAccessToken];
            isloginwithtwitter=success;
        }];
        
        
    });

}


-(void)twitterdetails:(NSData *)data
{
    NSLog(@"twitterdetails %@",data);
    @try {
        NSError* error = nil;
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        NSLog(@"json %@",json);
        
        twitterloginid=[NSString stringWithFormat:@"%@",[json objectForKey:@"id"]];
        
        
        
        // [self ShowProgress:@"Please wait.." :NO];
        
        
        [_apiManager performReverseAuthForAccount:_accounts[0] withHandler:^(NSData *responseData, NSError *error) {
            if (responseData) {
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                NSLog(@"parts %@",parts);
                if(parts.count>1){
                    NSString *oauthstring=[parts objectAtIndex:0];
                    NSString *secretstring=[parts objectAtIndex:1];
                    
                    
                    
                    NSArray *ouatharray=[oauthstring componentsSeparatedByString:@"="];
                    NSArray *secretarray=[secretstring componentsSeparatedByString:@"="];
                    
                    twitteraccesstoken=[ouatharray objectAtIndex:1];
                    twittersecretkey=[secretarray objectAtIndex:1];
                    NSLog(@"twittersecretkey %@",twittersecretkey);
                     NSLog(@"twitteraccesstoken %@",twitteraccesstoken);
                    if(istextpost==FALSE){
                    [self postimage];
                    }else{
                        [self posttext];
                    }

                    
                }else{
                    [self loginwithtwiiter];
                }
                
                [SVProgressHUD dismiss];
                [self.view setUserInteractionEnabled:YES];
                
            }
            else {
                [SVProgressHUD dismiss];
                [self.view setUserInteractionEnabled:YES];
                
            }
        }];
        
    }
    @catch (NSException *exception) {
        
        [SVProgressHUD dismiss];
        [self.view setUserInteractionEnabled:YES];
    }
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [_apiManager performReverseAuthForAccount:_accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
            if (responseData) {
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                NSString *lined = [parts componentsJoinedByString:@"\n"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:lined delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
            else {
                
            }
        }];
    }
}


- (void)_displayAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:message delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
    [alert show];
}


- (void)_refreshTwitterAccounts
{
    if (![TWTAPIManager hasAppKeys]) {
         [self _displayAlertWithMessage:ERROR_NO_KEYS];
    }
    else if (![TWTAPIManager isLocalTwitterAccountAvailable]) {
         [self _displayAlertWithMessage:ERROR_NO_ACCOUNTS];
    }
    else {
        [self _obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    //                    _reverseAuthBtn.enabled = YES;
                }
                else {
                       [self _displayAlertWithMessage:ERROR_PERM_ACCESS];
                }
            });
        }];
    }
}

- (void)_obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [accountStore accountsWithAccountType:twitterType];
            NSLog(@"self.accounts %@",self.accounts);
        }
        
        block(granted);
    };
    [accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:handler];
}


- (IBAction)textshare:(id)sender {
    istextpost=TRUE;;

    
    
    //// twitter using reverse oauth
    if(twittersecretkey.length==0 || twittersecretkey.length==0){
        [self twitterwithreverseoauth];
    }else{
        [self posttext];
    }
    
    
//    [self twitterwithoutreverseoauth];
}

- (IBAction)imageshare:(id)sender {
    istextpost=FALSE;
    
     //// twitter using reverse oauth
    if(twittersecretkey.length==0 || twittersecretkey.length==0){
        [self twitterwithreverseoauth];
    }else{
        [self postimage];
    }
    
   
//     [self twitterwithoutreverseoauth];
}
-(void)posttext{
    NSString *posttext=_status.text;
    [SVProgressHUD showWithStatus:@"Please wait..."];
    [self.view setUserInteractionEnabled:YES];
    
    [[FHSTwitterEngine sharedEngine] setaccesstoken:twitteraccesstoken secret_key:twittersecretkey];
    
    
   
    
    if(posttext.length>140){
        posttext=[posttext substringToIndex:140];
    }
    [SVProgressHUD dismiss];
    [[FHSTwitterEngine sharedEngine] postTweet1:posttext];
 
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
-(void)twitterwithoutreverseoauth
{
    
        if(istextpost==TRUE){
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
           
            
            ACAccountType *accountType      = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
                
                NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                if([accountsArray count]>0)
                {
                    
                    
                    SLRequestHandler requestHandler =
                    ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        if (responseData) {
                            NSInteger statusCode = urlResponse.statusCode;
                            if (statusCode >= 200 && statusCode < 300) {
                                
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    NSLog(@"1111");
                                    [self performSelectorOnMainThread:@selector(postusingtwitterlogin) withObject:nil waitUntilDone:YES];
                                    
                                    
                                });
                            }
                        } else {
                            
                            NSString *ErrString = [NSString stringWithFormat:@"[ERROR] An error occurred while posting: %@", [error localizedDescription]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD dismiss];
                                
                                UIAlertView *TwitterAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [TwitterAlertView show];
                            });
                        }
                    };
                    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
                    ^(BOOL granted, NSError *error) {
                        if (granted) {
                            NSString *postedstring;
                            postedstring=_status.text;
                            if(istextpost==TRUE){
                            if(_status.text.length>140){
                                postedstring=[postedstring substringToIndex:140];
                            }
                            }else{
//                                if(postedstring.length==0){
//                                   postedstring=@" ";
//                                }
//                                else if(_status.text.length>117){
//                                    postedstring=[postedstring substringToIndex:117];
//                                }
                            }
                            NSURL *url;
                            NSDictionary *params;
//                            if(istextpost==FALSE){
//                                url = [NSURL URLWithString:@"https://api.twitter.com"
//                                              @"/1.1/statuses/update_with_media.json"];
//                                NSDictionary *params = @{@"status" : postedstring};
//                                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
//                                                                        requestMethod:SLRequestMethodPOST
//                                                                                  URL:url
//                                                                           parameters:params];
//                                [request addMultipartData:ImageShareData
//                                                 withName:@"media[]"
//                                                     type:@"image/jpeg"
//                                                 filename:@"image.jpg"];
//                            }else{
                                url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
                                params = @{@"status" : postedstring};
//                            }
                            
                           
                            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                    requestMethod:SLRequestMethodPOST
                                                                              URL:url
                                                                       parameters:params];
                            
                            
                            
                            [request setAccount:[accountsArray lastObject]];
                            [request performRequestWithHandler:requestHandler];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD dismiss];
                               
                                UIAlertView *TwitterAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"status posted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [TwitterAlertView show];
                            });
                            
                        }
                        else {
                            NSString *ErrString = [NSString stringWithFormat:@"[ERROR] An error occurred while asking for user authorization: %@",[error localizedDescription]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD dismiss];
                               
                                UIAlertView *TwitterAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [TwitterAlertView show];
                            });
                            
                        }
                    };
                    [accountStore requestAccessToAccountsWithType:accountType
                                                          options:NULL
                                                       completion:accountStoreHandler];
                    
                    
                    
                    
                    
                    
                    
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                         NSLog(@"3333");
                        [self performSelectorOnMainThread:@selector(postusingtwitterlogin) withObject:nil waitUntilDone:YES];
                        
                    });
                }
            }];
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"2222");
                [SVProgressHUD dismiss];
                [self performSelectorOnMainThread:@selector(postusingtwitterlogin) withObject:nil waitUntilDone:YES];
                
                
                
                
            });
        }
        }else{
            NSData  *ImageShareData= UIImageJPEGRepresentation(_uploadimageview.image,.4);
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                
               
                ACAccountType *accountType      = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                
                [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
                    
                    NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                    if([accountsArray count]>0)
                    {
                        
                        
                        SLRequestHandler requestHandler =
                        ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                            if (responseData) {
                                NSInteger statusCode = urlResponse.statusCode;
                                if (statusCode >= 200 && statusCode < 300) {
                                    //                            NSDictionary *postResponseData = [NSJSONSerialization JSONObjectWithData:responseData
                                    //                                                                                             options:NSJSONReadingMutableContainers
                                    //                                                                                               error:NULL];
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self performSelectorOnMainThread:@selector(postusingtwitterlogin) withObject:nil waitUntilDone:YES];
                                        
                                        
                                    });
                                }
                            } else {
                                
                                NSString *ErrString = [NSString stringWithFormat:@"[ERROR] An error occurred while posting: %@", [error localizedDescription]];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SVProgressHUD dismiss];
                                    
                                    UIAlertView *TwitterAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    [TwitterAlertView show];
                                });
                            }
                        };
                        ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
                        ^(BOOL granted, NSError *error) {
                            if (granted) {
                                NSString *postedstring;
                                postedstring=_status.text;
                                if(postedstring.length==0){
                                    postedstring=@" ";
                                }
                                else if(_status.text.length>117){
                                    postedstring=[postedstring substringToIndex:117];
                                }
                                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                                              @"/1.1/statuses/update_with_media.json"];
                                NSDictionary *params = @{@"status" :postedstring};
                                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                        requestMethod:SLRequestMethodPOST
                                                                                  URL:url
                                                                           parameters:params];
                                [request addMultipartData:ImageShareData
                                                 withName:@"media[]"
                                                     type:@"image/jpeg"
                                                 filename:@"image.jpg"];
                                [request setAccount:[accountsArray lastObject]];
                                [request performRequestWithHandler:requestHandler];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SVProgressHUD dismiss];
                                    
                                    UIAlertView *TwitterAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image uploaded successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    [TwitterAlertView show];
                                });
                                
                            }
                            else {
                                NSString *ErrString = [NSString stringWithFormat:@"[ERROR] An error occurred while asking for user authorization: %@",[error localizedDescription]];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SVProgressHUD dismiss];
                                    
                                    UIAlertView *TwitterAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    [TwitterAlertView show];
                                });
                                
                            }
                        };
                        [accountStore requestAccessToAccountsWithType:accountType
                                                              options:NULL
                                                           completion:accountStoreHandler];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                           
                            [self performSelectorOnMainThread:@selector(postusingtwitterlogin) withObject:nil waitUntilDone:YES];
                            
                        });
                    }
                }];
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    
                    
                    //            [SVProgressHUD show];
                    
                    
                    
                    [self performSelectorOnMainThread:@selector(postusingtwitterlogin) withObject:nil waitUntilDone:YES];
                    
                    
                    
                    
                });
            }
        }
    }

-(void)postusingtwitterlogin
{
    [SVProgressHUD showWithStatus:@"please wait"];
    [self.view setUserInteractionEnabled:NO];
    if(isloginwithtwitter==TRUE)
    {
        
        
        NSString *postedstring;
        postedstring=_status.text;
        if(istextpost==TRUE){
            if(_status.text.length>140){
                postedstring=[postedstring substringToIndex:140];
            }
        }else{
            if(postedstring.length==0){
                postedstring=@" ";
            }
            else if(_status.text.length>117){
                postedstring=[postedstring substringToIndex:117];
            }
        }

        
        if(istextpost==TRUE){
        [[FHSTwitterEngine sharedEngine]postTweet:postedstring] ;
            
        }else{
           [[FHSTwitterEngine sharedEngine] postTweet:postedstring withImageData:UIImageJPEGRepresentation(_uploadimageview.image, .4)];
        }
        
        if(isloginwithtwitter==TRUE){
            
            [[FHSTwitterEngine sharedEngine]clearAccessToken];
         }
        
        isloginwithtwitter=FALSE;
        
        
        
        [self performSelector:@selector(desblemsg:) withObject:nil afterDelay:1.5];
    }
    
    else
    {
       [self loginwithtwiiter];
       
        
    }
}

-(void)desblemsg:(id)sender{
    [self.view setUserInteractionEnabled:YES];
    [SVProgressHUD dismiss];
}



@end
