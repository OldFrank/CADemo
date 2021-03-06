//
//  CardLayoutViewController.m
//  CADemo
//
//  Created by Paul Franceus on 7/20/11.
//
//  MIT License
//
//  Copyright (c) 2011 Paul Franceus
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CardLayoutViewController.h"

#import "DemoCardView.h"
#import "BasicAnimationsViewController.h"
#import "GroupAnimationViewController.h"
#import "ImplicitAnimationsViewController.h"
#import "KeyPathAnimationViewController.h"
#import "MagnifierViewController.h"
#import "MoviePlayerViewController.h"
#import "SublayerTransformView.h"
#import "TransitionViewController.h"

@interface CardLayoutViewController ()

@property(nonatomic, retain) UISegmentedControl *layoutControl;
@property(nonatomic, retain) UIPopoverController *settingsPopover;
@property(nonatomic, retain) KeyPathAnimationViewController *keypathDemo;
@property(nonatomic, retain) ImplicitAnimationsViewController *implicitDemo;

- (void)setParametersForOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation CardLayoutViewController

@synthesize cardViews = cardViews_;
@synthesize cardLayoutView = cardLayoutView_;
@synthesize layoutControl = layoutControl_;
@synthesize settingsPopover = settingsPopover_;
@synthesize keypathDemo = keypathDemo_;
@synthesize implicitDemo = implicitDemo_;

- (void)dealloc {
  [cardViews_ release];
  [layoutControl_ release];
  [settingsPopover_ release];
  [keypathDemo_ release];
  [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setParametersForOrientation:self.interfaceOrientation];
  cardViews_ = [[NSMutableArray alloc] init];
  cardLayoutView_.inset = CGSizeMake(30, 30);
  cardLayoutView_.spacing = CGSizeMake(30, 30);
  cardLayoutView_.animationDuration = 0.4;
  
  layoutControl_ = [[UISegmentedControl alloc] initWithItems:
                    [NSArray arrayWithObjects:@"Grid", @"Circle", nil]];
  layoutControl_.segmentedControlStyle = UISegmentedControlStyleBar;
  layoutControl_.selectedSegmentIndex = 0;
  [layoutControl_ addTarget:self
                    action:@selector(updateLayout)
          forControlEvents:UIControlEventValueChanged];

  UIBarButtonItem *layoutItem = [[[UIBarButtonItem alloc] initWithCustomView:layoutControl_]
                                  autorelease];
  
  self.navigationItem.rightBarButtonItem = layoutItem;
  
  // Every view is always sized to fit the screen. If it's shrunk, it's due to the view transform.
  CGRect layoutFrame = cardLayoutView_.frame;
  CGRect cardFrame = CGRectMake(0, 0, layoutFrame.size.width - 40, layoutFrame.size.height - 148);
  for (int i = 0; i < 8; i++) {
    DemoCardView *cardView = [[[DemoCardView alloc] initWithFrame:cardFrame] autorelease];
    cardView.parentController = self;
    UIView *placeholder = [[UIView alloc] initWithFrame:cardFrame];
    placeholder.backgroundColor = [UIColor colorWithHue:.6 saturation:.3 brightness:.6 alpha:1.0];
    cardView.demoView = (id<DemoCardSubview>)placeholder;
    [cardViews_ addObject:cardView];
  }
  // 0 is implicit animations.
  implicitDemo_ = [[ImplicitAnimationsViewController alloc] initWithFrame:cardFrame];
  ((DemoCardView *)[cardViews_ objectAtIndex:0]).demoView = implicitDemo_;
  
  // 1 is basic demo.
  ((DemoCardView *)[cardViews_ objectAtIndex:1]).demoView =
      [[BasicAnimationsViewController alloc] initWithFrame:cardFrame];
  
  // 2 is keyframe demo.
  keypathDemo_ = [[KeyPathAnimationViewController alloc] initWithFrame:cardFrame];
  ((DemoCardView *)[cardViews_ objectAtIndex:2]).demoView = keypathDemo_;

  // 3 is 3D/Sublayer
  ((DemoCardView *)[cardViews_ objectAtIndex:3]).demoView =
      [[SublayerTransformView alloc] initWithFrame:cardFrame];
  
  // 4 is grouped/composite.
  ((DemoCardView *)[cardViews_ objectAtIndex:4]).demoView =
      [[GroupAnimationViewController alloc] initWithFrame:cardFrame];
  
  // 3 is transitions.
  ((DemoCardView *)[cardViews_ objectAtIndex:5]).demoView =
      [[TransitionViewController alloc] initWithFrame:cardFrame];
  
  // 6 movie in a layer
  ((DemoCardView *)[cardViews_ objectAtIndex:6]).demoView =
      [[MoviePlayerViewController alloc] initWithFrame:cardFrame];
  
  // 7 magnifier
  ((DemoCardView *)[cardViews_ objectAtIndex:7]).demoView =
      [[MagnifierViewController alloc] initWithFrame:cardFrame];  
  
  [cardLayoutView_ setNeedsLayout];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

#pragma mark -
#pragma mark Interface actions

- (void)updateLayout {
  NSInteger index = [layoutControl_ selectedSegmentIndex];
  if (index == 0) {
    cardLayoutView_.layout = kCardLayoutGrid;
  } else {
    cardLayoutView_.layout = kCardLayoutCircle;
  }
  [cardLayoutView_ setNeedsLayout];
}

#pragma mark -
#pragma mark User interface rotation.

- (void)setParametersForOrientation:(UIInterfaceOrientation)orientation {
  if (UIInterfaceOrientationIsPortrait(orientation)) {
    cardLayoutView_.rows = 3;
    cardLayoutView_.columns = 3;
  } else if (UIInterfaceOrientationIsLandscape(orientation)) {
    cardLayoutView_.rows = 3;
    cardLayoutView_.columns = 3;
  }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  cardLayoutView_.animationDuration = duration;
  [self setParametersForOrientation:toInterfaceOrientation];
  
  // TODO: Set the bounds of all the views to the new shape.
  
  [cardLayoutView_ setNeedsLayout];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark CardLayoutDataSource

- (NSString *)observableKeyPath {
  return @"cardViews";
}

@end
