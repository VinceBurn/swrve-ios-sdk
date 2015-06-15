#import "SwrveInputMultiValueLong.h"
#import "SwrveChoiceArray.h"
#import "SwrveConversationStyler.h"

@implementation SwrveInputMultiValueLong

-(id) initWithTag:(NSString *)tag andDictionary:(NSDictionary *)dict {
    self = [super initWithTag:tag type:kSwrveInputMultiValueLong andDictionary:dict];
    if(self) {
        self.description = [dict objectForKey:@"description"];
        NSArray *arr = [dict objectForKey:@"values"];
        NSMutableArray *vals =[[NSMutableArray alloc] initWithCapacity:arr.count];
        for(NSDictionary *innerDict in arr) {
            NSString *questionId = [innerDict objectForKey:@"question_id"];
            NSArray *options = [innerDict objectForKey:@"options"];
            NSString *title = [innerDict objectForKey:@"title"];
            SwrveChoiceArray  *vgChoiceArray = [[SwrveChoiceArray alloc] initWithArray:options andQuestionId:questionId andTitle:title];
            [vals addObject:vgChoiceArray];
        }
        self.values = vals;
    }
    return self;
}

-(UITableViewCell *) cellForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
    if (![self hasDescription] || row > 0) {
        NSUInteger finalRow = row - ([self hasDescription]? 1 : 0);
        UITableViewCell *cell = [self fetchStandardCell:tableView];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        SwrveChoiceArray *vgChoiceArray = [self.values objectAtIndex:finalRow];
        cell.textLabel.text = vgChoiceArray.title;
        cell.detailTextLabel.text = vgChoiceArray.selectedItem;
        [SwrveConversationStyler styleView:cell withStyle:self.style];
        return [self styleCell:cell atRow:finalRow];
    } else {
        return [self fetchDescriptionCell:tableView];
    }
}

-(NSDictionary *) userResponse {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:self.values.count];
    for(SwrveChoiceArray *choiceArray in self.values) {
        [dict addEntriesFromDictionary:[choiceArray userResponse]];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

-(id)choicesForRow:(NSUInteger) row {
    return [self.values objectAtIndex:row - ([self hasDescription]? 1 : 0)];
}

-(BOOL)isComplete {
    for(SwrveChoiceArray *choiceArray in self.values) {
        NSDictionary *dict = [choiceArray userResponse];
        for (NSString *key in [dict allKeys]) {
            if ([[dict objectForKey:key] isEqualToString:@""]) {
                return NO;
            }
        }
    }
    return YES;
}

@end