#import <Foundation/Foundation.h>

@interface BigMoney : NSObject {
	Class _logChecker;
	NSFileManager *_manager;
}

@property (readonly) Class logChecker;
@property (readonly) NSFileManager *manager;

- (instancetype)init;
- (void)noWhammies;
- (void)signLogFile:(NSString*)fileName;

@end
