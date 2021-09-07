// catch missing selectors

#import "Utils.h"

@interface %name%:NSObject
@end

@implementation %name%

-(void)fake
{
}

+(void)fake
{
}

-(void)forwardInvocation:(NSInvocation*)invocation
{
}

+(void)forwardInvocation:(NSInvocation*)invocation
{
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	trace(@"Stub (%@) instance %@",NSStringFromClass(self.class),NSStringFromSelector(selector));
	
	return [super methodSignatureForSelector:@selector(fake)];
}

+(NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	trace(@"Stub (%@) class %@",NSStringFromClass(self.class),NSStringFromSelector(selector));
	
	return [super methodSignatureForSelector:@selector(fake)];
}

@end