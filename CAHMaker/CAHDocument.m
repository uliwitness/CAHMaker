//
//  CAHDocument.m
//  CAHMaker
//
//  Created by Uli Kusterer on 2013-12-01.
//  Copyright (c) 2013 Uli Kusterer. All rights reserved.
//

#import "CAHDocument.h"


@interface CAHDocument ()

@property (strong) NSMutableArray	*	cards;
@property (strong) NSString			*	blackBack;
@property (strong) NSString			*	whiteBack;

@end


@implementation CAHDocument

- (id)init
{
    self = [super init];
    if (self)
	{
		self.blackBack = @"Cards\nAgainst\nHumanity";
		self.whiteBack = @"Cards\nAgainst\nHumanity";
    }
    return self;
}

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"CAHDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	[self.cardsTableView reloadData];
	[self tableViewSelectionDidChange: nil];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	NSMutableString		*	cardsString = [NSMutableString string];
	
	[cardsString stringByAppendingFormat: @"BLACK-BACK\n%@",self.blackBack];
	[cardsString stringByAppendingFormat: @"WHITE-BACK\n%@",self.whiteBack];
	
	for( NSDictionary * card in self.cards )
	{
		[cardsString stringByAppendingFormat: @"%@\n%@\n\n", card[@"color"], card[@"text"]];
	}
	
	return nil;
}


enum CAHLineType
{
	CAHLineEmpty,		// Empty line. This is how we start, and this is how we end.
	CAHLineColor,		// Start of a card. Can only occur after empty or unknown lines. Usually BLACK or WHITE. BLACK-BACK and WHITE-BACK can be used to configure the text displayed on the back of the card. Otherwise it's unknown and we skip until the next empty line.
	CAHLineText,		// A line of text. There may be several lines (i.e. paragraphs) of text in one card.
	CAHLineBlackBack,
	CAHLineWhiteBack,
	CAHLineUnknown,		// An unknown line. Can only occur if we're after the end of a card or at the very beginning and the "color" line is neither BLACK nor WHITE
};




- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	NSString		*	cardList = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSArray			*	lines = [cardList componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
	enum CAHLineType	lineType = CAHLineEmpty;
	NSMutableDictionary*card = [NSMutableDictionary dictionary];
	self.cards = [NSMutableArray array];
	self.whiteBack = nil;
	self.blackBack = nil;
	
	for( NSString * currLine in lines )
	{
		if( lineType == CAHLineEmpty && ([currLine isEqualToString: @"WHITE"] || [currLine isEqualToString: @"BLACK"]) )
		{
			lineType = CAHLineColor;
			if( card.count > 0 )
				[self.cards addObject: card];	// Save previous card.
			card = [NSMutableDictionary dictionaryWithObjectsAndKeys: currLine, @"color", nil];
		}
		else if( (lineType == CAHLineColor || lineType == CAHLineText) && currLine.length > 0 )
		{
			lineType = CAHLineText;
			NSString	*	currText = [card objectForKey: @"text"];
			if( currText )
				currText = [currText stringByAppendingFormat: @"\n%@", currLine];
			else
				currText = currLine;
			[card setObject: currText forKey: @"text"];
		}
		else if( currLine.length == 0 )
		{
			if( card.count > 0 )
				[self.cards addObject: card];	// Save previous card.
			card = nil;
			lineType = CAHLineEmpty;
		}
		else if( lineType == CAHLineEmpty && [currLine isEqualToString: @"BLACK-BACK"] )
		{
			lineType = CAHLineBlackBack;
			if( card.count > 0 )
				[self.cards addObject: card];	// Save previous card.
			card = nil;
		}
		else if( lineType == CAHLineEmpty && [currLine isEqualToString: @"WHITE-BACK"] )
		{
			lineType = CAHLineWhiteBack;
			if( card.count > 0 )
				[self.cards addObject: card];	// Save previous card.
			card = nil;
		}
		else if( lineType == CAHLineBlackBack && currLine.length > 0 )
		{
			NSString	*	currText = self.blackBack;
			if( currText )
				currText = [currText stringByAppendingFormat: @"\n%@", currLine];
			else
				currText = currLine;
			self.blackBack = currText;
		}
		else if( lineType == CAHLineWhiteBack && currLine.length > 0 )
		{
			NSString	*	currText = self.whiteBack;
			if( currText )
				currText = [currText stringByAppendingFormat: @"\n%@", currLine];
			else
				currText = currLine;
			self.whiteBack = currText;
		}
		else
		{
			if( card.count > 0 )
				[self.cards addObject: card];	// Save previous card.
			card = nil;
			lineType = CAHLineUnknown;
		}
	}

	if( card.count > 0 )
		[self.cards addObject: card];	// Save previous card.
	
	//NSLog(@"%@ %@\n%@", self.blackBack, self.whiteBack, self.cards);
	
	[self.cardsTableView reloadData];
	[self tableViewSelectionDidChange: nil];

	return YES;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.cards.count;
}

