//
//  CAHDocument.h
//  CAHMaker
//
//  Created by Uli Kusterer on 2013-12-01.
//  Copyright (c) 2013 Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CAHDocument : NSDocument

@property (weak) IBOutlet NSWindow *listWindow;
@property (weak) IBOutlet NSTableView *cardsTableView;
@property (weak) IBOutlet NSImageView *cardImageView;
@property (weak) IBOutlet NSImageView *backImageView;

-(IBAction)	buildAllImages: (id)sender;

@end
