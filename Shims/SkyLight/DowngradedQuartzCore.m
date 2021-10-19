// for the record, i still don't approve of this

@interface CAPresentationModifierGroup:NSObject
@end

@interface CAPresentationModifierGroup(Hax)
@end

@implementation CAPresentationModifierGroup(Hax)

-(void)setUpdatesAsynchronously:(BOOL)flag
{
	trace(@"CAPresentationModifierGroup setUpdatesAsynchronously");
}

-(void)flushWithTransaction
{
	trace(@"CAPresentationModifierGroup flushWithTransaction");
}

@end