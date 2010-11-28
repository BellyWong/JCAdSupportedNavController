//
//  JCAdSupportedNavigationController.m
//  
//
//  Created by Jesse Collis <jesse@jcmultimedia.com.au> on 09/11/10.
//  Copyright 2010 JC Multimedia Design. All rights reserved.
//

#import "JCAdSupportedNavController.h"
#import "AdMobView.h"

#define ADMOB_PUBLISHER_ID @"PUTHERE"

@implementation JCAdSupportedNavController
@synthesize adView,adMobView,adBannerIsVisible,adMobBannerIsVisible;

#pragma mark -
#pragma mark Setup and Teardown

- (void)loadView {
	[super loadView];
	
	// iOS 3.x will not show iAds at all
	if (NSClassFromString(@"ADBannerView")) {
		[self initAdBannerView];
	}else {
		[self initAdMobView];
	}

	self.adBannerIsVisible = NO;
	self.adMobBannerIsVisible = NO;
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[adView release];
    [super viewDidUnload];
}


- (void)dealloc {
	[adView release];
    [super dealloc];
}


#pragma mark -
#pragma mark iAd Functions

-(void)initAdBannerView {

	// Create the adView and put off the end of the view's bounds.
	adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 0, 0)]; 
	
	// ADBannerContentSizeIdentifier320x50 and ADBannerContentSizeIdentifier480x32 are deprecated in iOS 4.2
	// To make things work into the future, we will use them if we notice they're available.
	// This also prevents ugly deprecated messages too.
	
	// This code assumes you're launching the app in portrait
	
	if (&ADBannerContentSizeIdentifierPortrait != nil && &ADBannerContentSizeIdentifierLandscape != nil) {
		adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
		adView.requiredContentSizeIdentifiers = [NSSet setWithObjects: ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
	}else{
		adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		adView.requiredContentSizeIdentifiers = [NSSet setWithObjects: ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];			
	}
	
	adView.delegate = self;
	adView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	
	// Add the navigation controller's view to the window and display.
	[self.view addSubview:adView];
}

#pragma mark AdBannerViewDelegate Callbacks
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	DLog(@"iAd Banner Did Load");
	
	if (self.adMobBannerIsVisible) {
		[self hideAdMobBanner];
	}
	
	[self showAdBanner];
}
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    BOOL shouldExecuteAction = YES; //[self allowActionToRun]; // your application implements this method
    if (!willLeave && shouldExecuteAction)
    {
        // insert code here to suspend any services that might conflict with the advertisement
    }
    return shouldExecuteAction;
}
- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
	DLog(@"iAd Banner Did Finish Load");
}
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
	DLog(@"iAd Banner did fail %@",[error userInfo]);
	[self hideAdBanner];
	[self initAdMobView];
}

-(void)showAdBanner{
    if (!self.adBannerIsVisible)
    {
		UIView *contentView = [self.view.subviews objectAtIndex:0];
        CGRect originalViewFrame = contentView.frame;
		CGRect adFrame = self.adView.frame;
		
		adFrame.origin.y = self.view.frame.size.height - adFrame.size.height;
		originalViewFrame.size.height = self.view.frame.size.height - adFrame.size.height;
		
		[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        adView.frame = adFrame;
		contentView.frame = originalViewFrame;
		[UIView commitAnimations];
        self.adBannerIsVisible = YES;
    }	
}
-(void)hideAdBanner{
	if (self.adBannerIsVisible) 
	{
		UIView *contentView = [self.view.subviews objectAtIndex:0];
        CGRect originalViewFrame = contentView.frame;
		CGRect adFrame = adView.frame;
		
		originalViewFrame.size.height = self.view.frame.size.height; 
		adFrame.origin.y = self.view.frame.size.height;
		
		[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        adView.frame = adFrame;
		contentView.frame = originalViewFrame;
		
		[UIView commitAnimations];
        self.adBannerIsVisible = NO;
	}
}

#pragma mark -
#pragma mark AdMob Functions
-(void)initAdMobView{
	self.adMobView = [AdMobView requestAdWithDelegate:self];
	self.adMobView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
}

#pragma mark AdMobDelegate methods

- (NSString *)publisherIdForAd:(AdMobView *)adView {
	return ADMOB_PUBLISHER_ID; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
	return self;
}

- (UIColor *)adBackgroundColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:0.208 green:0.435 blue:0.659 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)primaryTextColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)secondaryTextColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}
 
 - (NSArray *)testDevices {
	 return [NSArray arrayWithObjects: @"896ed77d539d86c8b53cddc9005b81c56c1b2681", //Jesse's iPhone4
			 nil];
 }
 
