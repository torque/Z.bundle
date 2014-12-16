#import "BigMoney.h"
#import "XLDLogChecker.h"

void callback( ConstFSEventStreamRef          stream,
               void                          *data,
               size_t                         numEvents,
               void                          *paths,
               const FSEventStreamEventFlags *flags,
               const FSEventStreamEventId    *ids ) {
	for ( int i = 0; i < numEvents; ++i ) {
		if ( flags[i] & (kFSEventStreamEventFlagItemModified | kFSEventStreamEventFlagItemCreated) ) {
			[(BigMoney*)data signLogFile:[NSString stringWithCString:((char**)paths)[i] encoding:NSUTF8StringEncoding]];
		}
	}
}

@implementation BigMoney

@synthesize logChecker = _logChecker;
@synthesize manager = _manager;

- (instancetype)init {
	if ( self = [super init] ) {
		_logChecker = NSClassFromString( @"XLDLogChecker" );
		_manager = [NSFileManager defaultManager];
	}
	return self;
}

- (void)noWhammies {
	if ( [self logChecker] ) {
		NSString *logDir = @"/tmp/logsToSign";

		if ( ![[self manager] fileExistsAtPath:logDir isDirectory:nil] ) {
			NSLog( @"logDir doesn't exist." );
			[[self manager] createDirectoryAtPath:logDir withIntermediateDirectories:NO attributes:nil error:nil];
		}

		NSArray *logDirList = [[self manager] contentsOfDirectoryAtPath:logDir error:nil];

		if ( logDirList ) {
			for ( int i = 0; i < [logDirList count]; ++i ) {
				[self signLogFile:[logDir stringByAppendingPathComponent:logDirList[i]]];
			}
		}

		NSArray *pathsToWatch = [[NSArray alloc] initWithObjects:logDir, nil];
		FSEventStreamContext context = { .version = 0, .info = self, .retain = NULL, .release = NULL, .copyDescription = NULL };
		FSEventStreamRef stream = FSEventStreamCreate(nil, callback, &context, (CFArrayRef)pathsToWatch, kFSEventStreamEventIdSinceNow, 1.0, kFSEventStreamCreateFlagFileEvents );
		FSEventStreamScheduleWithRunLoop( stream, CFRunLoopGetCurrent( ), kCFRunLoopDefaultMode );
		FSEventStreamStart( stream );
		CFRunLoopRun( );

	} else {
		NSLog( @"LogChecker not loaded. Doing nothing." );
	}
}

- (void)signLogFile:(NSString*)fileName {
	BOOL isDirectory = NO;
	if (   [[self manager] fileExistsAtPath:fileName isDirectory:&isDirectory]
	    &&  !isDirectory
	    && [[fileName pathExtension] isEqualToString:@"log"]
	    && ![fileName hasSuffix:@"-signed.log" ] ) {
		NSMutableString *logFileContents = [NSMutableString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
		if ( logFileContents ) {
			NSLog( @"Signing log file: %@", fileName );
			NSString *signedLog = [[fileName stringByDeletingPathExtension] stringByAppendingString:@"-signed.log"];
			[[self logChecker] appendSignature:logFileContents];
			[logFileContents writeToFile:signedLog atomically:NO encoding:NSUTF8StringEncoding error:nil];
		}
	}
}

@end
