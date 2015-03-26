
//Made by Stan Tatarnykov, creator of 'Floppy Worm'
//https://itunes.apple.com/ca/app/floppy-worm-epic-silly-hopper/id820626377?mt=8

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//simple struct to hold polygons pointer, and number
@interface SimplePolygon : NSObject
/** array of NSValue-wrapped CGPoints */
@property (nonatomic, strong) NSMutableArray *points;
-(void) addPoint:(CGPoint)point;
-(CGPoint*) pointsAsPointerArray;
@end

@interface PolygonHelper : NSObject {
    
}

/** (input polygon MUST be clock-wise)
  returns NSArray of all polygons (as SimplePolygon objects), with NSArray of wrapped CGPoints for each polygon*/
+(NSArray*) partitionPolygonIntoConvexPolygons:(CGPoint*)points NumPoints:(int)numPoints;

/** creates a physicsbody for a CONCAVE polygon! (polygon points must be CLOCKWISE, polygon can't overlap itself) */
+(CCPhysicsBody*) physicsBodyFromConcavePolygonPoints:(CGPoint*)points NumPoints:(int)numPoints CornerRadius:(float)cornerRadius;
@end
