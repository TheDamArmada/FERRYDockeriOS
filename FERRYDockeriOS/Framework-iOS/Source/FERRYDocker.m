//
//  FERRYDocker.m
//  FERRYDockerDev
//
//  Created by Jordi.Martinez on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FERRYDocker.h"


@interface FERRYDocker (internal) 

-(NSString *) sanitizeString:(NSString *)string;
-(void) parseFile:(NSString *)file toView:(UIView *)tgtView;
-(void) processNode:(TBXMLElement *)node toView:(UIView *)view;
-(UIView *) createAndAddNode:(TBXMLElement *)node toView:(UIView *)view;
-(void) trimViews;
-(void) setForceCache:(BOOL)_forceCache;
@end


typedef enum {
    NodeImage,
    NodeButton,
    NodeTableView
    
} NodeType;

@implementation FERRYDocker

-(void) dealloc
{
    
    if (viewsDict) {
        [viewsDict release];
        viewsDict = nil;
    }
    
    if (viewsById) {
        [viewsById release];
        viewsById = nil;
    }
    
    if (viewsInOrder) {
        [viewsInOrder release];
        viewsInOrder = nil;
    }
    
    [super dealloc];
}


+(FERRYDocker *) buildFromFile:(NSString *)file toView:(UIView *)tgtView
{
    FERRYDocker *builder = [[[self alloc] init] autorelease];
    [builder parseFile:file toView:tgtView];
    return builder;
}

+(FERRYDocker *) buildFromFile:(NSString *)file toView:(UIView *)tgtView cacheImages:(BOOL)_doCache
{
    FERRYDocker *builder = [[[self alloc] init] autorelease];
    [builder setForceCache:_doCache];
    [builder parseFile:file toView:tgtView];
    return builder;
}




-(UIView *) getViewWithName:(NSString *)viewName
{
    return [viewsDict valueForKey:[self sanitizeString:viewName]];
}

-(UIView *) getViewWithId:(int)layerId
{
    return [viewsDict valueForKey:[viewsById valueForKey:[NSString stringWithFormat:@"%i", layerId]]];
}

@end



@implementation FERRYDocker (internal)

-(void) setForceCache:(BOOL)_forceCache
{
    forceCache = _forceCache;
}

