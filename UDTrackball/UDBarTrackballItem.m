//
//  UDBarTrackballItem.m
//  UDTrackball
//
//  Created by Uwe Dauernheim on 2/14/13.
//  Copyright (c) 2013 Uwe Dauernheim. All rights reserved.
//

#import "UDBarTrackballItem.h"

@interface UDBarTrackballItem()

@property (nonatomic, retain) id textView;
@property (nonatomic) BOOL selectionMode;
@property (nonatomic) CGPoint touchOrigin;
@property (nonatomic) UITextPosition *startCaretOrigin;
@property (nonatomic) UITextPosition *endCaretOrigin;

@end

@implementation UDBarTrackballItem

- (id)initForTextView:(UITextView *)textView {  
    self.textView = textView;
  
    UIButton *trackballButton = [[UIButton alloc] init];
  
    [trackballButton setImage:[UIImage imageNamed:@"trackball.png"] forState:UIControlStateNormal];
    [trackballButton setImage:[UIImage imageNamed:@"trackball blue highlighted.png"] forState:UIControlStateHighlighted];
    [trackballButton setFrame:CGRectMake(0, 0, 44, 44)];
  
    [trackballButton addTarget:self action:@selector(touchDownAction:withEvent:) forControlEvents:UIControlEventTouchDown];
    [trackballButton addTarget:self action:@selector(touchDownRepeatAction:withEvent:) forControlEvents:UIControlEventTouchDownRepeat];
    [trackballButton addTarget:self action:@selector(touchDragAction:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
    [trackballButton addTarget:self action:@selector(touchUpAction:withEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];

    self = [super initWithCustomView:trackballButton];
  
    return self;
}

#pragma mark - Touch

- (void)touchDownAction:(id)sender withEvent:(UIEvent *)event {
    self.selectionMode = NO;
  
    [self prepareTracking:event];
}

- (void)touchDownRepeatAction:(id)sender withEvent:(UIEvent *)event {
    self.selectionMode = YES;
 
    [self prepareTracking:event];
}

- (void)touchDragAction:(id)sender withEvent:(UIEvent *)event {
    // Continue faking a touched down button
    [sender setImage:[UIImage imageNamed:@"trackball blue highlighted.png"] forState:UIControlStateNormal];

    [self track:[[event allTouches] anyObject]];
}

- (void)touchUpAction:(id)sender withEvent:(UIEvent *)event {
    // Reset faked touched down button
    [sender setImage:[UIImage imageNamed:@"trackball.png"] forState:UIControlStateNormal];
    
    [self showMenu];
}

#pragma mark - Tracking

- (void)prepareTracking:(UIEvent *)event {
    // Store touch down origin
    UITouch *touch = [[event allTouches] anyObject];
    self.touchOrigin = [touch locationInView:self.textView];
    
    // Store carets origin
    UITextRange *selection = [self.textView selectedTextRange];
    self.startCaretOrigin = selection.start;
    self.endCaretOrigin = selection.end;
}

- (void)track:(UITouch *)touch {
    // Calculate movement delta
    CGPoint touchPos = [touch locationInView:self.textView];
    CGSize movement = CGSizeMake(touchPos.x - self.touchOrigin.x, touchPos.y - self.touchOrigin.y);
  
    // Set new caret position
    if (self.selectionMode) {
        // Calculate new caret position
        UITextPosition *newCaretPos = [self calcPos:self.endCaretOrigin delta:movement];
        
        // Set new caret position
        [self.textView setSelectedTextRange:[self.textView textRangeFromPosition:self.startCaretOrigin toPosition:newCaretPos]];
    } else {
        // Calculate new caret position
        UITextPosition *newCaretPos = [self calcPos:self.startCaretOrigin delta:movement];
        
        // Set new caret position
        [self.textView setSelectedTextRange:[self.textView textRangeFromPosition:newCaretPos toPosition:newCaretPos]];
    }
 
    // Scroll when necessary
    [self.textView scrollRangeToVisible:[self.textView selectedRange]];
}

- (UITextPosition *)calcPos:(UITextPosition *)pos delta:(CGSize)delta {
    CGRect rect = [self.textView caretRectForPosition:pos];
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
    // Double movement so one tracking motion can reach end to end
    CGFloat newX = center.x + delta.width * 2;
    CGFloat newY = center.y + delta.height * 2;
    
    // Constrain: Don't implicitly jump to beginningOfDocument or endOfDocument
    CGFloat minHeight = [self.textView caretRectForPosition:[self.textView beginningOfDocument]].origin.y;
    CGFloat maxHeight = [self.textView caretRectForPosition:[self.textView endOfDocument]].origin.y;
    if (newY < minHeight)
        newY = minHeight;
    else if (newY > maxHeight)
        newY = maxHeight;
    
    return [self.textView closestPositionToPoint:CGPointMake(newX, newY)];
}

#pragma mark - Menu

- (void)showMenu {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:[self selectionRect] inView:self.textView];
    [menuController setMenuVisible:YES animated:YES];
}

- (CGRect)selectionRect {
    UITextRange *range = [self.textView selectedTextRange];
    CGRect startRect = [self.textView caretRectForPosition:range.start];
    CGRect endRect = [self.textView caretRectForPosition:range.end];
    
    CGFloat left, top, right, bottom;
    
    if (startRect.origin.y != endRect.origin.y) {
        // Multiline selection: Use entire width
        left = 0;
        right = [self.textView frame].size.width;
    } else {
        left = MIN(startRect.origin.x, endRect.origin.x);
        right = MAX(startRect.origin.x + startRect.size.width, endRect.origin.x + endRect.size.width);
    }
    top = MIN(startRect.origin.y, endRect.origin.y);
    bottom = MAX(startRect.origin.y + startRect.size.height, endRect.origin.y +  + endRect.size.height);
    
    return CGRectMake(left, top, right - left, bottom - top);
}

@end
