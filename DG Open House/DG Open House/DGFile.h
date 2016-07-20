//
//  DGFile.h
//  DG Open House
//
//  Created by Chase Acton on 5/4/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <JSONModel/JSONModel.h>

extern NSString * const DGFileTypeListing;
extern NSString * const DGFileTypeEvent;

static NSString * const SGAPIParamAccuracy;

@interface DGFile : JSONModel

@property (nonatomic) NSString *fileID;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *filename;
@property (nonatomic) NSString *agentID;
@property (nonatomic) NSString *mimetype;

@property (nonatomic) BOOL uploaded;

@property (nonatomic) NSDate <Ignore> *date;

@end

//Download
/*

 {
 "id": "33d2db73-0d13-4867-b92b-9f2102a8e1a7",
 "ldapuser_id": "539527",
 "user_file_type": "PROPATT_CARD",
 "filename": "33d2db73-0d13-4867-b92b-9f2102a8e1a7.jpg",
 "mimetype": "image\/jpeg",
 "uploaded": true,
 "mob_created_at": "2016-04-28T14:04:14+00:00",
 "created_at": "2016-04-28T18:08:17+00:00",
 "updated_at": "2016-04-28T18:08:21+00:00"
 }

*/

//Upload
/*

 [{
	"download_needed": false,
	"filename": "e493e03f-8d68-4564-981a-d7451f69b9ca.jpg",
	"id": "e493e03f-8d68-4564-981a-d7451f69b9ca",
	"ldapuser_id": 539527,
	"mimetype": "image/jpeg",
	"mob_created_at": "2016-05-05T23:47:20-0400",
	"sync_needed": true,
	"upload_needed": false,
	"uploaded": false,
	"user_file_type": "PROPATT_CARD"
 }]
 
*/