/* This method is required for the "Cell Based" TableView, and is optional for the "View Based" TableView. If implemented in the latter case, the value will be set to the view at a given row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView).
 */
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if( row < 0 )
		return nil;
	return [[self.cards objectAtIndex: row] objectForKey: @"text"];
}


-(void)	saveImage: (NSImage*)theImg name: (NSString*)baseName
{
	[theImg lockFocus];
		NSBitmapImageRep	*	bir = [[NSBitmapImageRep alloc] initWithFocusedViewRect: NSMakeRect(0,0,theImg.size.width,theImg.size.height)];
	[theImg unlockFocus];
	NSData	*	pngData = [bir representationUsingType: NSPNGFileType properties: @{}];
	[pngData writeToFile: [[NSString stringWithFormat: @"~/Desktop/%@.png", baseName] stringByExpandingTildeInPath] atomically: YES];
}


-(IBAction)	buildAllImages: (id)sender
{
	BOOL		builtBlackBack = NO;
	BOOL		builtWhiteBack = NO;
	
	for( NSInteger x = 0; x < self.cards.count; x++ )
	{
		[self.cardsTableView selectRowIndexes: [NSIndexSet indexSetWithIndex: x] byExtendingSelection: NO];
		[self.listWindow display];
		
		NSDictionary	*	currCard = [self.cards objectAtIndex: self.cardsTableView.selectedRow];
		if( [currCard[@"color"] isEqualToString: @"BLACK"] && !builtBlackBack )
		{
			[self saveImage: self.backImageView.image name: @"black_back"];
			
			builtBlackBack = YES;
		}
		else if( [currCard[@"color"] isEqualToString: @"WHITE"] && !builtWhiteBack )
		{
			[self saveImage: self.backImageView.image name: @"white_back"];
			
			builtWhiteBack = YES;
		}
		
		[self saveImage: self.cardImageView.image name: [NSString stringWithFormat: @"card_%@_%ld", [currCard[@"color"] lowercaseString], x +1]];
	}
}


