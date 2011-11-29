//
//  FERRYDocker.h
//  Framework-iOS
//
//  Created by The Dam Armada on 10/12/11.
//  Copyright 2011 The Dam Armada. All rights reserved.
//

/*
Copyright (c) 2011, The Dam Armada
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/
// FERRYDocker includes TBXML

/* TBXML License:
 Copyright (c) 2009 Tom Bradley
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "TBXML.h"



@interface FERRYDocker : NSObject {
    UIView                  *targetView;        
    TBXML                   *xmlparser;
    NSMutableDictionary     *viewsDict;
    NSMutableArray          *viewsInOrder;
    BOOL                    retinaCoords;
    NSString                *resolution;
    NSMutableDictionary     *viewsById;
    BOOL                    forceCache;
    BOOL                    isEven;
    BOOL                    isRetinaDevice;
}


/* 
    Recreates the XML file in the specified UIView 
    Returns an autoreleased FERRYDocker object
 */


+(FERRYDocker *) buildFromFile:(NSString *)file toView:(UIView *)tgtView;

/* 
    Recreates the XML file in the specified UIView caching the images using [UIImage imageNamed:]
    Returns an autoreleased FERRYDocker object
 
    Alternatively you can also specified what images will be cached on the XML file. Add the attribute 'cache="YES"' no the nodes you want to cache
 */

+(FERRYDocker *) buildFromFile:(NSString *)file toView:(UIView *)tgtView cacheImages:(BOOL)_doCache;


/* 
    Returns the UIView with the specified name (from XML file)
    Please note that if a button has defined both states (on/off) the name is "but_"+name ; no sufix ("_on"/"_off")
*/
-(UIView *) getViewWithName:(NSString *)viewName;

/* 
    Returns the UIView with the specified id
    Please note that numerical ids may change everytime FERRYScript is executed
 */

-(UIView *) getViewWithId:(int)layerId;

@end