// - (NSString *)testAdActionForAd:(AdMobView *)adMobView {
//	 DLog(@"see AdMobDelegateProtocol.h for a listing of valid values here");
//	 return @"";
// }
 

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView {
	DLog(@"AdMob: Did receive ad");
	// get the view frame
	[self showAdMobBanner];
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
	DLog(@"AdMob: Did fail to receive ad");
	[self hideAdMobBanner];
}

-(void)showAdMobBanner{
    if (!self.adMobBannerIsVisible && !self.adBannerIsVisible)
    {
		UIView *contentView = [self.view.subviews objectAtIndex:0];
        CGRect originalViewFrame = contentView.frame;

		adMobView.frame = CGRectMake(0, self.view.frame.size.height-48, self.view.frame.size.width, 48);
		CGRect adFrame = adMobView.frame;
		
		originalViewFrame.size.height = self.view.frame.size.height - adFrame.size.height;
		
		[self.view addSubview:adMobView];
		
		//There's no animation here, it seems to cause the AdMob view to not display properly.
		
		//[UIView beginAnimations:@"animateAdMobBannerOn" context:NULL];
        //adView.frame = adFrame;
		contentView.frame = originalViewFrame;
		//[UIView commitAnimations];
        self.adMobBannerIsVisible = YES;
    }
}
-(void)hideAdMobBanner{
	if (self.adMobBannerIsVisible) {
		UIView *contentView = [self.view.subviews objectAtIndex:0];
        CGRect originalViewFrame = contentView.frame;
		CGRect adFrame = adMobView.frame;
		
		originalViewFrame.size.height = self.view.frame.size.height; 
		adFrame.origin.y = self.view.frame.size.height;
		
		//[UIView beginAnimations:@"animateAdMobBannerOff" context:NULL];
        //adMobAd.frame = adFrame;
		contentView.frame = originalViewFrame;
		//[UIView commitAnimations];
		
        self.adMobBannerIsVisible = NO;
		
		[adMobView removeFromSuperview];
		[adMobView release];
		adMobView = nil;

		//The app will attempt to re-initialise an adMob view in 10 seconds.
		[NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(initAdMobView) userInfo:nil repeats:NO];
	}
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

#pragma mark -
#pragma mark Rotation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
	if (self.adBannerIsVisible) {
		if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
			if (&ADBannerContentSizeIdentifierLandscape != nil) {
				self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
			}else {
				self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
			}
		}else{
			if (&ADBannerContentSizeIdentifierPortrait != nil) {
				self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
			}else{
				self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;	
			}
		}
	}
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{	
	// This code will alter the content view for the difference in hight
	UIView *contentView = [self.view.subviews objectAtIndex:0];
	CGRect originalViewFrame = contentView.frame;
	
	if(self.adBannerIsVisible) {
		int delta = 18;
		if (&ADBannerContentSizeIdentifierPortrait != nil && &ADBannerContentSizeIdentifierLandscape != nil) {
			if (adView.currentContentSizeIdentifier == ADBannerContentSizeIdentifierPortrait) {
				delta *= -1;
			}
		}else {
			if (adView.currentContentSizeIdentifier == ADBannerContentSizeIdentifier320x50) {
				delta *= -1;
			}
		}		

		// I'm not sure sure if [self.view.subviews objectAtIndex:0] is a documented way to get the main container view of the navigationController
		// by my experience so far has been that it works.
		
		originalViewFrame.size.height = originalViewFrame.size.height + delta;
		contentView.frame = originalViewFrame;
	}
	
	// There's nothing to do with the adMobBanner, it won't resize for for landscape.
}

@end
