
//Made by Stan Tatarnykov, creator of 'Floppy Worm'
//https://itunes.apple.com/ca/app/floppy-worm-epic-silly-hopper/id820626377?mt=8

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "PolygonHelper.h"
#import "polypartition.h"

@implementation SimplePolygon

- (instancetype)init
{
    if ([super init]) {
        self.points=[NSMutableArray array];
    }
    return self;
}
//adds point to points array
-(void) addPoint:(CGPoint)point{
    [self.points addObject:[NSValue valueWithCGPoint:point]];
}
//returns points as pointer for easy debug drawing
-(CGPoint *)pointsAsPointerArray{
    NSInteger numOfPoints=[self.points count];
    CGPoint *points=(CGPoint *)malloc(sizeof(CGPoint)*numOfPoints);
    for(int i=0; i<numOfPoints; i++){
        points[i]=[self.points[i] CGPointValue];
    }
    return points;
}
@end

@implementation PolygonHelper

+(CCPhysicsBody*) physicsBodyFromConcavePolygonPoints:(CGPoint*)points NumPoints:(int)numPoints CornerRadius:(float)cornerRadius{

    //loop through created polygons
    CCPhysicsBody* body = NULL;
    NSArray *resultPolygons=[self partitionPolygonIntoConvexPolygons:points NumPoints:numPoints];
    if([resultPolygons count]>0){
        
        NSMutableArray * shapes = [NSMutableArray array];
        
        //create CCPhysicsShape for each concave polygon
        for (SimplePolygon *aPoly in resultPolygons) {
            CGPoint *polyPoints=[aPoly pointsAsPointerArray];
            int polyPointsCount=[aPoly.points count];
            
            CCPhysicsShape * shape = [CCPhysicsShape polygonShapeWithPoints:polyPoints count:polyPointsCount cornerRadius:cornerRadius];
            [shapes addObject:shape];
            
            //cleanup
            free(polyPoints);
        }
        //Construct body
        body = [CCPhysicsBody bodyWithShapes:shapes];
    }
    else{
        //failed to partition points
        CCLOG(@"Failed to create physics body!");
        return nil;
    }
    
    //set body defaults
    body.type=CCPhysicsBodyTypeStatic;
    
    return body;
    
}

/** input polygon MUST be clock-wise */
+(NSArray*) partitionPolygonIntoConvexPolygons:(CGPoint*)points NumPoints:(int)numPoints{
    
    //convert points array to 'tpplPoly'
    TPPLPoly *inputPoly=new TPPLPoly;
    inputPoly->Init(numPoints);
    inputPoly->SetOrientation(TPPL_CW);
    NSLog(@"");
    for(int i=0;i<numPoints;i++) {
        //SetOrientation
        CGPoint aPoint=points[i];
        (*inputPoly)[i].x = aPoint.x;
        (*inputPoly)[i].y = aPoint.y;
    }
    inputPoly->SetOrientation(TPPL_CCW);
    
//DEBUG: check what points are inputted //
    /*NSLog(@"Input points:( ");
    for(int i=0;i<inputPoly->GetNumPoints(); i++) {
        printf("{%g, %g}",(*inputPoly)[i].x, (*inputPoly)[i].y);
    }
    printf(" )\n");*/
    
    //partition, and return result polygon list
    TPPLPartition partitioner;
    std::list<TPPLPoly> resultPolygonsList;

    double timeNow=[NSDate timeIntervalSinceReferenceDate];
    BOOL success=partitioner.ConvexPartition_OPT(inputPoly,&resultPolygonsList);
    int numPolygons=(int)resultPolygonsList.size();
    if(success){
        CCLOG(@"Successfully partitioned %i points into %i polygons! (run time %.1fms)",numPoints,numPolygons,1000*([NSDate timeIntervalSinceReferenceDate]-timeNow));
    }
    else{
        CCLOG(@"PolygonHelper: Failed to partition %i points! (Make sure the polygon is CLOCKWISE, and that the polygon doesn't overlap itself)",numPoints);
    }
    
    
    //convert result into c pointer array of TPPLPoly
    NSMutableArray *resultPolygons=[NSMutableArray arrayWithCapacity:numPolygons];
    
    std::list<TPPLPoly>::iterator aPoly;
    int polygonCount=0;
    for(aPoly=resultPolygonsList.begin(); aPoly!=resultPolygonsList.end(); aPoly++) {
        //loop through result polygons, convert each to holder object
        SimplePolygon *thisPoly=[[SimplePolygon alloc] init];

        for(int i=0;i<aPoly->GetNumPoints();i++) {
            CGPoint aPoint=CGPointMake(aPoly->GetPoint(i).x, aPoly->GetPoint(i).y);
            [thisPoly addPoint:aPoint]; //points will add in same order
        }

        [resultPolygons addObject:thisPoly];
        polygonCount++;
    }
    
    return resultPolygons;
}
@end
