//
//  FindTeamViewController.m
//  ClubMaster
//
//  Created by Henrik Hansen on 25/01/12.
//

#import "FindTeamViewController.h"
#import "TeamTableViewCell.h"
#import "ISO8601DateFormatter.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "ViewTeamViewController.h"

@implementation FindTeamViewController

@synthesize tableView;
@synthesize registrations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Find team", @"");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    ASIHTTPRequest *requestUserRegistrations = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kAllRegistrations, [preferences valueForKey:@"serverurl"]]]];
    [requestUserRegistrations setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [requestUserRegistrations startSynchronous];
    
    NSError *error = [requestUserRegistrations error];
    //NSLog(@"return string %@", [requestUserRegistrations responseString]);
    //NSLog(@"error code %d", [requestUserRegistrations responseStatusCode]);
    if (!error) {
        if ([requestUserRegistrations responseStatusCode] == 200) {
            NSData *jsonData = [requestUserRegistrations responseData];
            NSDictionary *jsonRegistrations = [jsonData objectFromJSONData];
            
            NSLog(@"user registrations %@", jsonRegistrations);
            self.registrations = [jsonRegistrations objectForKey:@"data"];
        }
    }
    
    [self.tableView reloadData]; 

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tw numberOfRowsInSection:(NSInteger)section
{
    return [registrations count];
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TeamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"TeamTableViewCell" owner:nil options:nil];
        
        for (UIView *view in views) {
            if([view isKindOfClass:[UITableViewCell class]]) {
                cell = (TeamTableViewCell *)view;
            }
        }
    }
    
    NSDictionary *data = [registrations objectAtIndex:indexPath.row];
    
    cell.title.text = [data objectForKey:@"team_name"];

    NSArray *instructors = [data objectForKey:@"instructors"];

    if ([instructors count]) {
        cell.instructor.text = [NSString stringWithFormat:@"%@ %@", [[instructors objectAtIndex:0] objectForKey:@"first_name"], [[instructors objectAtIndex:0] objectForKey:@"last_name"]];
    }

    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *firstDate = [formatter dateFromString:[data objectForKey:@"first_date"]];
    NSDate *endDate = [formatter dateFromString:[data objectForKey:@"end_date"]];
    [formatter release], formatter = nil;

	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
	NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags
                                                                   fromDate:firstDate
                                                                     toDate:endDate options:0];

    cell.duration.text = [NSString stringWithFormat:@"%02d:%02d", [components hour], [components minute]];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setDateFormat:@"HH:mm"];
    
    cell.time.text = [NSString stringWithFormat:@"%@", [df stringFromDate:firstDate]];
    
    [df setDateFormat:@"MMM dd"];
    
    cell.date.text = [NSString stringWithFormat:@"%@", [df stringFromDate:firstDate]];
    
    [df release];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tw titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"All teams", @"");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewTeamViewController *viewTeamViewController = [[ViewTeamViewController alloc] init];
    viewTeamViewController.data = [registrations objectAtIndex:indexPath.row];
    viewTeamViewController.isAttending = NO;
    [self.navigationController pushViewController:viewTeamViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

@end