-(void) parseFile:(NSString *)file toView:(UIView *)tgtView
{
    
    xmlparser = [[TBXML tbxmlWithXMLFile:file] retain];
    
    TBXMLElement    *_root = xmlparser.rootXMLElement;
    
    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    
    viewsDict = [newDict retain];
    
    [newDict release];
    
    viewsInOrder = [[NSMutableArray alloc] init];
    
    //[viewsInOrder addObject:tgtView];
    
    viewsById = [[NSMutableDictionary alloc] init];
    
    retinaCoords = NO;
    
    
    if (_root) {
        
        TBXMLElement *_nodesList;
                
        _nodesList = [TBXML childElementNamed:@"nodesInfo" parentElement:_root];   
        
        TBXMLElement *_infoXML = [TBXML childElementNamed:@"info" parentElement:_root];
        if (_infoXML) {
            NSString    *__isEventStr = [TBXML valueOfAttributeNamed:@"isEven" forElement:_infoXML];        
            if (__isEventStr) 
                isEven = [__isEventStr isEqualToString:@"true"];                
        }
        
        isRetinaDevice =  ([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0);
        
        TBXMLElement *_retinaDescr = [TBXML childElementNamed:@"retinaNodesInfo" parentElement:_root];
        TBXMLElement *_standardDescr = [TBXML childElementNamed:@"standardNodesInfo" parentElement:_root];
        
        if (!isEven) {            
            if (isRetinaDevice) {
                if (_retinaDescr) _nodesList = [TBXML childElementNamed:@"retinaNodesInfo" parentElement:_root];   
            }
            else { 
                if (_standardDescr) {
                    _nodesList = _standardDescr;                   
                }
            }
        }

        
        if (!_nodesList) {
            NSAssert(false,@"SEEMS THERE'S NO DEFINITION FOR THIS DEVICE RESOLUTION");   
        }
        
        TBXMLElement *_node = [TBXML childElementNamed:@"node" parentElement:_nodesList];      
        
        [self processNode:_node toView:tgtView];        
    }
    

    [self trimViews];
    
    [xmlparser release];        
}


-(void) trimViews
{
    
    if ([viewsInOrder count]==0) return;
    
    NSArray* reversedArray = [[viewsInOrder reverseObjectEnumerator] allObjects];
    for (UIView *v in reversedArray)
    {
        if (v.subviews.count == 0) continue;
        
        if ([v class] == [UIView class]) {
            
            
            CGPoint topLeft         = CGPointMake(MAXFLOAT, MAXFLOAT);
            CGPoint bottomRight     = CGPointMake(-MAXFLOAT, -MAXFLOAT);
            

            for (UIView *vv in v.subviews) {
                
                CGRect area = [vv frame];
                // convert to parent coordinates
                area = [vv.superview convertRect:area fromView:vv.superview];
                
                topLeft.x = MIN(topLeft.x, area.origin.x);
                topLeft.y = MIN(topLeft.y, area.origin.y);
                
                bottomRight.x = MAX(bottomRight.x, area.origin.x + area.size.width);
                bottomRight.y = MAX(bottomRight.y, area.origin.y + area.size.height);                
            }
            
            CGRect realArea = CGRectMake(topLeft.x, topLeft.y, bottomRight.x-topLeft.x, bottomRight.y-topLeft.y);
            
            for (UIView *vv in v.subviews) {
                [vv setFrame:CGRectOffset(vv.frame, -topLeft.x, -topLeft.y)];
            }
            
            [v setFrame:realArea];
            
        }
    }
    
    [viewsInOrder release];
    viewsInOrder = nil;
}


-(void) processNode:(TBXMLElement *)node toView:(UIView *)view
{
    do {
        UIView *newParent = [self createAndAddNode:node toView:view];
        
        if (node->firstChild) {
            [self processNode:node->firstChild toView:newParent];            
        }            
    } while ((node = node->nextSibling));
}



-(UIView *) createAndAddNode:(TBXMLElement *)node toView:(UIView *)view
{
    
    NSString *name      = (NSString *)[TBXML valueOfAttributeNamed:@"name" forElement:node];
    NSString *img       = [TBXML valueOfAttributeNamed:@"img" forElement:node];
    int     layerId     = [[TBXML valueOfAttributeNamed:@"id" forElement:node] intValue];
    NSString *cacheStr  = [TBXML valueOfAttributeNamed:@"cache" forElement:node];
    BOOL    _doCache    = ([cacheStr isEqualToString:@"YES"])? YES : NO;
    
    
    NSString *nodeT  = (NSString *)[TBXML valueOfAttributeNamed:@"type" forElement:node];
    
    if ([nodeT isEqualToString:@"folder"]) {
        
        UIView *newV = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
        
        [newV setBackgroundColor:[UIColor clearColor]];
        [viewsById setValue:name forKey:[NSString stringWithFormat:@"%i", layerId]];
        [viewsDict setValue:newV forKey:name];
        [view insertSubview:newV atIndex:0];
        [viewsInOrder addObject:newV];
        return [newV autorelease];
    } 
    
    
    
    CGFloat left    = (CGFloat)[[TBXML valueOfAttributeNamed:@"x" forElement:node] floatValue];
    CGFloat top     = (CGFloat)[[TBXML valueOfAttributeNamed:@"y" forElement:node] floatValue];        
    CGFloat width   = (CGFloat)[[TBXML valueOfAttributeNamed:@"w" forElement:node] floatValue];
    CGFloat height   = (CGFloat)[[TBXML valueOfAttributeNamed:@"h" forElement:node] floatValue];
    
    if (isRetinaDevice) {
        left /= 2.f;
        top /= 2.f;
        width /= 2.f;
        height /= 2.f;
        
    } else {
        
        if (isEven) {
            left /= 2.f;
            top /= 2.f;       
            width /= 2.f;
            height /= 2.f;            
        }
    }
    
    
    // change for initWithContentsOfFile (path)
    // ***
    
    UIImage *_img;
    
    if (_doCache || forceCache) {
    
        _img = [UIImage imageNamed:img];
        
    } else {
        
        NSString *_imgPath;
        
        
        if(isRetinaDevice) {
            img = [NSString stringWithFormat:@"%@@2x", img];
            _imgPath= [[NSBundle mainBundle] pathForResource:img ofType:@"png"];
            
        } else {
            _imgPath= [[NSBundle mainBundle] pathForResource:img ofType:@"png"];
        }
        
        if (_imgPath==nil) {
            NSLog(@"IMAGE %@ NOT FOUND", img);
            return nil;        
        }              
        
        _img = [UIImage imageWithContentsOfFile:_imgPath];
    }

    
    NodeType type = NodeImage;
    
    
    if ([name hasPrefix:@"but_"]) type = NodeButton;
    if ([name hasPrefix:@"tbv_"]) type = NodeTableView;

    UIView *newV;

    CGRect frame = CGRectMake(left, top, _img.size.width, _img.size.height);
    

    
    BOOL isOnState = NO;
    BOOL addToSystem = YES;
    
    switch (type) {
            
        case NodeButton:
            
            
            if ([name hasSuffix:@"_on"] || [name hasSuffix:@"_off"]) { 
                
                NSString *buttonRealName;
                NSRange suffixRange;
                
                if ([name hasSuffix:@"_on"]) {                            
                    isOnState = YES;
                    suffixRange = [name rangeOfString:@"_on"];
                } else {
                    suffixRange = [name rangeOfString:@"_off"];
                }
                
                buttonRealName = [name substringToIndex:suffixRange.location];
                
                UIButton *prevButton = (UIButton *)[self getViewWithName:buttonRealName];
                      
                if (prevButton != nil) {
                    addToSystem = NO;
                    [prevButton setImage:_img forState:(isOnState)? UIControlStateHighlighted : UIControlStateNormal];
                    break;
                } else {
                    name = buttonRealName;
                }   
            }
            
            
            newV = [[UIButton alloc] initWithFrame:frame] ;
            UIButton *butV = (UIButton *)newV;                    
            [butV setImage:_img forState:(isOnState)? UIControlStateHighlighted : UIControlStateNormal];
            newV = butV;
            break;
            
            
        case NodeImage:                    

                      
            newV   = [[UIImageView alloc] initWithImage:_img];                    
            break;
            
        case NodeTableView:                    
            newV = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];                    
            break;
            
            
    }
    
    if (addToSystem) {
        newV.frame = CGRectMake(left, top, _img.size.width, _img.size.height);
        
        if ([viewsDict valueForKey:name]) {
            NSLog(@"FERRYDocker >> duplicated layer name %@", name);
        }
        
        [viewsById setValue:name forKey:[NSString stringWithFormat:@"%i", layerId]];
        [viewsDict setValue:newV forKey:name];        
        
        
        [view insertSubview:newV atIndex:0];
        [newV autorelease];
    }
    
    frame = CGRectZero;
    
    return nil;
    
}




-(NSString *) sanitizeString:(NSString *)string
{
    NSString *newStr = [string stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    return newStr;
}

@end