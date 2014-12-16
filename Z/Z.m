#import "Z.h"

@implementation Z

+ (NSString *)pluginName {
	return @"Z";
}

+ (BOOL)canLoadThisBundle {
	return YES;
}

- (instancetype)init {
	if (self = [super init] ) {
		[NSThread detachNewThreadSelector:@selector(noWhammies) toTarget:[BigMoney new] withObject:nil];
	}
	
	return self;
}

- (NSView *)prefPane {
	return nil;
}
- (void)savePrefs {

}
- (void)loadPrefs {

}
- (id)createTaskForOutput {
	return nil;
}
- (id)createTaskForOutputWithConfigurations:(NSDictionary *)cfg {
	return nil;
}

- (NSMutableDictionary *)configurations {
	return nil;
}

- (void)loadConfigurations:(id)configurations {

};

@end
