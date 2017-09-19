# odokus 3rd Party API (iOS)

Simple class to use odokus 3rd party API calls in your project. Using the geo api - you gain a very easy and fast way to store and fetch geo tagged events from and to your odokus account.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What things you need to install the software and how to install them

* XCode (install using Mac AppStore)
* CocoaPods (from Terminal: `sudo gem install cocoapods` )
* A XCode project setup to start with
* podfile within the projects root folder
* OdokusGeoApi.h / OdokusGeoApi.m from this repo
* Your user credentials for odokus 

Use Cocoapods to add the following projects:

```
	pod 'AFNetworking', '~> 3.1'
  	pod 'ProgressHUD'
```
Where ProgressHUD is totally optional.


### Using the API

Within your project, adopt the OdokusApiDelegate protocol and instantiate OdokusGeoApi like

```
// .h file
@interface YourAwesomeViewController : UIViewController <OdokusGeoApiDelegate>
{
    OdokusGeoApi* odokus;
}
...
// .m file
@implementation YourAwesomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    odokus = [[OdokusGeoApi alloc]initWithDelegate:self andUserName:YOUR_USERNAME andPassword:YOUR_PASSWORD];
}

```

And your basically good to go. To actually send or retrieve any data, you need to implement the required delegate methods and may adopt other delegate methods as it suit your needs. Like:

* ping (Usefull to see if credentials are correct)
* saveGeoEvent: (To send a GeoEvent to odokus) or
* requestGeoEventsWithStart: andEnd: (to retrieve all Geo Events within an given timespan.

```
// API methods
/**
 Simple API call to verify if connection to the odokus servers are possible and user credentials are correct.
 */
- (void)ping;

/**
 Call to retrieve GEO Events from odokus

 @param start : Starting date of the time span you will receive events for.
 @param end : Ending date of the time span you will receive events for.
 */
- (void)requestGeoEventsWithStart:(NSDate*_Nonnull)start andEnd:(NSDate*_Nonnull)end;

/**
 Call to add a new GEO Event to odokus

 @param date : The events date.
 @param typeString : Your Developer API App identifier.
 @param location : The events CLLocation.
 @param dictionary : A dictionary containing keys and values for that particular event.
 */
- (void)saveGeoEvent:(NSDate*_Nonnull)date typeString:(NSString*_Nonnull)typeString atLocation:(CLLocation*_Nonnull)location withExtensions:(NSDictionary*_Nonnull)dictionary;
```

End with an example of getting some data out of the system or using it for a little demo



## Authors

* **Johannes Dürr** - *Initial work* - [whileCoffee](https://whilecoffee.de)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details