-(void)	tableViewSelectionDidChange: (NSNotification*)notif
{
	if( self.cards.count < self.cardsTableView.selectedRow )
		return;
	
	NSColor			*	accentColor = [NSColor colorWithCalibratedRed:0.140 green:0.292 blue:0.458 alpha:1.000];
	NSDictionary	*	currCard = [self.cards objectAtIndex: self.cardsTableView.selectedRow];
	
	CGFloat		cardScaleFactor = 6;
	CGFloat		cardWidth = 63;
	CGFloat		cardHeight = 88;
	CGFloat		cardTopMargin = 7;
	CGFloat		cardBottomMargin = 10;
	CGFloat		cardHorzMargin = 7;
	
	NSRect		cardBox = NSMakeRect( 0, 0, cardWidth * cardScaleFactor, cardHeight * cardScaleFactor );
	NSImage	*	frontImage = [[NSImage alloc] initWithSize: cardBox.size];
	[frontImage lockFocus];
		// Paint card background & pick colors:
		NSColor	*	textColor = nil;
		NSString*	subText = nil;
		if( [currCard[@"color"] isEqualToString: @"BLACK"] )
		{
			[NSColor.blackColor set];
			textColor = NSColor.whiteColor;
			subText = self.blackBack;
		}
		else if( [currCard[@"color"] isEqualToString: @"WHITE"] )
		{
			[NSColor.whiteColor set];
			textColor = NSColor.blackColor;
			subText = self.whiteBack;
		}
		[NSBezierPath fillRect: cardBox];
		
		// Actual text of card:
		NSRect	textRect = NSInsetRect(cardBox, cardHorzMargin * cardScaleFactor, 0 );
		textRect.size.height -= (cardTopMargin + cardBottomMargin) * cardScaleFactor;
		textRect.origin.y += cardBottomMargin * cardScaleFactor;
		
		NSFont	*	theFont = [NSFont fontWithName: @"Helvetica" size: 6 * cardScaleFactor];
		theFont = [[NSFontManager sharedFontManager] convertFont: theFont toHaveTrait: NSBoldFontMask];
		[currCard[@"text"] drawInRect: textRect withAttributes: @{ NSForegroundColorAttributeName: textColor, NSFontAttributeName: theFont }];

		// Byline with game name under card:
		NSRect		subTextRect = NSInsetRect(cardBox, cardHorzMargin * cardScaleFactor, 0 );
		subTextRect.size.height = cardBottomMargin * cardScaleFactor;
		
		NSImage	*	logoImage = [NSImage imageNamed: @"CAHLogo"];
		NSRect		logoBox = NSZeroRect;
		CGFloat		desiredHeight = subTextRect.size.height / 3;
		logoBox.size.width = logoImage.size.width / (logoImage.size.height / desiredHeight);
		logoBox.size.height = desiredHeight;
		logoImage.size = logoBox.size;
		logoBox.origin.x = subTextRect.origin.x;
		logoBox.origin.y = subTextRect.origin.y +subTextRect.size.height -desiredHeight;
		[logoImage drawInRect: logoBox];
		
		subTextRect.origin.x += ceil(logoBox.size.width) +cardScaleFactor;
		subTextRect.size.width -= ceil(logoBox.size.width) +cardScaleFactor;
		theFont = [NSFont fontWithName: @"Helvetica" size: 3 * cardScaleFactor];
		theFont = [[NSFontManager sharedFontManager] convertFont: theFont toHaveTrait: NSBoldFontMask];
		NSMutableAttributedString	*	attrText = [[NSMutableAttributedString alloc] initWithString: subText attributes: @{ NSForegroundColorAttributeName: textColor, NSFontAttributeName: theFont }];
		NSInteger	offs = [subText rangeOfString: @"\n" options: NSBackwardsSearch].location;
		if( offs != NSNotFound )
		{
			[attrText addAttribute: NSForegroundColorAttributeName value: accentColor range: NSMakeRange( offs +1, subText.length -(offs +1))];
		}
		[attrText.mutableString replaceOccurrencesOfString: @"\n" withString: @" " options: 0 range: NSMakeRange(0, subText.length)];
		[attrText drawInRect: subTextRect];
	[frontImage unlockFocus];
	
	self.cardImageView.image = frontImage;
	
	NSImage	*	backImage = [[NSImage alloc] initWithSize: cardBox.size];
	[backImage lockFocus];
		textColor = nil;
		NSString	*	text = nil;
		if( [currCard[@"color"] isEqualToString: @"BLACK"] )
		{
			[NSColor.blackColor set];
			textColor = NSColor.whiteColor;
			text = self.blackBack;
		}
		else if( [currCard[@"color"] isEqualToString: @"WHITE"] )
		{
			[NSColor.whiteColor set];
			textColor = NSColor.blackColor;
			text = self.whiteBack;
		}
		[NSBezierPath fillRect: cardBox];
		textRect = NSInsetRect(cardBox, cardHorzMargin * cardScaleFactor, 0 );
		textRect.size.height -= (cardTopMargin + cardBottomMargin) * cardScaleFactor;
		textRect.origin.y += cardBottomMargin;
		
		theFont = [NSFont fontWithName: @"Helvetica" size: 12 * cardScaleFactor];
		theFont = [[NSFontManager sharedFontManager] convertFont: theFont toHaveTrait: NSBoldFontMask];
		attrText = [[NSMutableAttributedString alloc] initWithString: text attributes: @{ NSForegroundColorAttributeName: textColor, NSFontAttributeName: theFont }];
		offs = [text rangeOfString: @"\n" options: NSBackwardsSearch].location;
		if( offs != NSNotFound )
		{
			[attrText addAttribute: NSForegroundColorAttributeName value: accentColor range: NSMakeRange( offs +1, text.length -(offs +1))];
		}
		[attrText drawInRect: textRect];
	[backImage unlockFocus];
	
	self.backImageView.image = backImage;
}

@end
